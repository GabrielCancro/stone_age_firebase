extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	showFriendList()
	$Title/btn_cancel.connect("button_down",self,"onCancelClick")

func showFriendList():
	if !"friends" in GC.USER: GC.USER["friends"] = []
	for chk in $Panel/PlayerList/Scroll/VBox.get_children(): chk.queue_free()
	for f in GC.USER["friends"]:
		var chk = CheckBox.new()
		chk.text = f
		$Panel/PlayerList/Scroll/VBox.add_child(chk)

func onCancelClick():
	get_tree().change_scene("res://Scenes/Main.tscn")
