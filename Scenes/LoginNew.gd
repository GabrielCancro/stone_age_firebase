extends Control

func _ready():	
	$Tween/ColorRect.visible = true
	$Background/AnimationPlayer.play("wood")
	$btn_account.connect("button_down",self,"onClickAccount")
	$btn_forgot.connect("button_down",self,"onClickForgot")
	$btn_exit.connect("button_down",self,"onClickExit")
	$btn_remember.connect("button_down",self,"onRememberClick")
	$btn_enter.connect("button_down",self,"onEnterClick")

	CLOCK.init()
	FM.init()
	FM.pull_users()
	yield(FM,"complete_pull")
#	print("USERS",FM.USERS)
	FM.pull_data()
	yield(FM,"complete_pull")
	checkRemember()
	checkOldVersion()
	fadeOutBlackScreen()


func onClickAccount():
	OS.shell_open("https://bearmolegames.web.app")
#	get_tree().change_scene("res://Scenes/CreateAccount.tscn")

func onClickForgot():
	OS.shell_open("https://bearmolegames.web.app")
	#get_tree().change_scene("res://Scenes/ForgotPassword.tscn")

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
	$btn_enter.visible = false
	var user_data = { 
		"name":$Input_name/LineEdit.text.to_upper(),
		"pass":$Input_pass/LineEdit.text,
		"mpass":$Input_pass/LineEdit.text.md5_text(),
	}
	FM.login(user_data.name,user_data.pass)
	var res = yield(FM,"complete_login")
	print("END LOGIN ",res)
	if !res.success:
		$Input_pass/LineEdit.text = ""
		$FloatMessage.msg("ERROR "+res.error.code)
	else:
		if !res.user.email_verified: 
			$FloatMessage.msg("Aún no has verificado tu cuenta!")
		else: 
			GC.USER = FM.DATA.users[user_data.name]
			StoreData.DATA["remember_user"] = $btn_remember/lb_X.visible
			StoreData.DATA["user_name"] = user_data.name
			StoreData.DATA["user_pass"] = user_data.pass
			StoreData.DATA["muted"] = false #$LogIn/Mute.pressed
			StoreData.save_store_data()
			print("TE LOGUEASTE COMO >> ",GC.USER)
			get_tree().change_scene("res://Scenes/Main.tscn")
	$btn_enter.visible = true

func fadeOutBlackScreen():
	$Tween.interpolate_property($Tween/ColorRect,"modulate",Color(1,1,1,1),Color(1,1,1,0),.5,Tween.TRANS_LINEAR,Tween.EASE_IN)
	$Tween.start()
	yield($Tween,"tween_all_completed")
	$Tween/ColorRect.visible = false
