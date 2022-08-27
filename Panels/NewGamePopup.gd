extends ColorRect

var players = []
var current_own_game = null
var ConfigVars = null
var gameId = null
signal on_play_click()
signal close()

func _ready():
	visible = false
	$NewGame/btn_back.connect("button_down",self,"onClickBack")
	$NewGame/Players/btn_add.connect("button_down",self,"onClickAddPLayer")
	$NewGame/btn_create.connect("button_down",self,"onClickCreateNewGame")
	$NewGame/btn_delete.connect("button_down",self,"onClickDelete")
	$NewGame/btn_play.connect("button_down",self,"onClickPlay")
	$NewGame/Configs/GameTypeSelector.connect("item_selected",self,"onSelectGame")
	ConfigVars = $NewGame/Configs/Scroll.get_child(0)

func showNewGamePanel(_gameId=null):
	gameId = _gameId
	visible = true
	$NewGame.visible = true
	$NewGame/btn_create.visible = false
	$NewGame/btn_delete.visible = false
	$NewGame/btn_play.visible = false
	$NewGame/Players/Label_error.text = ""
	$NewGame/Label_exist.text = ""
	current_own_game = null
	$NewGame/ReadOnlyStop.visible = false
	$NewGame/Configs/ReadOnlyGame.visible = false
	if !gameId: 
		players = [GC.USER.name]
		check_own_game()
		if current_own_game: 
			gameId = current_own_game.name
			$NewGame/btn_delete.visible = true
		else: $NewGame/btn_create.visible = true
	if gameId: 
		var game = FM.DATA.games[gameId]
		if current_own_game!=game:$NewGame/btn_play.visible = true		
		$NewGame/ReadOnlyStop.visible = true
		$NewGame/TitleEdit.text = game.desc
		$NewGame/Label_exist.text = "Partida de "+game.own
		if current_own_game==game: $NewGame/Label_exist.text = "Ya tienes una partida activa!"
		players = game.players.keys()
		$NewGame/Configs/ReadOnlyGame.visible = true
	onSelectGame(-1)
	showPlayersList()

func onSelectGame(index):
	if(gameId):
		for i in $NewGame/Configs/GameTypeSelector.get_item_count():
			if $NewGame/Configs/GameTypeSelector.get_item_text(i) == FM.DATA.games[gameId].gameType:
				index = i
	elif(index==-1): index = 0
	$NewGame/Configs/GameTypeSelector.select(index)	
	$NewGame/Configs/Scroll.remove_child(ConfigVars)
	ConfigVars.queue_free()
	var gameName = $NewGame/Configs/GameTypeSelector.get_item_text(index)
	print("SELECTED-",index," ",gameName)
	$NewGame/Configs/GameIcon.texture = load("res://Games/"+gameName+"/ico.png")
	ConfigVars = load("res://Games/"+gameName+"/ConfigVars.tscn").instance()
	$NewGame/Configs/Scroll.add_child(ConfigVars)
	ConfigVars.setReadOnly(false)
	if(gameId):
		ConfigVars.set_data_from_game(FM.DATA.games[gameId])
		ConfigVars.setReadOnly(true)
	
func check_own_game():
	$NewGame/Label_exist.text = ""
	$NewGame/btn_delete.visible = false
	for i in FM.DATA.games:
		var game = FM.DATA.games[i]
		if "own" in game && game.own == GC.USER.name: 
			current_own_game = game
			break

func onClickBack():
	visible = false

func onClickAddPLayer():
	var name = $NewGame/Players/LineEdit.text.to_upper()
	if(players.find(name)!=-1):
		$NewGame/Players/Label_error.text = "El jugador ya esta en lista"
		yield(get_tree().create_timer(2),"timeout")
		$NewGame/Players/Label_error.text = ""
	elif !name in FM.DATA.users:
		$NewGame/Players/Label_error.text = "Jugador Inexistente"
		yield(get_tree().create_timer(2),"timeout")
		$NewGame/Players/Label_error.text = ""
	else: 
		$NewGame/Players/LineEdit.text = ""
		players.append(name)
	print(players)
	showPlayersList()

func showPlayersList():
	$NewGame/Players/Label_players.text = ""
	for i in players: $NewGame/Players/Label_players.text += i+"\n"

func onClickCreateNewGame():
	var config_data = ConfigVars.get_config_data()
	if !config_data: return
	$NewGame.visible = false
	FM.DATA.games_id += 1
	FM.push_var("","games_id",FM.DATA.games_id)
	yield(FM,"complete_push")
	var game_name = "partida "+str(FM.DATA.games_id)
	var players_data = {}
	for nm in players:
		players_data[nm.to_upper()] = {
			"turn":0, "tool":0, "camp":0,"villager":5,"score":0,
			"food":20,"wood":0,"adobe":0,"stone":0,"gold":0,"build":0,"looter":0,
			"build_cards":[],"civ_cards":[],"civ_bonif":[],
		}
	FM.DATA.games[game_name] = {
		"name":game_name,
		"desc":$NewGame/TitleEdit.text,
		"start_time": yield( CLOCK.get_time(),"complete" ),
		"start_os_date": OS.get_datetime(),
		"players": players_data,
		"own": GC.USER.name,
		"gameType": $NewGame/Configs/GameTypeSelector.text
	}
	for k in config_data.keys(): FM.DATA.games[game_name][k] = config_data[k]
	if FM.DATA.games[game_name]["desc"]=="": FM.DATA.games[game_name]["desc"] = game_name
	FM.push_data("games/"+game_name)
	yield(FM,"complete_push")
	get_tree().reload_current_scene()

func onClickDelete():
	if !current_own_game: return
	if $NewGame/btn_delete.text != "SEGURO?":
		$NewGame/btn_delete.text = "SEGURO?"
		return
	$NewGame/btn_delete.disabled = true
	FM.delete_path("games/"+current_own_game.name)
	yield(FM,"complete_remove")
	get_tree().reload_current_scene()

func onClickPlay():
	emit_signal("on_play")
	get_tree().change_scene("res://Games/"+FM.DATA.games[gameId].gameType+"/Game.tscn")
