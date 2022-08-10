extends ColorRect

func _ready():
	visible=false
	get_node("../BuildButton").connect("button_down",self,"onShowButton")
	$Back.connect("button_down",self,"onBackButton")
	$B1.connect("button_down",self,"onClickHouse",[1])
	$B2.connect("button_down",self,"onClickHouse",[2])

func onShowButton():
	visible = true

func onBackButton():
	visible = false

func onClickHouse(id):
	print(id)
