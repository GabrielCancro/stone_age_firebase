extends Node2D

signal finish_end_task
signal finish_current_anim
# Called when the node enters the scene tree for the first time.
func _ready():
	$Drager.connect("set_node",self,"onSetNode")
	update_all_panels()

func onSetNode(node,stay,result):
	print(result)
	if result.TOOL>1: $Drager.free_node(node)
	if result.CAMP>1: $Drager.free_node(node)
	if result.VILLAGER>2: $Drager.free_node(node)

func end_turn_task():
	var RESULT = $Drager.get_result()
	print("RESUTL")
	print(RESULT)
	print("__________________________________")
	if RESULT.FOOD > 0: 
		add_resource("FOOD", floor(get_dices(RESULT.FOOD)/2) )
		yield(self,"finish_current_anim")
	if RESULT.WOOD > 0:
		add_resource("WOOD", floor(get_dices(RESULT.WOOD)/3) )
		yield(self,"finish_current_anim")
	if RESULT.ADOBE > 0: 
		add_resource("ADOBE", floor(get_dices(RESULT.ADOBE)/4) )
		yield(self,"finish_current_anim")
	if RESULT.STONE > 0: 
		add_resource("STONE", floor(get_dices(RESULT.STONE)/5) )
		yield(self,"finish_current_anim")
	if RESULT.GOLD > 0: 
		add_resource("GOLD", floor(get_dices(RESULT.GOLD)/6) )
		yield(self,"finish_current_anim")
	if RESULT.TOOL == 1: 
		add_resource("TOOL",1)
		yield(self,"finish_current_anim")
	if RESULT.CAMP == 1: 
		add_resource("CAMP",1)
		yield(self,"finish_current_anim")
	if RESULT.VILLAGER == 2: 
		add_resource("VILLAGER",1)
		$Drager.add_max(1)
		update_all_panels()
		yield(self,"finish_current_anim")
	if RESULT.BUILD == 1 && GC.PLAYER.build_cards: 
		var card = GC.PLAYER.build_cards[GC.BUILD_TO_CONSTRUCT]
		var recs = {}
		for r in card: 
			if !r in recs: recs[r] = 0
			recs[r] += 1
		var build = true
		for r in recs: if recs[r] > GC.PLAYER[r]: build = false
		if build:
			for r in recs:
				GC.PLAYER[r] -= recs[r]
				update_all_panels()
				fx_text("-"+str(recs[r]),r,get_node("../Map/MapBuild").position)
				yield(self,"finish_current_anim")
			#add build
			add_resource("BUILD",1)
			yield(self,"finish_current_anim")
			#add score
			var score = get_node("../BuildPanel").calc_score(card)
			GC.PLAYER["score"] += score
			fx_text("+"+str(score),"score",Vector2(700,310))
			update_all_panels()
			GC.PLAYER.build_cards.erase(card)
			print(GC.PLAYER.build_cards)
			yield(self,"finish_current_anim")
		#free villager
		$Drager.free_node(get_node("../BuildPanel").current_villager_node)
		yield(get_tree().create_timer(.3),"timeout")

#	EAT TRIBE
	var eat = max(0,GC.PLAYER["villager"]-GC.PLAYER["camp"])
	GC.PLAYER["food"] -= eat
	var no_eat = false
	if(GC.PLAYER["food"]<0): 
		GC.PLAYER["food"] = 0
		no_eat = true
	fx_text("-"+str(eat),"food",$eat_panel.position)
	update_all_panels()
	yield(self,"finish_current_anim")
	if no_eat:
		GC.PLAYER["score"] -= 10
		fx_text("-"+str(10),"score",Vector2(700,310))
		update_all_panels()
		yield(self,"finish_current_anim")
	
#	END TURN
	yield(get_tree().create_timer(1),"timeout")
	emit_signal("finish_end_task")

func add_resource(name,cnt):
	var nameLow = name.to_lower()
	if !nameLow in GC.PLAYER: GC.PLAYER[nameLow] = 0
	GC.PLAYER[nameLow] += cnt
	fx_text("+"+str(cnt),name,$Drager/Points.get_node(name).position)
	update_all_panels()
	
func fx_text(txt,icon,pos):
	$fx/Icon.texture = load("res://assets/"+icon.to_lower()+".jpg")
	$fx/Label.text = txt
	$fx.position = pos + Vector2(0,-15)
	$Tween.interpolate_property($fx,"modulate",Color(1,1,1,1),Color(1,1,1,0),1.0,Tween.TRANS_QUINT,Tween.EASE_IN)
	$Tween.interpolate_property($fx,"position",$fx.position,$fx.position+Vector2(0,-10),1.0,Tween.TRANS_QUAD,Tween.EASE_OUT)
	$Tween.start()
	yield($Tween,"tween_completed")
	yield(get_tree().create_timer(.1),"timeout")
	emit_signal("finish_current_anim")

func get_dices(cnt):
	randomize()
	var sum = 0
	for i in range(cnt): sum += randi() % 6 +1
	return sum

func update_all_panels():
	var cnt = max(0,GC.PLAYER["villager"]-GC.PLAYER["camp"])
	$eat_panel/Label2.text = "-"+str(cnt)
	$rec_panel.update_panel()
	$ScoreTable.updateTable()
