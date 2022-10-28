extends Control

var CODE = 0
var MSG_ID = 0

func _ready():
	$float_message.visible = false
	$NewAccount/btn_back.connect("button_down",self,"onBackClick")
	$NewAccount/VBox/btn_create.connect("button_down",self,"onCreateClick")
	$NewAccount/VBox/code/btn_code.connect("button_down",self,"onCodeClick")
	randomize()
	CODE = randi()%9000+1000

func onBackClick():
	get_tree().change_scene("res://Scenes/LoginNew.tscn")

func onCreateClick():
	createAccount()

func onCodeClick():
	if $NewAccount/VBox/mail.text=="": 
		show_float_message("FALTA UN MAIL")
		return
	for user in FM.DATA.users:
		if $NewAccount/VBox/mail.text==FM.DATA.users[user].mail: 
			show_float_message("ESE MAIL YA ESTA REGISTRADO!")
			return
	$NewAccount/VBox/code/btn_code.disabled = true
	$MailSender.send(CODE,$NewAccount/VBox/mail.text)
	show_float_message("HEMOS ENVIADO SU CODIGO SECRETO A SU MAIL!!")

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
	for u in FM.DATA.users:
		if FM.DATA.users[u].name == user_data.name:
			show_float_message("ESE USUARIO YA EXISTE!!!")
			return
	if user_data.pass=="": 
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
	user_data.erase("pass")
	user_data.erase("code")
	FM.DATA.users[user_data.name] = user_data
	FM.push_data("users/"+user_data.name)
	get_tree().change_scene("res://Scenes/LoginNew.tscn")

func show_float_message(msg):
	MSG_ID += 1
	var mi_id = MSG_ID
	$float_message.visible = true
	$float_message/Label.text = msg
	yield(get_tree().create_timer(4),"timeout")
	if mi_id==MSG_ID: $float_message.visible = false
