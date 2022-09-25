extends Node2D

var drag_radius = 30
var grabbed_offset = Vector2()
var drag_node = null
onready var max_nodes = GC.PLAYER.villager
var result = {}
signal set_node(node,stay,result)
var disabled = false

func _ready():
	for c in $Nodes.get_children():
		c.position = $Base.position
	for p in $Points.get_children(): 
		result[p.name] = 0
	result["NONE"] = max_nodes
	print("DRAGER POINTS >> ",result)
	update_label()

func _input(event):
	if disabled: return
	if get_node("../../BuildPanel").visible || get_node("../../CivPanel").visible: return
	if get_node("../../EndPanel").visible || get_node("../../HelpPanel").visible: return
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
				GC.SOUND.play_villager()
				drag_node = null

func _process(delta):
	if drag_node:
		drag_node.position = drag_node.get_global_mouse_position()

func onStartDrag(node):
	var stay = get_stay(node)
	if stay=="NONE" && result["NONE"]<=0: 
		drag_node = null
		return
	result[stay] -= 1
	node.z_index = 2
	update_label()
	$Points.visible = true
	
func onFinishDrag(node):
	var stay = get_stay(node)
	if stay == "NONE": 
		$Tween.interpolate_property(node,"position",node.position,$Base.position,.3,Tween.TRANS_QUAD,Tween.EASE_OUT)
		$Tween.start()
	result[stay] += 1
	node.z_index = 0
	update_label()
	$Points.visible = false
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
	$Tween.interpolate_property(node,"position",node.position,$Base.position,.3,Tween.TRANS_QUAD,Tween.EASE_OUT)
	$Tween.start()
	yield($Tween,"tween_completed")
	onFinishDrag(node)

func add_max(cnt=1):
	max_nodes += cnt
	result["NONE"] += cnt
	update_label()

func get_result():
	return result

func free_node_from_stay(stay):
	for node in $Nodes.get_children():
		if get_stay(node)==stay: 
			free_node(node)
			yield(get_tree().create_timer(.1),"timeout")

func consume_node_from_stay(stay):
	for node in $Nodes.get_children():
		if get_stay(node)==stay:
			$Tween.interpolate_property(node,"modulate",Color(1,1,1,1),Color(1,1,1,0),.3,Tween.TRANS_QUAD,Tween.EASE_OUT)
			$Tween.start()
			yield($Tween,"tween_completed")
			max_nodes -= 1
			result[stay] -= 1
			update_label()
			node.position = $Base.position
			node.modulate = Color(1,1,1,1)

func get_worker_positions():
	var pos = []
	for node in $Nodes.get_children():
		if(node.get_index()>=GC.PLAYER.villager): break
		pos.append({"x":node.position.x,"y":node.position.y})
	return pos

func set_worker_positions(pos):
	yield(get_tree().create_timer(.1),"timeout")
	for node in $Nodes.get_children():
		if(node.get_index()>=pos.size()): break		
		onStartDrag(node)
		var vPos = Vector2(pos[node.get_index()].x,pos[node.get_index()].y)
		$Tween.interpolate_property(node,"position",node.position,vPos,.1,Tween.TRANS_QUAD,Tween.EASE_OUT)
		$Tween.start()
		yield(get_tree().create_timer(.1),"timeout")
		onFinishDrag(node)
