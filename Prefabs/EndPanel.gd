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
	$Timer.start()

func refresh():
	$Refresh.text = "REFRESH"
	FM.pull_data()
	yield(FM,"complete_pull")
	GC.GAME = FM.DATA.games[GC.GAME.name]
	get_node("../Interaction/ScoreTable").updateTable()
	$Refresh.text = ""

func update_stock():
	var data = {}
	for bon in $VBox_stock.get_children(): data[bon.name] = 0
	if("civ_bonif" in GC.PLAYER): for bon in GC.PLAYER["civ_bonif"]: data[bon] += 1
	for bon in $VBox_stock.get_children():
		bon.get_node("Label").text = str( data[bon.name] )+"x"+str( GC.PLAYER[bon.name] )+"="+str( data[bon.name]*GC.PLAYER[bon.name] )
	$Label_extra.text = str(GC.PLAYER.end_bonif_points)