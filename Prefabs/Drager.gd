extends Node2D

var drag_radius = 30
var grabbed_offset = Vector2()
var drag_node = null
onready var max_nodes = $Nodes.get_children().size()
var result = {}
signal set_node(node,stay,result)

func _ready():	
	for c in $Nodes.get_children():
		c.position = $Base.position
	for p in $Points.get_children(): result[p.name] = 0
	result["NONE"] = max_nodes
	print("DRAGER POINTS >> ",result)
	update_label()

func _input(event):
	if event is InputEventMouseButton:
		if event.pressed && !drag_node:
			var near = $Nodes.get_children()[0]
			var near_dist = get_global_mouse_position().distance_to($Nodes.get_children()[0].position)
			for c in $Nodes.get_children():
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
	result[stay] -= 1
	node.z_index = 2
	update_label()
	
func onFinishDrag(node):
	var stay = get_stay(node)
	if stay == "NONE": node.position = $Base.position
	result[stay] += 1
	node.z_index = 0
	update_label()
	emit_signal("set_node",node,stay,result)	

func get_stay(node):
	var stay = "NONE"
	for p in $Points.get_children():
		if node.position.distance_to(p.position)<p.scale.x*50:
			stay = p.name
			break
	return stay

func update_label():
	$Base/Label.text = str(result["NONE"])+"/"+str(max_nodes)

#PUBLICS
func free_node(node):
	onStartDrag(node)
	node.position = $Base.position
	onFinishDrag(node)

func get_result():
	return result
