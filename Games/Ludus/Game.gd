extends Node2D

func _ready():
	$Header/btn_quit.connect("button_down",self,"onClick",["quit"])

func onClick(btn):
	if btn == "quit": get_tree().change_scene("res://Scenes/Main.tscn")
