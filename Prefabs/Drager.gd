extends Node2D

var drag_radius = 30
var grabbed_offset = Vector2()
var drag_node = null
export var origin_pos = Vector2(50,400)
onready var POINTS = get_node("../Points")

func _ready():
	for c in get_children():
		c.position = origin_pos
func _input(event):
	if event is InputEventMouseButton:
		if event.pressed && !drag_node:
			var near = get_children()[0]
			var near_dist = get_global_mouse_position().distance_to(get_children()[0].position)
			for c in get_children():
				if(get_global_mouse_position().distance_to(c.position) < near_dist):
					near = c
					near_dist = get_global_mouse_position().distance_to(c.position)
			if(near_dist < drag_radius):
				drag_node = near
				grabbed_offset = drag_node.position - get_global_mouse_position()
				onStartDrag(drag_node)
		if !event.pressed: 
			if drag_node:
				onFinishDrag(drag_node)
				drag_node = null

func _process(delta):
	if drag_node:
		drag_node.position = drag_node.get_global_mouse_position()

func onStartDrag(node):
	var stay = get_stay(node)
	if stay != "NONE": GC.WORK_VILLAGERS -= 1
	print("START DRAG ",node.name," > ",stay)
	print("WORK_VILLAGERS ",GC.WORK_VILLAGERS)
	
func onFinishDrag(node):
	var stay = get_stay(node)
	if stay == "NONE": node.position = origin_pos
	if stay != "NONE": GC.WORK_VILLAGERS += 1
	print("END DRAG ",node.name," > ",stay)
	print("WORK_VILLAGERS ",GC.WORK_VILLAGERS)

func get_stay(node):
	var stay = "NONE"
	for p in POINTS.get_children():
		if node.position.distance_to(p.position)<p.scale.x*50:
			stay = p.name
	return stay
