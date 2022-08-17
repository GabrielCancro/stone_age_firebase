extends Node2D

signal finish_end_task
signal finish_current_anim
# Called when the node enters the scene tree for the first time.
func _ready():
	$Drager.connect("set_node",self,"onSetNode")
	update_all_panels()

func onSetNode(node,stay,result):
	print(result)
	if stay=="TOOL":
		if result.TOOL>1: $Drager.free_node(node)
		else: 
			if result.VILLAGER>0: $Drager.free_node_from_stay("VILLAGER")
			if result.CAMP>0: $Drager.free_node_from_stay("CAMP")
	if stay=="CAMP":
		if result.CAMP>1: $Drager.free_node(node)
		else: 
			if result.TOOL>0: $Drager.free_node_from_stay("TOOL")
			if result.VILLAGER>0: $Drager.free_node_from_stay("VILLAGER")
	if result.VILLAGER>2: $Drager.free_node(node)
	if stay=="VILLAGER":
		if GC.PLAYER.villager>=10: $Drager.free_node_from_stay("VILLAGER")
		else: 
			if result.TOOL>0: $Drager.free_node_from_stay("TOOL")
			if result.CAMP>0: $Drager.free_node_from_stay("CAMP")
	if stay=="BUILD":
		if result.BUILD>1: $Drager.free_node(node)
		else:
			if result.CIV>0: 
				$Drager.free_node_from_stay("CIV")
				yield(get_tree().create_timer(.15),"timeout")
			get_node("../BuildPanel").showBuildPanel()
	if stay=="CIV":
		if result.CIV>1: $Drager.free_node(node)
		else:
			if result.CIV>0: 
				$Drager.free_node_from_stay("BUILD")
				yield(get_tree().create_timer(.15),"timeout")
			get_node("../CivPanel").showCivPanel()

func end_turn_task():
	var RESULT = $Drager.get_result()
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
		if GC.PLAYER.villager>=10: 
			$Drager.free_node_from_stay("VILLAGER")
			yield(get_tree().create_timer(.4),"timeout")
	if RESULT.BUILD == 1 && GC.PLAYER.build_cards: 
		var card_data = GC.PLAYER.build_cards[GC.BUILD_TO_CONSTRUCT]
		var buildeable = true
		for i in card_data: if card_data[i] > GC.PLAYER[i]: buildeable = false
		if buildeable:
			for i in card_data:
				if card_data[i]==0: continue
				GC.PLAYER[i] -= card_data[i]
				update_all_panels()
				fx_text("-"+str(card_data[i]),i,get_node("../Map/MapBuild").position)
				yield(self,"finish_current_anim")
			#add build
			add_resource("BUILD",1)
			yield(self,"finish_current_anim")
			#add score
			var score = get_node("../BuildPanel").calc_score(card_data)
			GC.PLAYER["score"] += score
			fx_text("+"+str(score),"score",Vector2(700,310))
			update_all_panels()
			GC.PLAYER.build_cards.erase(card_data)
			print(GC.PLAYER.build_cards)
			yield(self,"finish_current_anim")
		#free villager
		$Drager.free_node_from_stay("BUILD")
		yield(get_tree().create_timer(.3),"timeout")
	
	if RESULT.CIV == 1 && GC.PLAYER.civ_cards: 
		var card = GC.PLAYER.civ_cards[GC.CIV_TO_CONSTRUCT]
		if(!"civ_bonif" in GC.PLAYER): GC.PLAYER["civ_bonif"] = []
		var val = 3 + floor(GC.PLAYER["civ_bonif"].size()/2) + GC.CIV_TO_CONSTRUCT
		if(GC.PLAYER["wood"]>=val):
			GC.PLAYER["wood"] -= val
			update_all_panels()
			fx_text("-"+str(val),"wood",get_node("../Map/MapCiv").position)
			yield(self,"finish_current_anim")
			#add rec
			GC.PLAYER[card[0]] += 1
			update_all_panels()
			fx_text("+"+str(1),card[0],get_node("../Map/MapCiv").position)
			yield(self,"finish_current_anim")
			#add civ			
			GC.PLAYER["civ_bonif"].append(card[1])
			update_all_panels()
			GC.PLAYER.civ_cards.erase(card)
			fx_text("+"+str(1),"civ",get_node("../Map/MapCiv").position)
			yield(self,"finish_current_anim")
		#free villager
		$Drager.free_node_from_stay("CIV")
		yield(get_tree().create_timer(.3),"timeout")

#	EAT TRIBE
	var eat = GC.PLAYER["villager"] - floor(GC.PLAYER["camp"]/2)
	eat = max(0,eat)
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
	yield(get_tree().create_timer(.5),"timeout")
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
	for i in range(cnt): sum += (randi() % 6 + 1) + floor(GC.PLAYER["tool"]/3)
	return sum

func update_all_panels():
	var eat = GC.PLAYER["villager"] - floor(GC.PLAYER["camp"]/2)
	eat = max(0,eat)
	$eat_panel/Label2.text = "-"+str(eat)
	$rec_panel.update_panel()
	$ScoreTable.updateTable()
