extends ColorRect

func _ready():
	$Button.connect("button_down",self,"onClickOk")

func showHelp(page):
	visible = true
	for p in $Pages.get_children(): p.visible = false
	$Pages.get_node(page).visible = true

func onClickOk():
	visible = false
