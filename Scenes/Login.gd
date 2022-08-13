extends Node2D

func _ready():	
	$LogIn.visible = true
	$NewAccount.visible = false
	$LogIn/VBox/btn_login.connect("button_down",self,"onClick",["login"])
	$LogIn/VBox/btn_new.connect("button_down",self,"onClick",["new"])
	$LogIn/VBox/CheckBox.connect("button_down",self,"onClick",["check"])
	$LogIn/VBox/pass.connect("focus_entered",self,"onClick",["focus_pass"])
	$btn_quit.connect("button_down",self,"onClick",["quit"])
	$NewAccount/VBox/btn_create.connect("button_down",self,"onClick",["create"])
	$NewAccount/btn_back.connect("button_down",self,"onClick",["back"])
	CLOCK.init()
	
	$LogIn.visible = false
	FM.init()
	FM.pull_data()
	yield(FM,"complete_pull")
	if(FM.DATA):
		$LogIn.visible = true
	
	if("remember_user" in StoreData.DATA && StoreData.DATA.remember_user):
		$LogIn/VBox/CheckBox.pressed = true
		$LogIn/VBox/name.text = StoreData.DATA.user_name
		$LogIn/VBox/pass.text = StoreData.DATA.user_pass
		

func onClick(btn):
	print(btn)
	if btn=="new":
		$LogIn.visible = false
		$NewAccount.visible = true
		$NewAccount/Label_error.text = ""
	if btn=="back":
		$LogIn.visible = true
		$NewAccount.visible = false
		$LogIn/Label_error.text = ""
	if btn=="login":
		login()
	if btn=="create":
		createAccount()
	if btn=="quit":
		get_tree().quit()
	if btn=="focus_pass":
		$LogIn/VBox/pass.text = ""
		

func createAccount():
	var user_data = { 
		"name":$NewAccount/VBox/name.text.to_upper(),
		"pass":$NewAccount/VBox/pass.text,
		"mail":$NewAccount/VBox/mail.text,
	}
	if !"users" in FM.DATA: FM.DATA.users = {}
	for u in FM.DATA.users:
		if FM.DATA.users[u].name == user_data.name:
			$NewAccount/Label_error.text = "YA EXISTE "+user_data.name
			return
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
	}
	$LogIn/VBox/pass.text = ""
	if !"users" in FM.DATA: FM.DATA.users = {}
	if !user_data.name in FM.DATA.users:
		$LogIn/Label_error.text = "USUARIO INEXISTENTE"
	else:
		if FM.DATA.users[user_data.name].pass == user_data.pass:
			GC.USER = FM.DATA.users[user_data.name]
			get_tree().change_scene("res://Scenes/Main.tscn")
			StoreData.DATA["remember_user"] = $LogIn/VBox/CheckBox.pressed
			StoreData.DATA["user_name"] = user_data.name
			StoreData.DATA["user_pass"] = user_data.pass
			StoreData.save_store_data()
			print("TE LOGUEASTE COMO >> ",GC.USER)
		else:
			$LogIn/Label_error.text = "CLAVE INCORRECTA"
