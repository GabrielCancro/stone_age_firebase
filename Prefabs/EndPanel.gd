extends ColorRect

var ScoreLineScene = preload("res://Prefabs/ScoreLine.tscn")
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	visible = false
	$Label_noFinish.visible = true
	$HeaderTable.visible = false
	$FinalTable.visible = false
	$Timer.connect("timeout",self,"refresh")

func show_end_panel():
	visible = true
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
	for p in GC.GAME.players:
		print("END ",p," ",GC.GAME.players[p].turn)
		if(GC.GAME.players[p].turn<GC.GAME.max_turns): finished = false
	if finished:
		var winner = show_final_table()
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
	var max_score = 0
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
		if pl["score"]>max_score: max_score = pl["score"]
		total_looter += pl["looter"]
	for i in pjs_order:
		var pl = GC.GAME.players[i]
		pl["prom_looter"] = floor(total_looter/pjs_order.size())
		pl["points_per_looter"] = ceil( max_score / 10 )
		pl["end_score"] += (pl.looter - pl.prom_looter) * pl.points_per_looter
	pjs_order.sort_custom(self, "customComparison")
	for sl in $FinalTable/VBox.get_children():
		var i = sl.get_index()
		if i< pjs_order.size(): sl.set_data(GC.GAME.players[ pjs_order[i] ])
		else: sl.visible = false
	check_new_win(pjs_order[0])
	return pjs_order[0]

func check_new_win(winner_name):
	if !"is_winner" in GC.PLAYER: 
		GC.PLAYER["is_winner"] = (winner_name == GC.USER.name)
		if(GC.PLAYER["is_winner"]):
			GC.USER.wins += 1
			FM.push_data("games/"+GC.GAME.name+"/players/"+GC.USER.name)
			yield(FM,"complete_push")
			FM.push_data("users/"+GC.USER.name)
			yield(FM,"complete_push")

func _get_civ_bonif(pl):
	var bonif = {"villager":0,"tool":0,"camp":0,"build":0}
	if !"civ_bonif" in pl: pl["civ_bonif"] = []
	for i in pl["civ_bonif"]: bonif[i] += 1
	return bonif

func customComparison(a,b):
	 return GC.GAME.players[a].end_score > GC.GAME.players[b].end_score
