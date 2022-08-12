extends Node2D


func _ready():
	$Header/Label.text = GC.USER.name +" <"+GC.GAME.name+">  :"+str(GC.GAME.max_turns)
	$Header/btn_quit.connect("button_down",self,"onClick",["quit"])
	$Header/btn_turn.connect("button_down",self,"onClick",["turn"])
	CLOCK.init()
	set_now_time()
	if(GC.PLAYER.turn==0): $HelpPanel.showHelp("intro")
	for btn in $HelpButtons.get_children(): btn.connect("button_down",self,"onClickHelp",[btn])
	check_finish_game()

func onClick(btn):
	if btn == "quit": get_tree().change_scene("res://Scenes/Main.tscn")
	if btn == "turn": endTurn();
	
func endTurn():
	if GC.PLAYER.turn>=GC.get_total_turns(): return
	$Header/btn_turn.disabled = true
	$Interaction/Drager.disabled = true
	GC.reload_data()
	yield(GC,"complete_reload_data")
	$Interaction.end_turn_task()
	yield($Interaction,"finish_end_task")
	GC.PLAYER.turn += 1
	if GC.PLAYER.turn >= GC.GAME.max_turns && !"end_bonif_points" in GC.PLAYER: 
		GC.PLAYER.end_bonif_points = 0
		for bon in GC.PLAYER["civ_bonif"]: GC.PLAYER.end_bonif_points += GC.PLAYER[bon]
		GC.PLAYER.score += GC.PLAYER.end_bonif_points
		$Interaction.update_all_panels()
	FM.push_data("games/"+GC.GAME.name+"/players/"+GC.USER.name)
	yield(FM,"complete_push")
	update_ui()
	check_finish_game()
	$Header/btn_turn.disabled = false
	$Interaction/Drager.disabled = false

func set_now_time():
	$Header/btn_turn.disabled = true
	CLOCK.get_time()
	GC.NOW_TIME =  yield( CLOCK,"complete" )
	update_ui()
	$Header/btn_turn.disabled = false

func update_ui():
	$Header/btn_turn.text = str(GC.PLAYER.turn)+"/"+str(GC.get_total_turns())
	$Header/Recs.text = str(GC.PLAYER)

func onClickHelp(btn):
	$HelpPanel.showHelp(btn.name)

func check_finish_game():
	if GC.PLAYER.turn < GC.GAME.max_turns: return
	$EndPanel.show_end_panel()
	$Interaction/Drager.disabled = true
