extends ColorRect

var current_villager_node = null
onready var DRAGER = get_node("../Interaction/Drager")
var RECS = ["wood","adobe","stone","gold"]

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

func check_cards():
	if !"civ_cards" in GC.PLAYER: GC.PLAYER["civ_cards"] = []
	if GC.PLAYER["civ_cards"].size()>=2: return
	$HBox_cards.visible = false
	$HBox_recs.visible = false
	$Back.visible = false
	if GC.PLAYER["civ_cards"].size()<2: GC.PLAYER["civ_cards"].append(get_random_card())
	if GC.PLAYER["civ_cards"].size()<2: GC.PLAYER["civ_cards"].append(get_random_card())
	FM.push_var("games/"+GC.GAME.name+"/players/"+GC.USER.name,"civ_cards",GC.PLAYER["civ_cards"])
	yield(FM,"complete_push")
	$HBox_cards.visible = true
	$HBox_recs.visible = true
	$Back.visible = true
	
func get_random_card():
	var rec = ["adobe","stone","gold"][randi()%3]
	var bon = ["camp","tool","villager","build"][randi()%4]
	return [rec,bon]

func set_card_data(card,data):
	card.get_node("rec/r1").texture = load("res://assets/"+data[0]+".jpg")
	card.get_node("bon/r1").texture = load("res://assets/"+data[1]+".jpg")

func onBackButton():
	visible = false
	GC.BUILD_TO_CONSTRUCT = null
	DRAGER.free_node(current_villager_node)
	current_villager_node = null

func onClickCard(id):
	print(id)
	GC.CIV_TO_CONSTRUCT = id
	visible = false

func update_stock():
	var data = {}
	for bon in $VBox_stock.get_children(): data[bon.name] = 0
	if("civ_bonif" in GC.PLAYER): for bon in GC.PLAYER["civ_bonif"]: data[bon] += 1
	for bon in $VBox_stock.get_children(): bon.get_node("Label").text = "x"+str( data[bon.name] )
