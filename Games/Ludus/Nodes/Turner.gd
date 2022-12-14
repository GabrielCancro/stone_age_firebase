extends Panel

onready var Actions = get_node("../Actions")
onready var Chars = get_node("../Chars")
onready var Equip = get_node("../Equip")


# Called when the node enters the scene tree for the first time.
func _ready():
	$Button.connect("button_down",self,"onEndTurn")
	$ButtonBattle.connect("button_down",get_node("../Battle"),"show_battle")

func onEndTurn():
	$Button.disabled = true
	var result = Actions.get_settings()
	for ch in result.keys():
		if(int(result[ch])<=0):continue
		Chars.add_char(ch,int(result[ch]))
		yield(get_tree().create_timer(1.7),"timeout")
	$Button.disabled = false

