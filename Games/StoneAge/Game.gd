extends Node2D


func _ready():
	$Header/Label.text = GC.USER.name +" <"+GC.GAME.name+">  :"+str(GC.GAME.max_turns)
	$Header/btn_quit.connect("button_down",self,"onClick",["quit"])
	$Header/end_turn/btn_turn.connect("button_down",self,"onClick",["turn"])
	$Header/btn_build.connect("button_down",self,"onClick",["build"])
	$Header/btn_civ.connect("button_down",self,"onClick",["civ"])
	CLOCK.init()
	set_now_time()
	GC.FINISHED = false
	check_finished_game()
	if(GC.PLAYER.turn==0 && !GC.FINISHED): $HelpPanel.showHelp("intro")
	for btn in $HelpButtons.get_children(): btn.connect("button_down",self,"onClickHelp",[btn])
	if "worker_positions" in GC.PLAYER && !GC.FINISHED: $Interaction/Drager.set_worker_positions(GC.PLAYER["worker_positions"])

func onClick(btn):
	if btn == "quit": get_tree().change_scene("res://Scenes/Main.tscn")
	if btn == "turn": endTurn()
	if btn == "build" && !$Interaction/Drager.drag_node: $BuildPanel.showBuildPanel()
	if btn == "civ" && !$Interaction/Drager.drag_node: $CivPanel.showCivPanel()
	
func endTurn():
	GC.SOUND.play_on_turn()
	if GC.PLAYER.turn>=GC.get_total_turns(): return
	$Header/end_turn/btn_turn.disabled = true
	$Interaction/Drager.disabled = true
	GC.reload_data()
	yield(GC,"complete_reload_data")
	$Interaction.end_turn_task()
	yield($Interaction,"finish_end_task")
	GC.PLAYER.turn += 1
	#save workers positions
	GC.PLAYER["worker_positions"] = $Interaction/Drager.get_worker_positions()
	FM.push_data("games/"+GC.GAME.name+"/players/"+GC.USER.name)
	yield(FM,"complete_push")
	update_ui()
	$Interaction.update_all_panels()
	
	GC.SOUND.play_complete_turn()
	$Header/end_turn/btn_turn.disabled = false
	$Interaction/Drager.disabled = false
	$Header/end_turn/Tween.interpolate_property($Header/end_turn/btn_turn,"modulate",Color(3,3,3),Color(1,1,1),1,Tween.TRANS_EXPO,Tween.EASE_OUT)
	$Header/end_turn/Tween.start()

func set_now_time():
	$Header/end_turn/btn_turn.disabled = true
	CLOCK.get_time()
	GC.NOW_TIME =  yield( CLOCK,"complete" )
	GC.ADVANCED_TIME = 0
	$Header/time_ui/Timer.connect("timeout",self,"updateTimeUi")
	update_ui()
	$Header/end_turn/btn_turn.disabled = false

func updateTimeUi():
	if GC.FINISHED: return
	GC.ADVANCED_TIME += 1
	var time_passed = GC.NOW_TIME + GC.ADVANCED_TIME - float(GC.GAME.start_time)
	var tm = float(GC.GAME.duration)*60*60 - time_passed
	if tm < 0:
		tm = 0
		GC.FINISHED = true
		for p in GC.GAME.players: if(GC.GAME.players[p].turn < GC.GAME.max_turns): GC.FINISHED = false
		if !"finished" in GC.GAME && GC.FINISHED:
			GC.GAME["finished"] = true
			FM.DATA.games[GC.GAME.name] = GC.GAME
			FM.push_data("games/"+GC.GAME.name)
			yield(FM,"complete_push")
	check_finished_game()
	var frm = {
		"seg": str(int(tm)%60).pad_zeros(2),
		"min": str(int(tm/60)%60).pad_zeros(2),
		"hs": str(int(tm/60/60))
	}
	$Header/time_ui/Label.text = frm.hs+":"+frm.min+":"+frm.seg

func update_ui():
	$Header/end_turn/btn_turn.text = str(GC.PLAYER.turn)+"/"+str(GC.get_total_turns())
	$Header/Recs.text = str(GC.PLAYER)

func onClickHelp(btn):
	$HelpPanel.showHelp(btn.name)

func check_finished_game():
	if("finished" in GC.GAME && GC.GAME.finished): GC.FINISHED = true
	if GC.FINISHED:
		GC.SOUND.play_sfx("win")
		$EndPanel.show_end_panel()
		$Interaction/Drager.disabled = true
