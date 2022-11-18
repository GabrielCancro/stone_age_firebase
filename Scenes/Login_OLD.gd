extends Node2D

var CODE = 0
var MSG_ID = 0

func _ready():
	$LogIn.visible = true
	$NewAccount.visible = false
	$LogIn/btn_login.connect("button_down",self,"onClick",["login"])
	$LogIn/btn_new.connect("button_down",self,"onClick",["new"])
	$LogIn/btn_forgot.connect("button_down",self,"onClick",["forgot"])
	$LogIn/VBox/CheckBox.connect("button_down",self,"onClick",["check"])
	$LogIn/VBox/pass.connect("focus_entered",self,"onClick",["focus_pass"])
	$LogIn/btn_quit.connect("button_down",self,"onClick",["quit"])
	$RequireUpdate/btn_quit.connect("button_down",self,"onClick",["quit"])
	$NewAccount/VBox/btn_create.connect("button_down",self,"onClick",["NewAccount","create"])
	$NewAccount/btn_back.connect("button_down",self,"onClick",["NewAccount","back"])
	$NewAccount/VBox/code/btn_create.connect("button_down",self,"onClick",["NewAccount","send_code"])
	$ForgotPanel.connect("close",self,"onClick",["show_login"])
	$Changelog/btn_ok.connect("button_down",self,"onClick",["changelog"])
	$btn_version.connect("button_down",self,"onClick",["version"])
	$NinePatchRect/btn_login2.connect("button_down",self,"onClick",["loginNew"])
	CLOCK.init()
	$Changelog.visible = false
	$btn_version.text = GC.get_version_str()
	$LogIn.visible = false
	FM.init()
	FM.pull_data()
	yield(FM,"complete_pull")
	if(FM.DATA):
		if(FM.DATA.min_version_required > GC.version):
			$RequireUpdate.visible = true
			$RequireUpdate/Label_ver.text = "\nsu versión es: "+GC.get_version_str() 
			$RequireUpdate/Label_ver.text += "\nse requiere: "+GC.get_version_str(FM.DATA.min_version_required) 
		$LogIn.visible = true
	
	if("remember_user" in StoreData.DATA && StoreData.DATA.remember_user):
		$LogIn/VBox/CheckBox.pressed = true
		$LogIn/VBox/name.text = StoreData.DATA.user_name
		$LogIn/VBox/pass.text = StoreData.DATA.user_pass
		if("muted" in StoreData.DATA): $LogIn/Mute.pressed = StoreData.DATA.muted
	
	if(!"changelog_showed" in StoreData.DATA || StoreData.DATA.changelog_showed != GC.get_version_str()):
		StoreData.DATA.changelog_showed = GC.get_version_str()
		$Changelog.visible = true
		$Changelog/Label_title.text = "CHANGELOG "+GC.get_version_str()

func onClick(btn,sub=""):
	print(btn)
	if btn=="new":
		$LogIn.visible = false
		$NewAccount.visible = true
		$NewAccount/code_message.visible = false
		$NewAccount/VBox/code/btn_create.disabled = false
		$NewAccount/Label_error.text = ""
	if btn=="forgot":
		$LogIn.visible = false
		$ForgotPanel.showForgotPanel()
	if btn=="show_login":
		$LogIn.visible = true
	if btn=="NewAccount":
		if sub=="back":
			$LogIn.visible = true
			$NewAccount.visible = false
			$LogIn/Label_error.text = ""
		if sub=="create":
			createAccount()
		if sub=="send_code":
			if $NewAccount/VBox/mail.text=="": 
				show_float_message("FALTA UN MAIL")
				return
			for user in FM.DATA.users:
				if $NewAccount/VBox/mail.text==FM.DATA.users[user].mail: 
					show_float_message("ESE MAIL YA ESTA REGISTRADO!")
					return
			$NewAccount/VBox/code/btn_create.disabled = true
			randomize()
			CODE = randi()%9000+1000
			$MailSender.send(CODE,$NewAccount/VBox/mail.text)
			$NewAccount/code_message.visible = true
	if btn=="login":
		login()
	if btn=="quit":
		get_tree().quit()
	if btn=="focus_pass":
		$LogIn/VBox/pass.text = ""
	if btn=="changelog":
		$Changelog.visible = false
	if btn=="version":
		$Changelog.visible = true
		$Changelog/Label_title.text = "CHANGELOG "+GC.get_version_str()
	if btn=="loginNew":
		get_tree().change_scene("res://Scenes/LoginNew.tscn")
		

func createAccount():
	var user_data = { 
		"name":$NewAccount/VBox/name.text.to_upper(),
		"pass":$NewAccount/VBox/pass.text,
		"mpass":$NewAccount/VBox/pass.text.md5_text(),
		"mail":$NewAccount/VBox/mail.text,
		"code":$NewAccount/VBox/code.text,
	}
	if user_data.name=="": 
		show_float_message("FALTA UN NOMBRE")
		return
	if user_data.pass in FM.DATA.users: 
		show_float_message("FALTA UNA CLAVE")
		return
	if user_data.mail=="": 
		show_float_message("FALTA UN MAIL")
		return
	if user_data.code=="": 
		show_float_message("DEBES ESCRIBIR EL CODIGO SECRETO")
		return
	if str(CODE) != $NewAccount/VBox/code.text:
		show_float_message("CODIGO SECRETO INCORRECTO")
		return
	for u in FM.DATA.users:
		if FM.DATA.users[u].name == user_data.name:
			show_float_message("ESE USUARIO YA EXISTE!!!")
			return
	user_data.erase("pass")
	user_data.erase("code")
	FM.DATA.users[user_data.name] = user_data
	FM.push_data("users/"+user_data.name)
	$LogIn.visible = true
	$NewAccount.visible = false
	$LogIn/VBox/name.text = user_data.name
	$LogIn/VBox/pass.text = ""
	$LogIn/Label_error.text = ""
	
func login():
	var user_data = { 
		"name":$LogIn/VBox/name.text.to_upper(),
		"pass":$LogIn/VBox/pass.text,
		"mpass":$LogIn/VBox/pass.text.md5_text(),
	}
	$LogIn/VBox/pass.text = ""
	print("MD5 ",user_data.mpass)
	if !"users" in FM.DATA: FM.DATA.users = {}
	if !user_data.name in FM.DATA.users:
		$LogIn/Label_error.text = "USUARIO INEXISTENTE"
	else:
		if FM.DATA.users[user_data.name].mpass == user_data.mpass:
			GC.USER = FM.DATA.users[user_data.name]
			get_tree().change_scene("res://Scenes/Main.tscn")
			StoreData.DATA["remember_user"] = $LogIn/VBox/CheckBox.pressed
			StoreData.DATA["user_name"] = user_data.name
			StoreData.DATA["user_pass"] = user_data.pass
			StoreData.DATA["muted"] = $LogIn/Mute.pressed
			StoreData.save_store_data()
			print("TE LOGUEASTE COMO >> ",GC.USER)
		else:
			$LogIn/Label_error.text = "CLAVE INCORRECTA"

func show_float_message(msg):
	MSG_ID += 1
	var mi_id = MSG_ID
	$float_message.visible = true
	$float_message/Label.text = msg
	yield(get_tree().create_timer(4),"timeout")
	if mi_id==MSG_ID: $float_message.visible = false
