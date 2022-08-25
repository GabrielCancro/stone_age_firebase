extends ColorRect

var players = []
var current_own_game = null

func _ready():
	visible = false
	$NewGame/btn_back.connect("button_down",self,"onClickBack")
	$NewGame/Players/btn_add.connect("button_down",self,"onClickAddPLayer")
	$NewGame/btn_create.connect("button_down",self,"onClickCreateNewGame")
	$NewGame/btn_delete.connect("button_down",self,"onClickDelete")

func _input(event):
	if event is InputEventKey and event.pressed:
		yield(get_tree().create_timer(.1),"timeout")
		check_config_errors()

func showNewGamePanel(gameId=null):
	visible = true
	$NewGame.visible = true
	$NewGame/Players/Label_error.text = ""
	players = [GC.USER.name]
	in!gameId: check_own_game()

func check_own_game():
	$NewGame/Label_exist.text = ""
	$NewGame/btn_delete.visible = false
	for i in FM.DATA.games:
		var game = FM.DATA.games[i]
		if "own" in game && game.own == GC.USER.name: 
			current_own_game = game
			break
	if current_own_game:
		$NewGame/TitleEdit.text = current_own_game.desc
		$NewGame/btn_create.visible = false
		$NewGame/Label_exist.text = "Ya tienes una partida activa!"
		$NewGame/btn_delete.visible = true
		$NewGame/ReadOnlyStop.visible = true
		players = current_own_game.players.keys()
		if !"init_turns" in current_own_game: current_own_game.init_turns = 0
		$NewGame/Configs/Scroll/Grid/init_turns/LineEdit.text = str(current_own_game.init_turns)
		if !"max_turns" in current_own_game: current_own_game.max_turns = 0
		$NewGame/Configs/Scroll/Grid/total_turns/LineEdit.text = str(current_own_game.max_turns)
		if !"turns_phs" in current_own_game: current_own_game.turns_phs = 0
		$NewGame/Configs/Scroll/Grid/phs_turns/LineEdit.text = str(current_own_game.turns_phs)
		if !"duration" in current_own_game: current_own_game.duration = 0
		$NewGame/Configs/Scroll/Grid/duration/LineEdit.text = str(current_own_game.duration)
	showPlayersList()
	check_config_errors()

func onClickBack():
	visible = false

func onClickAddPLayer():
	var name = $NewGame/Players/LineEdit.text.to_upper()
	if(players.find(name)!=-1):
		$NewGame/Players/Label_error.text = "El jugador ya esta en lista"
		yield(get_tree().create_timer(2),"timeout")
		$NewGame/Players/Label_error.text = ""
	elif !name in FM.DATA.users:
		$NewGame/Players/Label_error.text = "Jugador Inexistnte"
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
	$NewGame.visible = false
	FM.DATA.games_id += 1
	FM.push_var("","games_id",FM.DATA.games_id)
	yield(FM,"complete_push")
	check_config_errors()
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
		"max_turns": int($NewGame/Configs/Scroll/Grid/total_turns/LineEdit.text),
		"init_turns": int($NewGame/Configs/Scroll/Grid/init_turns/LineEdit.text),
		"turns_phs": int($NewGame/Configs/Scroll/Grid/phs_turns/LineEdit.text),
		"duration": int($NewGame/Configs/Scroll/Grid/duration/LineEdit.text),
		"own": GC.USER.name,
		"pest_event": -1
	}	
	if FM.DATA.games[game_name]["desc"]=="": FM.DATA.games[game_name]["desc"] = game_name
	FM.push_data("games/"+game_name)
	yield(FM,"complete_push")
	get_tree().reload_current_scene()

func check_config_errors():
	var correct = true
	if !$NewGame/Configs/Scroll/Grid/init_turns/LineEdit.text.is_valid_integer():
		$NewGame/Configs/Scroll/Grid/init_turns/LineEdit.text = ""
		correct = false
	if !$NewGame/Configs/Scroll/Grid/phs_turns/LineEdit.text.is_valid_integer():
		$NewGame/Configs/Scroll/Grid/phs_turns/LineEdit.text = ""
		correct = false
	if !$NewGame/Configs/Scroll/Grid/total_turns/LineEdit.text.is_valid_integer():
		$NewGame/Configs/Scroll/Grid/total_turns/LineEdit.text = ""
		correct = false
	if !$NewGame/Configs/Scroll/Grid/final_await/LineEdit.text.is_valid_integer():
		$NewGame/Configs/Scroll/Grid/final_await/LineEdit.text = ""
		correct = false
	if correct:
		var max_turns = int($NewGame/Configs/Scroll/Grid/total_turns/LineEdit.text)
		var init_turns = int($NewGame/Configs/Scroll/Grid/init_turns/LineEdit.text)
		var turns_phs = int($NewGame/Configs/Scroll/Grid/phs_turns/LineEdit.text)
		var hs_await = int($NewGame/Configs/Scroll/Grid/final_await/LineEdit.text)
		var duration = ceil( (max_turns-init_turns) / turns_phs ) + hs_await
		$NewGame/Configs/Scroll/Grid/duration/LineEdit.text = str(duration)
	else: $NewGame/Configs/Scroll/Grid/duration/LineEdit.text = "?"

func onClickDelete():
	if !current_own_game: return
	if $NewGame/btn_delete.text != "SEGURO?":
		$NewGame/btn_delete.text = "SEGURO?"
		return
	$NewGame/btn_delete.disabled = true
	FM.delete_path("games/"+current_own_game.name)
	yield(FM,"complete_remove")
	get_tree().reload_current_scene()
