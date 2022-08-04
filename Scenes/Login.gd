extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	FM.get_data("")
	var data = yield(FM,"complete")
	print( "data of stone_age_fb" );
	print( data );
	
