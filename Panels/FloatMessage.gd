extends ColorRect

var MSG_ID = 0

func _ready():
	visible = false

func msg(msg):
	MSG_ID += 1
	var mi_id = MSG_ID
	visible = true
	$Label.text = msg
	yield(get_tree().create_timer(4),"timeout")
	if mi_id==MSG_ID: visible = false
