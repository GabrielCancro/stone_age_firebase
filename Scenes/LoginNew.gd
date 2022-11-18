extends Control

func _ready():
	$Background/AnimationPlayer.play("wood")
	$btn_account.connect("button_down",self,"onClickAccount")
	$btn_exit.connect("button_down",self,"onClickExit")
	$btn_remember.connect("button_down",self,"onRememberClick")
	$btn_enter.connect("button_down",self,"onEnterClick")

	CLOCK.init()
	FM.init()
	FM.pull_data()
	yield(FM,"complete_pull")
	checkRemember()
	checkOldVersion()


func onClickAccount():
	get_tree().change_scene("res://Scenes/CreateAccount.tscn")

func onClickExit():
	get_tree().quit()

func onRememberClick():
	$btn_remember/lb_X.visible = !$btn_remember/lb_X.visible
	StoreData.DATA["remember_user"] = $btn_remember/lb_X.visible
	checkRemember()

func checkOldVersion():
	if(FM.DATA && FM.DATA.min_version_required > GC.version):
		print("YOU HAVE A OLD VERSION!!! UPDATE PLEASE!")
#		$RequireUpdate.visible = true
#		$RequireUpdate/Label_ver.text = "\nsu versión es: "+GC.get_version_str() 
#		$RequireUpdate/Label_ver.text += "\nse requiere: "+GC.get_version_str(FM.DATA.min_version_required) 

func checkRemember():
	$btn_remember/lb_X.visible = false
	if("remember_user" in StoreData.DATA && StoreData.DATA.remember_user):
		$btn_remember/lb_X.visible = true
		$Input_name/LineEdit.text = StoreData.DATA.user_name
		$Input_pass/LineEdit.text = StoreData.DATA.user_pass
#		if("muted" in StoreData.DATA): $LogIn/Mute.pressed = StoreData.DATA.muted

func onEnterClick():
	var user_data = { 
		"name":$Input_name/LineEdit.text.to_upper(),
		"pass":$Input_pass/LineEdit.text,
		"mpass":$Input_pass/LineEdit.text.md5_text(),
	}
	$Input_pass/LineEdit.text = ""
	if !"users" in FM.DATA: FM.DATA.users = {}
	if !user_data.name in FM.DATA.users:
#		$LogIn/Label_error.text = "USUARIO INEXISTENTE"
		pass
	else:
		if FM.DATA.users[user_data.name].mpass == user_data.mpass:
			GC.USER = FM.DATA.users[user_data.name]
			StoreData.DATA["remember_user"] = $btn_remember/lb_X.visible
			StoreData.DATA["user_name"] = user_data.name
			StoreData.DATA["user_pass"] = user_data.pass
			StoreData.DATA["muted"] = false #$LogIn/Mute.pressed
			StoreData.save_store_data()
			print("TE LOGUEASTE COMO >> ",GC.USER)
			get_tree().change_scene("res://Scenes/Main.tscn")
		else:
#			$LogIn/Label_error.text = "CLAVE INCORRECTA"
			pass
