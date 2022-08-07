extends Node2D

signal finish_end_task
signal finish_current_anim
# Called when the node enters the scene tree for the first time.
func _ready():
	$Drager.connect("set_node",self,"onSetNode")

func onSetNode(node,stay,result):
	print(result)
	if result.TOOL>1: $Drager.free_node(node)
	if result.CAMP>1: $Drager.free_node(node)
	if result.VILLAGER>2: $Drager.free_node(node)

func end_turn_task():
	var RESULT = $Drager.get_result()
	print("RESUTL")
	print(RESULT)
	print("__________________________________")
	if RESULT.FOOD > 0: 
		add_resource("FOOD", floor(get_dices(RESULT.FOOD)/2) )
		yield(self,"finish_current_anim")
	if RESULT.WOOD > 0:
		add_resource("WOOD", floor(get_dices(RESULT.WOOD)/3) )
		yield(self,"finish_current_anim")
	if RESULT.ADOBE > 0: 
		add_resource("ADOBE", floor(get_dices(RESULT.ADOBE)/4) )
		yield(self,"finish_current_anim")
	if RESULT.STONE > 0: 
		add_resource("STONE", floor(get_dices(RESULT.STONE)/5) )
		yield(self,"finish_current_anim")
	if RESULT.GOLD > 0: 
		add_resource("GOLD", floor(get_dices(RESULT.GOLD)/6) )
		yield(self,"finish_current_anim")
	if RESULT.TOOL == 1: 
		add_resource("TOOL",1)
		yield(self,"finish_current_anim")
	if RESULT.CAMP == 1: 
		add_resource("CAMP",1)
		yield(self,"finish_current_anim")
	if RESULT.VILLAGER == 2: 
		add_resource("VILLAGER",1)
		$Drager.add_max(1)
		yield(self,"finish_current_anim")
	yield(get_tree().create_timer(1),"timeout")
	emit_signal("finish_end_task")

func add_resource(name,cnt):
	var nameLow = name.to_lower()
	if !nameLow in GC.PLAYER: GC.PLAYER[nameLow] = 0
	GC.PLAYER[nameLow] += cnt
	fx_text("+"+str(cnt),$Drager/Points.get_node(name).position)
	$rec_panel.update_panel()
	
func fx_text(txt,pos):
	$fx.text = txt
	$fx.rect_position = pos + Vector2(-100,-30)
	$Tween.interpolate_property($fx,"modulate",Color(1,1,1,1),Color(1,1,1,0),1.0,Tween.TRANS_QUAD,Tween.EASE_OUT)
	$Tween.interpolate_property($fx,"rect_position",$fx.rect_position,$fx.rect_position+Vector2(0,-50),1.0,Tween.TRANS_QUAD,Tween.EASE_OUT)
	$Tween.start()
	yield($Tween,"tween_completed")
	yield(get_tree().create_timer(.1),"timeout")
	emit_signal("finish_current_anim")

func get_dices(cnt):
	randomize()
	var sum = 0
	for i in range(cnt): sum += randi() % 6 +1
	return sum
