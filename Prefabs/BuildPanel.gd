extends ColorRect

onready var DRAGER = get_node("../Interaction/Drager")
var RECS = ["wood","adobe","stone","gold"]

func _ready():
	randomize()
	visible=false
	$Back.connect("button_down",self,"onBackButton")
	$B1.connect("button_down",self,"onClickHouse",[0])
	$B2.connect("button_down",self,"onClickHouse",[1])

func showBuildPanel():
	visible = true
	check_cards()
	set_card_data($B1,GC.PLAYER.build_cards[0])
	set_card_data($B2,GC.PLAYER.build_cards[1])
	$noWorker.visible = (DRAGER.result.BUILD<1)

func check_cards():
	if !"build_cards" in GC.PLAYER: GC.PLAYER["build_cards"] = []
	if GC.PLAYER["build_cards"].size()>=2: return
	$B1.visible = false
	$B2.visible = false
	$Back.visible = false
	if GC.PLAYER["build_cards"].size()<2: GC.PLAYER["build_cards"].append(get_random_card())
	if GC.PLAYER["build_cards"].size()<2: GC.PLAYER["build_cards"].append(get_random_card())
	FM.push_var("games/"+GC.GAME.name+"/players/"+GC.USER.name,"build_cards",GC.PLAYER["build_cards"])
	yield(FM,"complete_push")
	$B1.visible = true
	$B2.visible = true
	$Back.visible = true
	
func get_random_card():
	RECS = ["adobe","stone","gold"]
	var card_data = {"adobe":0,"stone":0,"gold":0}
	for i in range(2+floor(GC.PLAYER.build/2)):
		var key = RECS[ randi() % 3 ]
		card_data[key] += 1
	return card_data

func set_card_data(node,card_data):
	var cost_suficient = true
	for i in card_data:
		var label = node.get_node("HBox/"+i+"/Label")
		var texture = node.get_node("HBox/"+i)
		label.text = ""
		texture.modulate = Color(.3,.3,.3)
		if card_data[i]>0: 
			label.text = "-"+str(card_data[i])
			texture.modulate = Color(1,1,1)
		if card_data[i]>GC.PLAYER[i]: cost_suficient = false
	node.disabled = !cost_suficient
	node.get_node("Label2").text = str(calc_score(card_data))

func calc_score(card_data):
	var score = 0
	var amount = 0
	for i in card_data:
		if i=="adobe": score += card_data[i] * 4
		if i=="stone": score += card_data[i] * 5
		if i=="gold": score += card_data[i] * 6
		amount += card_data[i]
	score -= (amount-2)*4
	score -= 2
	return score

func onBackButton():
	visible = false
	GC.BUILD_TO_CONSTRUCT = null
	DRAGER.free_node_from_stay("BUILD")

func onClickHouse(id):
	print(id)
	GC.BUILD_TO_CONSTRUCT = id
	visible = false
