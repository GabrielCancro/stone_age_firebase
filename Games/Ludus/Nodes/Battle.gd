extends Node2D

var Gladio = preload("res://Games/Ludus/nodes/Gladio.tscn")
onready var pjs = GC.GAME.players.keys()
var hps = {}
var battle_data

func _ready():
	var cnt = pjs.size()
	var dist = 80 + cnt*8
	visible = false
	$ButtonHide.connect("button_down",self,"hide_battle")
	$Gladio.queue_free()
	for i in range(cnt):
		var gl = Gladio.instance(cnt)
		gl.name = "Gladio_"+pjs[i]
		gl.position = Vector2(400,200) + Vector2(dist*cos(i*PI*2/cnt),dist*.5*sin(i*PI*2/cnt))
		if gl.position.x>400: gl.get_node("Body").scale.x *= -1 
		add_child(gl)

func show_battle():
	randomize()
	visible = true
	create_battle_data()
	play_battle()

func hide_battle():
	visible = false

func create_battle_data():
	battle_data = {
		"start_hits":{},
		"rounds":[],
		"win":null,
		"lives":GC.GAME.players.size(),
	}
	for p in pjs:
		hps[p] = GC.GAME.players[p].hp
		battle_data.start_hits[p] = hps[p]
	while battle_data.lives>1:
		battle_data.rounds.append( new_round_data() )
	for p in pjs: if hps[p]>0: battle_data.win = p

func new_round_data():
	var round_data = []
	var hits = []
	for p in GC.GAME.players.keys():
		if hps[p]>0: hits.append(p)
	for p in GC.GAME.players.keys():
		if hits.size()==0: break
		var e = hits[ randi()%hits.size() ]
		for i in range(10): if p==e: e = hits[ randi()%hits.size() ]
		if p==e: continue
		var atk = GC.GAME.players[p].atk * 5
		var dam = floor( atk/2+rand_range(0,atk/2) )
		hps[e] -= dam
		if hps[e]<=0: 
			battle_data.lives -= 1
			hps[e]=0
		var str_line = p+"@"+e+"@"+str(dam)+"@"+str(hps[e])
#		print(str_line)
		round_data.append(str_line)
		hits.erase(e)
	return round_data

func play_battle():
	for p in pjs: 
		hps[p] = battle_data.start_hits[p]
		get_node("Gladio_"+p+"/Label").text = str(hps[p])
	var cntRound = 0
	for oneRound in battle_data.rounds:
		cntRound += 1
		$Label.text = "ROUND "+str(cntRound)
		yield(get_tree().create_timer(.5),"timeout")
		for ac in oneRound:
			ac = ac.split("@")
			var GLADIO = get_node("Gladio_"+ac[0])
			var origin = get_node("Gladio_"+ac[0]).position
			var destine = get_node("Gladio_"+ac[1]).position
			$Tween.interpolate_property(GLADIO,"position",origin,destine,.2,Tween.TRANS_LINEAR,Tween.EASE_IN)
			$Tween.start()
			yield(get_tree().create_timer(.3),"timeout")
			get_node("Gladio_"+ac[1]+"/Label").text = str(ac[3])
			pop_hit(destine,ac[2])
			$Tween.interpolate_property(GLADIO,"position",destine,origin,.2,Tween.TRANS_LINEAR,Tween.EASE_IN)
			$Tween.start()
			yield(get_tree().create_timer(.7),"timeout")

func pop_hit(pos,dam):
	$PopHit/Label.text = "-"+str(dam)
	$PopHit/Tween.interpolate_property($PopHit,"position",pos+Vector2(0,-50),pos+Vector2(0,-80),.5,Tween.TRANS_LINEAR,Tween.EASE_IN)
#	$PopHit/Tween.interpolate_property($PopHit,"modulate",Color(1,1,1,1),Color(1,1,1,0),.2,Tween.TRANS_LINEAR,Tween.EASE_IN,.3)
	$PopHit/Tween.start()
	yield(get_tree().create_timer(.7),"timeout")
	$PopHit.position.x = -300
