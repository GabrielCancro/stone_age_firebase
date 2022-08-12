extends ColorRect

var players = []
# Called when the node enters the scene tree for the first time.
func _ready():
	visible = false
	$NewGame/btn_back.connect("button_down",self,"onClickBack")
	$NewGame/btn_add.connect("button_down",self,"onClickAddPLayer")
	$NewGame/btn_create.connect("button_down",self,"onClickCreateNewGame")	

func showNewGamePanel():
	visible = true
	$NewGame.visible = true
	$NewGame/Label_error.text = ""
	players = [GC.USER.name]
	showPlayersList()
	
func onClickBack():
	visible = false

func onClickAddPLayer():
	var name = $NewGame/LineEdit.text.to_upper()
	if(players.find(name)!=-1):
		$NewGame/Label_error.text = "El jugador\nya esta en lista"
		yield(get_tree().create_timer(2),"timeout")
		$NewGame/Label_error.text = ""
	elif !name in FM.DATA.users:
		$NewGame/Label_error.text = "Jugador\nInexistnte"
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
	var game_name = "partida "+str(FM.DATA.games_id)
	var players_data = {}
	for nm in players:
		players_data[nm.to_upper()] = {
			"turn":0, "camp":0,"villager":5,"score":0,
			"food":12,"wood":0,"adobe":0,"stone":0,"gold":0,
			"build_cards":[],"civ_cards":[],"civ_bonif":[],
		}
	FM.DATA.games[game_name] = {
		"name":game_name,
		"start_time": yield( CLOCK.get_time(),"complete" ),
		"start_os_date": OS.get_datetime(),
		"players": players_data,
		"max_turns": 100,
	}
	FM.push_data("games/"+game_name)
	yield(FM,"complete_push")
	get_tree().reload_current_scene()
