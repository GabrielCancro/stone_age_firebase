extends Sprite

var RECS = ["wood","wood","stone"]

func _ready():
	set_recs()

func set_recs():
	for i in range(3):
		var cld = $HBox.get_children()[i]
		cld.visible = i < RECS.size()
		if cld.visible: cld.texture = load("res://assets/"+RECS[i]+".jpg")
