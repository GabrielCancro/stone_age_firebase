extends Node2D


func _ready():
	$Header/Label.text = GC.USER.name +" <"+GC.GAME.name+">"
	$Header/btn_quit.connect("button_down",self,"onClick",["quit"])

func onClick(btn):
	if btn == "quit": get_tree().change_scene("res://Scenes/Main.tscn")
	
