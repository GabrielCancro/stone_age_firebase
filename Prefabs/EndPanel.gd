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
	$Timer.start()

func refresh():
	$Refresh.text = "REFRESH"
	FM.pull_data()
	yield(FM,"complete_pull")
	GC.GAME = FM.DATA.games[GC.GAME.name]
	get_node("../Interaction/ScoreTable").updateTable()
	$Refresh.text = ""
