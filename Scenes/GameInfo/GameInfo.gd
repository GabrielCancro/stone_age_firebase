extends Control

signal on_play

func _ready():
	$Panel/btn_back.connect("button_down",self,"onClickBack")
	$Panel/btn_play.connect("button_down",self,"onClickPlay")
	$Panel/btn_delete.connect("button_down",self,"onClickDelete")
	$Panel/btn_delete.visible = ( GC.GAME.name == GC.OWN_GAME_ID ) 
	set_data()

func set_data():
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

func onClickBack():
	queue_free()

func onClickPlay():
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
