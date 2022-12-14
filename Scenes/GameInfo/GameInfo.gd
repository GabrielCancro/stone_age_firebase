extends Control

signal on_play

func _ready():
	$Panel/btn_back.connect("button_down",self,"onClickBack")
	$Panel/btn_play.connect("button_down",self,"onClickPlay")
	$Panel/btn_delete.connect("button_down",self,"onClickDelete")
	$Panel/btn_delete.visible = ( GC.GAME.name == GC.OWN_GAME_ID ) 
	set_data()

func set_data_OLD():
	$Panel/Title.text = GC.GAME.name
	$Panel/ScrollInfo/Info.text = "<GAME DATA>\n"
	for k in GC.GAME:
		$Panel/ScrollInfo/Info.text += "  "+k+": "
		if GC.GAME[k] is String: $Panel/ScrollInfo/Info.text += GC.GAME[k]+"\n"
		elif GC.GAME[k] is int: $Panel/ScrollInfo/Info.text += str(GC.GAME[k])+"\n"
		elif GC.GAME[k] is float: $Panel/ScrollInfo/Info.text += str(GC.GAME[k])+"\n"
		elif GC.GAME[k] is bool: $Panel/ScrollInfo/Info.text += str(GC.GAME[k])+"\n"
		else: $Panel/ScrollInfo/Info.text += "[object]\n"
#	$Panel/ScrollInfo/Info.text = JSON.print(GC.GAME, "       ")

func set_data():
	$Panel/Title.text = GC.GAME.name
	var lb = $Panel/ScrollInfo/Info
	lb.text = "INFORMACIÓN DE LA PARTIDA\n"
	lb.text += GC.GAME.gameType+" - "+str(GC.GAME.desc)+" de "+GC.GAME.own+"\n"
	if GC.GAME.is_open: lb.text += "Partida pública\n"
	else: lb.text += "Partida cerrada\n"
	lb.text += "Turnos iniciales: "+str(GC.GAME.init_turns)+"\n"
	lb.text += "Turnos por hora: "+str(GC.GAME.turns_phs)+"\n"
	lb.text += "Turnos totales: "+str(GC.GAME.max_turns)+"\n"
	lb.text += "Espera final: "+str(GC.GAME.final_await)+"hs"+"\n"
	lb.text += "Duración de la partida: "+str(GC.GAME.duration)+"hs"+"\n"
	lb.text += "Jugadores:\n"
	for j in GC.GAME.players: lb.text += "  -"+j+"\n"

func onClickBack():
	queue_free()

func onClickPlay():
	disableAll()
	if (!GC.USER.name in GC.GAME.players):
		GC.GAME.players[GC.USER.name] = GC.get_player_start_config()
		FM.push_data("games/"+GC.GAME.name+"/players/"+GC.USER.name)
		yield(FM,"complete_push")
	GC.PLAYER = GC.GAME.players[GC.USER.name]
	get_tree().change_scene("res://Games/"+GC.GAME.gameType+"/Game.tscn")

func onClickDelete():
	if $Panel/btn_delete.text != "SEGURO?":
		$Panel/btn_delete.text = "SEGURO?"
		return
	$Panel.visible = false
	FM.delete_path("games/"+GC.OWN_GAME_ID)
	yield(FM,"complete_remove")
	get_tree().reload_current_scene()

func disableAll():
	$Panel/btn_back.disabled = true
	$Panel/btn_play.disabled = true
	$Panel/btn_delete.disabled = true
