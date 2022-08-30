extends Node

var pjs = { 
	"M":{"hp":50,"atk":20,"res":0,"def_filo":20,"def_perf":20,"def_ap":20,"agi":0},
	"E":0,
	"Y":0,
	"L":0,
	"B":0 
}
var rounds = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	for i in range(7): new_round()
	print(pjs)

func new_round():
	rounds += 1
	print("--RAUND ",rounds)
	var hits = pjs.keys()
	for p in pjs.keys():
		var e = hits[ randi()%hits.size() ]
		for i in range(10): if p==e: e = hits[ randi()%hits.size() ]
		print(p,"->",e)
		pjs[e] -= 1
		hits.erase(e)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
