extends Control

func _ready():
	$Background/AnimationPlayer.play("wood")
	$btn_account.connect("button_down",self,"onClickAccount")
	$btn_exit.connect("button_down",self,"onClickExit")
	$btn_remember.connect("button_down",self,"onRememberClick")
	checkRemember()

func onClickAccount():
	get_tree().change_scene("res://Scenes/CreateAccount.tscn")

func onClickExit():
	get_tree().quit()

func onRememberClick():
	$btn_remember/lb_X.visible = !$btn_remember/lb_X.visible
	StoreData.DATA["remember_user"] = $btn_remember/lb_X.visible
	checkRemember()

func checkRemember():
	$btn_remember/lb_X.visible = false
	if("remember_user" in StoreData.DATA && StoreData.DATA.remember_user):
		$btn_remember/lb_X.visible = true
		$Input_name/LineEdit.text = StoreData.DATA.user_name
		$Input_pass/LineEdit.text = StoreData.DATA.user_pass
#		if("muted" in StoreData.DATA): $LogIn/Mute.pressed = StoreData.DATA.muted
