extends Control

func _ready():
	$Tween.interpolate_property($ColorRect,"modulate",Color(1,1,1,1),Color(1,1,1,0),1,Tween.TRANS_LINEAR,Tween.EASE_IN)
	$Tween.start()
	yield(get_tree().create_timer(3),"timeout")
	$Tween.interpolate_property($ColorRect,"modulate",Color(1,1,1,0),Color(1,1,1,1),1,Tween.TRANS_LINEAR,Tween.EASE_IN)
	$Tween.start()
	yield(get_tree().create_timer(2),"timeout")
	get_tree().change_scene("res://Scenes/LoginNew.tscn")
