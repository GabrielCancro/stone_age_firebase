extends ColorRect

var players = []
var current_own_game = null
# Called when the node enters the scene tree for the first time.
func _ready():
	visible = false
# warning-ignore:return_value_discarded
	$NewGame/btn_back.connect("button_down",self,"onClickBack")
# warning-ignore:return_value_discarded
	$NewGame/btn_add.connect("button_down",self,"onClickAddPLayer")
# warning-ignore:return_value_discarded
	$NewGame/btn_create.connect("button_down",self,"onClickCreateNewGame")
# warning-ignore:return_value_discarded
	$NewGame/btn_delete.connect("button_down",self,"onClickDelete")
# warning-ignore:return_value_discarded
	$NewGame/VBoxContainer/init_turns.connect("focus_exited",self,"check_config_errors")
# warning-ignore:return_value_discarded
	$NewGame/VBoxContainer/turns_phs.connect("focus_exited",self,"check_config_errors")
# warning-ignore:return_value_discarded
	$NewGame/VBoxContainer/total_turns.connect("focus_exited",self,"check_config_errors")

func showNewGamePanel():
	visible = true
	$NewGame.visible = true
	$NewGame/Label_error.text = ""
	players = [GC.USER.name]
	check_own_game()
	showPlayersList()
	check_config_errors()

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
		$NewGame/TitleEdit.editable = false
		$NewGame/btn_add.disabled = true
		$NewGame/btn_create.disabled = true
		$NewGame/Label_exist.text = "Ya tienes una partida activa!"
		$NewGame/btn_delete.visible = true
		$NewGame/VBoxContainer/OptionButton.disabled = true
		$NewGame/VBoxContainer/init_turns.editable = false
		$NewGame/VBoxContainer/turns_phs.editable = false
		$NewGame/VBoxContainer/total_turns.editable = false
		$NewGame/VBoxContainer/pest_event.disabled = true
		players = current_own_game.players.keys()

func onClickBack():
	visible = false

func onClickAddPLayer():
	var name = $NewGame/LineEdit.text.to_upper()
	if(players.find(name)!=-1):
		$NewGame/Label_error.text = "El jugador ya esta en lista"
		yield(get_tree().create_timer(2),"timeout")
		$NewGame/Label_error.text = ""
	elif !name in FM.DATA.users:
		$NewGame/Label_error.text = "Jugador Inexistnte"
		yield(get_tree().create_timer(2),"timeout")
		$NewGame/Label_error.text = ""
	else: 
		$NewGame/LineEdit.text = ""
		players.append(name)
	print(players)
	showPlayersList()

func showPlayersList():
	$NewGame/Label_players.text = ""
	for i in players: $NewGame/Label_players.text += i+"\n"

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
			"food":35,"wood":0,"adobe":0,"stone":0,"gold":0,"build":0,
			"build_cards":[],"civ_cards":[],"civ_bonif":[],
		}
	FM.DATA.games[game_name] = {
		"name":game_name,
		"desc":$NewGame/TitleEdit.text,
		"start_time": yield( CLOCK.get_time(),"complete" ),
		"start_os_date": OS.get_datetime(),
		"players": players_data,
		"max_turns": int($NewGame/VBoxContainer/total_turns.text),
		"init_turns": int($NewGame/VBoxContainer/init_turns.text),
		"turns_phs": int($NewGame/VBoxContainer/turns_phs.text),
		"own": GC.USER.name,
		"pest_event": -1
	}
	if $NewGame/VBoxContainer/pest_event.pressed: FM.DATA.games[game_name]["pest_event"] = floor(FM.DATA.games[game_name]["max_turns"]/2)
	if FM.DATA.games[game_name]["desc"]=="": FM.DATA.games[game_name]["desc"] = game_name
	FM.push_data("games/"+game_name)
	yield(FM,"complete_push")
# warning-ignore:return_value_discarded
	get_tree().reload_current_scene()

func check_config_errors():
	var correct = true
	if !$NewGame/VBoxContainer/init_turns.text.is_valid_integer():
		$NewGame/VBoxContainer/init_turns.text = ""
		correct = false
	if !$NewGame/VBoxContainer/turns_phs.text.is_valid_integer():
		$NewGame/VBoxContainer/turns_phs.text = ""
		correct = false
	if !$NewGame/VBoxContainer/total_turns.text.is_valid_integer():
		$NewGame/VBoxContainer/total_turns.text = ""
		correct = false
	if correct:
		var max_turns = int($NewGame/VBoxContainer/total_turns.text)
		var init_turns = int($NewGame/VBoxContainer/init_turns.text)
		var turns_phs = int($NewGame/VBoxContainer/turns_phs.text)
		$NewGame/VBoxContainer/duration.text = "DURACIÓN ( "+str( ceil( (max_turns-init_turns) / turns_phs ) )+"hs )"
	else: $NewGame/VBoxContainer/duration.text = "DURACIÓN ( - )"

func onClickDelete():
	if !current_own_game: return
	if $NewGame/btn_delete.text != "SEGURO?":
		$NewGame/btn_delete.text = "SEGURO?"
		return
	$NewGame/btn_delete.disabled = true
	FM.delete_path("games/"+current_own_game.name)
	yield(FM,"complete_remove")
# warning-ignore:return_value_discarded
	get_tree().reload_current_scene()
