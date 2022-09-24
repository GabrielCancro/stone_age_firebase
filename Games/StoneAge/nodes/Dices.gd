extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	visible = false
	get_parent().get_node("btn_dice4").connect("button_down",self,"roll_dices",[])
#	for i in range(10):
#		roll_dices(6)
#		yield(get_tree().create_timer(5),"timeout")

func roll_dices(cnt=0):
	if cnt==0: cnt = 3+randi()%6
	var values = []
	var total = 0
	for d in get_children():
		var i = d.get_index()
		d.visible = (i<cnt)
		if d.visible:
			var rnd = randi()%6+1
			values.append(rnd)
			total += rnd
			d.position.x = sin(PI/2-PI/(cnt-1)*(i))*80
			d.position.y = cos(PI/2-PI/(cnt-1)*(i))*50
			roll_one_dice(d,values[i])
	print("TOTAL: ",total)
	show_total(total)
	visible = true
	return total

func roll_one_dice(dice,value):
	dice.playing = true
	yield(get_tree().create_timer(1+randf()),"timeout")
	dice.playing = false
	dice.frame = int(value*3-1)
	print(value," f:",dice.frame)

func show_total(total):
	get_parent().get_node("btn_dice4").text = "???"
	yield(get_tree().create_timer(2.1),"timeout")
	get_parent().get_node("btn_dice4").text = str(total)
