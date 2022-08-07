extends Node2D


func _ready():
	$Header/Label.text = GC.USER.name +" <"+GC.GAME.name+">"
	$Header/btn_quit.connect("button_down",self,"onClick",["quit"])
	$Header/btn_turn.connect("button_down",self,"onClick",["turn"])
	CLOCK.init()
	set_now_time()

func onClick(btn):
	if btn == "quit": get_tree().change_scene("res://Scenes/Main.tscn")
	if btn == "turn": endTurn();
	
func endTurn():
	$Header/btn_turn.disabled = true
	GC.reload_data()
	yield(GC,"complete_reload_data")
	$Interaction.end_turn_task()
#	yield($Interaction,"finish_end_task")
	GC.PLAYER.turn += 1
	FM.push_data("games/"+GC.GAME.name+"/players/"+GC.USER.name)
	yield(FM,"complete_push")
	update_ui()
	$Header/btn_turn.disabled = false
	
func set_now_time():
	$Header/btn_turn.disabled = true
	CLOCK.get_time()
	GC.NOW_TIME =  yield( CLOCK,"complete" )
	GC.TOTAL_TURNS = 3+floor( (GC.NOW_TIME - GC.GAME.start_time)/10)
	update_ui()
	$Header/btn_turn.disabled = false

func update_ui():
	$Header/btn_turn.text = str(GC.PLAYER.turn)+"/"+str(GC.TOTAL_TURNS)
	$Header/Recs.text = str(GC.PLAYER)
