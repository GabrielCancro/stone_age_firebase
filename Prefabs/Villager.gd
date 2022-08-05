extends Sprite

var can_grab = true
var grabbed_offset = Vector2()
var drag_radius = 30
var draging = false


func _input(event):
	if event is InputEventMouseButton:
		can_grab = event.pressed
		if(get_global_mouse_position().distance_to(position) < drag_radius):
			grabbed_offset = position - get_global_mouse_position()
			GC.DRAGING_ELEMENT = self
		if !event.pressed: GC.DRAGING_ELEMENT = null

func _process(delta):
	pass
