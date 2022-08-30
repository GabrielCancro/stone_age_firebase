extends Node2D

var Gladio = preload("res://Games/Ludus/nodes/Gladio.tscn")
var cnt = 5

# Called when the node enters the scene tree for the first time.
func _ready():
	var dist = 80 + cnt*8
	$Gladio.queue_free()
	for i in range(cnt):
		var gl = Gladio.instance(cnt)
		gl.position = Vector2(dist*cos(i*PI*2/cnt),dist*.5*sin(i*PI*2/cnt))
		if gl.position.x>0: gl.scale.x *= -1 
		add_child(gl)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
