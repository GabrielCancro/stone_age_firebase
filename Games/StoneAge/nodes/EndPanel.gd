extends ColorRect

# Called when the node enters the scene tree for the first time.
func _ready():
	visible = false
	$Label_noFinish.visible = true
	$HeaderTable.visible = false
	$FinalTable.visible = false
	$Timer.connect("timeout",self,"refresh")

func show_end_panel():
	visible = true
	$Map.modulate.a = 0
	update_stock()
	check_all_finished()
	$Timer.start()

func refresh():
	$Refresh.text = "REFRESH"
	FM.pull_data()
	yield(FM,"complete_pull")
	GC.GAME = FM.DATA.games[GC.GAME.name]
	get_node("../Interaction/ScoreTable").updateTable()
	check_all_finished()
	$Refresh.text = ""

func check_all_finished():
	var finished = true
#	for p in GC.GAME.players:
#		print("END ",p," ",GC.GAME.players[p].turn)
#		if(GC.GAME.players[p].turn<GC.GAME.max_turns): finished = false
	if finished:
		var winner = show_final_table()
		$Map.modulate.a = 1
		$Label_win.text = winner
		$Label_noFinish.text = ""
		$HeaderTable.visible = true
		$FinalTable.visible = true

func update_stock():
	var data = {}
	for bon in $VBox_stock.get_children(): data[bon.name] = 0
	if("civ_bonif" in GC.PLAYER): for bon in GC.PLAYER["civ_bonif"]: data[bon] += 1
	for bon in $VBox_stock.get_children():
		bon.get_node("Label").text = str( data[bon.name] )+"x"+str( GC.PLAYER[bon.name] )+"="+str( data[bon.name]*GC.PLAYER[bon.name] )
#	$Label_extra.text = str(GC.PLAYER.end_bonif_points)

func show_final_table():
	var pjs_order = []
	var total_looter = 0
	var total_score = 0
	for sl in $FinalTable/VBox.get_children(): 
		if sl.get_index()>GC.GAME.players.size(): 
			sl.queue_free()
	for i in GC.GAME.players:
		var pl = GC.GAME.players[i]
		pjs_order.append(i)
		pl["name"] = i
		pl["end_bonif"] = _get_civ_bonif(pl)
		pl["end_score"] = pl.score
		pl["end_score"] += pl.villager*pl["end_bonif"].villager
		pl["end_score"] += pl.camp*pl["end_bonif"].camp
		pl["end_score"] += pl.tool*pl["end_bonif"].tool
		pl["end_score"] += pl.build*pl["end_bonif"].build
		total_score += pl["score"]
		total_looter += pl["looter"]
	var percent_looter = .3
	for i in pjs_order:
		var pl = GC.GAME.players[i]
		pl["percent_looter"] = percent_looter
		if total_looter==0: pl["points_per_looter"] = 0
		else: pl["points_per_looter"] = floor( total_score * pl.percent_looter / total_looter)
		pl["end_score"] -= floor(pl.score * pl.percent_looter)
		pl["end_score"] += pl.points_per_looter * pl.looter
	$HeaderTable/ico5/scores.text = str( floor(total_score*percent_looter) )
	$HeaderTable/ico5/looters.text = str( total_looter )
	pjs_order.sort_custom(self, "customComparison")
	for sl in $FinalTable/VBox.get_children():
		var i = sl.get_index()
		if i< pjs_order.size(): sl.set_data(GC.GAME.players[ pjs_order[i] ])
		else: sl.visible = false
	check_new_win(pjs_order[0])
	return pjs_order[0]

func check_new_win(winner_name):
	var cnt_players = GC.GAME.players.keys().size()
	for p in GC.GAME.players: if(GC.GAME.players[p].turn<GC.GAME.max_turns/2): cnt_players -= 1
	if !"is_winner" in GC.PLAYER && cnt_players>2: 
		GC.PLAYER["is_winner"] = (winner_name == GC.USER.name)
		if(GC.PLAYER["is_winner"]):
			GC.USER.wins += 1
			FM.DATA.users[GC.USER.name] = GC.USER
			FM.push_data("games/"+GC.GAME.name+"/players/"+GC.USER.name)
			yield(FM,"complete_push")
			FM.DATA.users[GC.USER.name] = GC.USER
			FM.push_data("users/"+GC.USER.name)
			yield(FM,"complete_push")

func _get_civ_bonif(pl):
	var bonif = {"villager":0,"tool":0,"camp":0,"build":0}
	if !"civ_bonif" in pl: pl["civ_bonif"] = []
	for i in pl["civ_bonif"]: bonif[i] += 1
	return bonif

func customComparison(a,b):
	 return GC.GAME.players[a].end_score > GC.GAME.players[b].end_score
