extends Node2D

var OWN_GAME = null
func _ready():
	$NewGamePopup.visible = false
	$User/Label.text = "Bienvenido "+GC.USER.name+"!"
	$User/btn_logout.connect("button_down",self,"onClick",["logout"])
	$User/btn_new.connect("button_down",self,"onClick",["new"])
	CLOCK.init()
	$User/btn_new.visible = (GC.USER.name == "MOLE")
	FM.pull_data()
	yield(FM,"complete_pull")
	$User/btn_logout.disabled = false
	set_game_button()

func onClick(btn):
	if btn=="logout":
		GC.USER = null
		get_tree().change_scene("res://Scenes/Login.tscn")
	if btn=="new":
		$NewGamePopup.showNewGamePanel()

#func check_time():
#	var nowTime = yield(CLOCK.get_time(),"complete")
#	var played_time = nowTime-FM.DATA.games.gm1.start_time
#	print("START TIME: ",FM.DATA.games.gm1.start_time)
#	print("NOW TIME: ",nowTime)
#	print("PLAYED TIME: ",played_time)
#	print("TURNS: ",floor(played_time/25))

func set_game_button():
	if !"games" in FM.DATA: 
		FM.DATA.games = {}
		FM.push_data("games")
		yield(FM,"complete_push")
	for i in FM.DATA.games:
		var game = FM.DATA.games[i]
		if GC.USER.name in game.players.keys():
			var btn = Button.new()
			btn.text = game.name
			$Games/VBox.add_child(btn)
			if !GC.USER.name in game.players: btn.disabled = true
			btn.connect("button_down",self,"onSelectGame",[game])

func onSelectGame(game):
	GC.GAME = game
	GC.PLAYER = game.players[GC.USER.name]
	get_tree().change_scene("res://Scenes/Game.tscn")
