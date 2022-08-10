extends ColorRect

var current_villager_node = null
onready var DRAGER = get_node("../Interaction/Drager")

func _ready():
	visible=false
	$Back.connect("button_down",self,"onBackButton")
	$B1.connect("button_down",self,"onClickHouse",[1])
	$B2.connect("button_down",self,"onClickHouse",[2])
	DRAGER.connect("set_node",self,"onDragHouse")

func onShowButton():
	visible = true

func onBackButton():
	visible = false
	DRAGER.free_node(current_villager_node)
	current_villager_node = null

func onClickHouse(id):
	print(id)
	visible = false

func onDragHouse(node,stay,result):
	if result.BUILD>1: DRAGER.free_node(node)
	elif stay == "BUILD": 
		visible = true
		current_villager_node = node
