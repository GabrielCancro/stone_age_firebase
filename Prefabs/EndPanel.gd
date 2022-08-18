extends ColorRect


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	visible = false
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
		show_final_table()
		$Label_win.text = get_node("../Interaction/ScoreTable").table[0].name
		$Label_noFinish.text = ""

func update_stock():
	var data = {}
	for bon in $VBox_stock.get_children(): data[bon.name] = 0
	if("civ_bonif" in GC.PLAYER): for bon in GC.PLAYER["civ_bonif"]: data[bon] += 1
	for bon in $VBox_stock.get_children():
		bon.get_node("Label").text = str( data[bon.name] )+"x"+str( GC.PLAYER[bon.name] )+"="+str( data[bon.name]*GC.PLAYER[bon.name] )
#	$Label_extra.text = str(GC.PLAYER.end_bonif_points)

func show_final_table():
	var table = []
	for i in GC.GAME.players:
		var pl = GC.GAME.players[i]
		pl["bonif"] = _get_civ_bonif(pl)
		pl["final_score"] = pl.score
		pl["final_score"] += pl.villager*pl["bonif"].villager
		pl["final_score"] += pl.camp*pl["bonif"].camp
		pl["final_score"] += pl.tool*pl["bonif"].tool
		pl["final_score"] += pl.build*pl["bonif"].build
	
	for label in $FinalTable/HBox.get_children():
		label.text = ""
	for i in GC.GAME.players.keys():
		var pl = GC.GAME.players[i]
		var bonif = pl["bonif"]
		$FinalTable/HBox/lb_name.text += i
		$FinalTable/HBox/lb_score.text += str(pl.score)
		$FinalTable/HBox/lb_villager.text += str(pl.villager)+"x"+str(bonif.villager)
		$FinalTable/HBox/lb_camp.text += str(pl.camp)+"x"+str(bonif.camp)
		$FinalTable/HBox/lb_tool.text += str(pl.tool)+"x"+str(bonif.tool)
		$FinalTable/HBox/lb_build.text += str(pl.build)+"x"+str(bonif.build)
		$FinalTable/HBox/lb_looter.text += "-"
		$FinalTable/HBox/lb_total.text += str(pl.final_score)

func _get_civ_bonif(pl):
	var bonif = {"villager":0,"tool":0,"camp":0,"build":0}
	if !"civ_bonif" in pl: pl["civ_bonif"] = []
	for i in pl["civ_bonif"]: bonif[i] += 1
	return bonif
