extends Node2D

signal finish_end_task

# Called when the node enters the scene tree for the first time.
func _ready():
	$Drager.connect("set_node",self,"onSetNode")

func onSetNode(node,stay,result):
	print(result)
	if result.TOOL>1: $Drager.free_node(node)
	if result.CAMP>1: $Drager.free_node(node)
	if result.HOUSE>2: $Drager.free_node(node)

func end_turn_task():
	var RESULT = $Drager.get_result()
	if RESULT.TOOL == 1: GC.PLAYER.tool += 1
	if RESULT.CAMP == 1: GC.PLAYER.camp += 1
	if RESULT.HOUSE == 2: GC.PLAYER.villager += 1
	if RESULT.FOOD > 0: GC.PLAYER.food += floor(get_dices(RESULT.FOOD)/2)
	if RESULT.WOOD > 0: GC.PLAYER.wood += floor(get_dices(RESULT.WOOD)/3)
	if RESULT.ADOBE > 0: GC.PLAYER.adobe += floor(get_dices(RESULT.ADOBE)/4)
	if RESULT.STONE > 0: GC.PLAYER.stone += floor(get_dices(RESULT.STONE)/5)
	if RESULT.GOLD > 0: GC.PLAYER.gold += floor(get_dices(RESULT.GOLD)/6)
	emit_signal("finish_end_task")

func get_dices(cnt):
	randomize()
	var sum = 0
	for i in range(cnt): sum += randi() % 6 +1
	return sum
