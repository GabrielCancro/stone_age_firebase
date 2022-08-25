extends Panel

signal close()
var CODE
var selectedUser

func _ready():
	$btn_back.connect("button_down",self,"onButtonClick",["back"])
	$VBox/btn_send_code.connect("button_down",self,"onButtonClick",["send_code"])
	$VBox/btn_change_pass.connect("button_down",self,"onButtonClick",["change_pass"])
	visible = false

func onButtonClick(code):
	if code=="back":
		visible = false
		emit_signal("close")
	if code=="send_code":
		send_code()
	if code=="change_pass":
		change_pass()
		
func showForgotPanel():
	visible = true
	selectedUser = null
	$VBox/name.text = ""
	$VBox/code.text = ""
	$VBox/pass.text = ""
	$VBox/btn_send_code.disabled = false
	randomize()
	CODE = randi()%9000+1000

func send_code():
	var userName = $VBox/name.text
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
	get_parent().show_float_message(selectedUser+" enviamos un mail a "+FM.DATA.users[selectedUser].mail+" con el CODIGO SECRETO que necesitas")
	get_node("../MailSender").send(CODE,FM.DATA.users[selectedUser].mail)
	$VBox/btn_send_code.disabled = true

func change_pass():
	if !selectedUser:
		get_parent().show_float_message("DEBE ESCRIBIR SU NOMBRE DE USUARIO O MAIL")
		return
	if $VBox/code.text != str(CODE):
		get_parent().show_float_message("EL CODIGO SECRETO ES INCORRECTO!")
		return
	if $VBox/pass.text == "":
		get_parent().show_float_message("ESCRIBA SU NUEVA CONTRASEÑA!")
		return
	if $VBox/pass.text.length() <= 3:
		get_parent().show_float_message("SU CLAVE ES DEMASIADO CORTA")
		return
	$VBox/btn_change_pass.disabled = true
	FM.DATA.users[selectedUser].mpass = $VBox/pass.text.md5_text()
	FM.push_data("users/"+selectedUser)
	yield(FM,"complete_push")
	get_tree().reload_current_scene()
