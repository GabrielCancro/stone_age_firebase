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
	RECS = ["wood","adobe","stone","gold"]
	var card = []
	var last = 0
	for i in range(3):
		if last == 3: break
		var index = last + randi()%(4-last)
		card.append( RECS[index] )
		last = index
	if(card.size()==1): card.append("gold")
	return card

func set_card_data(card,data):
	var recs = {"wood":0,"adobe":0, "stone":0, "gold":0}
	for i in range(3):
		var cld = card.get_node("HBox").get_children()[i]
		cld.visible = i < data.size()
		if cld.visible: 
			cld.texture = load("res://assets/"+data[i]+".jpg")
			recs[data[i]] += 1
	var cost_suficient = true
	for r in recs: if GC.PLAYER[r]<recs[r]: cost_suficient = false
	card.disabled = !cost_suficient
	card.get_node("Label2").text = str(calc_score(data))

func calc_score(data):
	var score = 0
	for i in range(data.size()): score += RECS.find(data[i])+3
	return score

func onBackButton():
	visible = false
	GC.BUILD_TO_CONSTRUCT = null
	DRAGER.free_node_from_stay("BUILD")

func onClickHouse(id):
	print(id)
	GC.BUILD_TO_CONSTRUCT = id
	visible = false
