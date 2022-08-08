extends Node2D

func _ready():
	FM.init()
	$LogIn.visible = true
	$NewAccount.visible = false
	$LogIn/VBox/btn_login.connect("button_down",self,"onClick",["login"])
	$LogIn/VBox/btn_new.connect("button_down",self,"onClick",["new"])
	$NewAccount/VBox/btn_create.connect("button_down",self,"onClick",["create"])
	$NewAccount/btn_back.connect("button_down",self,"onClick",["back"])
	CLOCK.init()
#	var time = yield( CLOCK.get_time(),"complete" )
#	print( "TIME: ", time)

func onClick(btn):
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
			print("TE LOGUEASTE COMO >> ",GC.USER)
		else:
			$LogIn/Label_error.text = "CLAVE INCORRECTA"
