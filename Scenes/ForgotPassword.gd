extends Control

signal close()
var CODE
var selectedUser
var MSG_ID = 0

func _ready():
	$float_message.visible = false
	$ForgotPanel/btn_back.connect("button_down",self,"onButtonClick",["back"])
	$ForgotPanel/VBox/btn_send_code.connect("button_down",self,"onButtonClick",["send_code"])
	$ForgotPanel/VBox/btn_change_pass.connect("button_down",self,"onButtonClick",["change_pass"])
	show_float_message("ESTE PANEL ESTA EN DESARROLLO, DISCULPE!")

func onButtonClick(code):
	if code=="back":
		get_tree().change_scene("res://Scenes/LoginNew.tscn")
	if code=="send_code":
		send_code()
	if code=="change_pass":
		change_pass()
		
func showForgotPanel():
	visible = true
	selectedUser = null
	$ForgotPanel/VBox/name.text = ""
	$ForgotPanel/VBox/code.text = ""
	$ForgotPanel/VBox/pass.text = ""
	$ForgotPanel/VBox/btn_send_code.disabled = false
	randomize()
	CODE = randi()%9000+1000

func send_code():
	var userName = $ForgotPanel/VBox/name.text
	var is_mail = false
	for user in FM.DATA.users.keys():
		if userName.to_upper() == user: 
			selectedUser = user
			break
		elif userName == FM.DATA.users[user].mail: 
			selectedUser = user
			is_mail = true
			break
	if !selectedUser:
		get_parent().show_float_message("NO SE ENCONTRO EL USUARIO/MAIL\n"+userName)
		return
	show_float_message(selectedUser+" enviamos un mail a "+FM.DATA.users[selectedUser].mail+" con el CODIGO SECRETO que necesitas")
	get_node("MailSender").send(CODE,FM.DATA.users[selectedUser].mail)
	$ForgotPanel/VBox/btn_send_code.disabled = true

func change_pass():
	if !selectedUser:
		get_parent().show_float_message("DEBE ESCRIBIR SU NOMBRE DE USUARIO O MAIL")
		return
	if $ForgotPanel/VBox/code.text != str(CODE):
		get_parent().show_float_message("EL CODIGO SECRETO ES INCORRECTO!")
		return
	if $ForgotPanel/VBox/pass.text == "":
		get_parent().show_float_message("ESCRIBA SU NUEVA CONTRASEÑA!")
		return
	if $ForgotPanel/VBox/pass.text.length() <= 3:
		get_parent().show_float_message("SU CLAVE ES DEMASIADO CORTA")
		return
	$ForgotPanel/VBox/btn_change_pass.disabled = true
	FM.DATA.users[selectedUser].mpass = $ForgotPanel/VBox/pass.text.md5_text()
	FM.push_data("users/"+selectedUser)
	yield(FM,"complete_push")
	get_tree().reload_current_scene()

func show_float_message(msg):
	MSG_ID += 1
	var mi_id = MSG_ID
	$float_message.visible = true
	$float_message/Label.text = msg
	yield(get_tree().create_timer(4),"timeout")
	if mi_id==MSG_ID: $float_message.visible = false
