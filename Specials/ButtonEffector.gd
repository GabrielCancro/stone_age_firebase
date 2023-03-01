extends Node2D

export(Array, String) var paths : Array = []
var nodes = []

func _ready():
	randomize()
	for path in paths: 
		var node = get_parent().get_node_or_null(path)
		if node: nodes.append( node )
	$Timer.connect("timeout",self,"onTime")
	print(paths)
	print(nodes)

func onTime():
	for node in nodes: 
		node.modulate.a = .9+randf()*.2
