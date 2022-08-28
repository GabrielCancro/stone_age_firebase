extends ColorRect

onready var DRAGER = get_node("../Interaction/Drager")

func _ready():
	randomize()
	visible=false
	$Back.connect("button_down",self,"onBackButton")
	$HBox_cards/B1.connect("button_down",self,"onClickCard",[0])
	$HBox_cards/B2.connect("button_down",self,"onClickCard",[1])

func showCivPanel():
	visible = true
	check_cards()
	set_card_data($HBox_cards/B1,GC.PLAYER.civ_cards[0])
	set_card_data($HBox_cards/B2,GC.PLAYER.civ_cards[1])
	update_stock()
	$noWorker.visible = (DRAGER.result.CIV<1)

func check_cards():
	if !"civ_cards" in GC.PLAYER: GC.PLAYER["civ_cards"] = []
	if GC.PLAYER["civ_cards"].size()>=2: return
	$HBox_cards.visible = false
	$Back.visible = false
	if GC.PLAYER["civ_cards"].size()<2: GC.PLAYER["civ_cards"].append(get_random_card())
	if GC.PLAYER["civ_cards"].size()<2: GC.PLAYER["civ_cards"].append(get_random_card())
	FM.push_var("games/"+GC.GAME.name+"/players/"+GC.USER.name,"civ_cards",GC.PLAYER["civ_cards"])
	yield(FM,"complete_push")
	$HBox_cards.visible = true
	$Back.visible = true
	
func get_random_card():
	var rec = ["adobe","stone"][randi()%2]
	var bon = ["camp","tool","villager","build"][randi()%4]
	return [rec,bon]

func set_card_data(card,data):
	card.get_node("rec/r1").texture = load("res://Games/StoneAge/assets/res/"+data[0]+".jpg")
	card.get_node("bon/r1").texture = load("res://Games/StoneAge/assets/res/"+data[1]+".jpg")
	card.get_node("cost2/r1").texture = load("res://Games/StoneAge/assets/res/"+data[1]+".jpg")
	if(!"civ_bonif" in GC.PLAYER): GC.PLAYER["civ_bonif"] = []
	var wood_cost = 3 + floor(GC.PLAYER.civ_bonif.size()/2) + card.get_index()
	card.get_node("cost/Label").text = "-"+str( wood_cost )
	var cant_bonif = 0
	for b in GC.PLAYER.civ_bonif: if b == data[1]: cant_bonif += 1
	cant_bonif = 1+floor(cant_bonif/2)
	if(data[1]=="villager"): 
		if(cant_bonif)<2: cant_bonif = 0
		else: cant_bonif = 1
	card.get_node("cost2/Label").text = "-"+str( cant_bonif )
	card.disabled = (GC.PLAYER["wood"]<wood_cost || GC.PLAYER[data[1]]<cant_bonif)

func onBackButton():
	visible = false
	GC.BUILD_TO_CONSTRUCT = null
	DRAGER.free_node_from_stay("CIV")

func onClickCard(id):
	print(id)
	GC.CIV_TO_CONSTRUCT = id
	visible = false

func update_stock():
	var data = {}
	for bon in $VBox_stock.get_children(): data[bon.name] = 0
	if("civ_bonif" in GC.PLAYER): for bon in GC.PLAYER["civ_bonif"]: data[bon] += 1
	for bon in $VBox_stock.get_children(): bon.get_node("Label").text = "x"+str( data[bon.name] )
