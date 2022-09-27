extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	showFriendList()
	CLOCK.init()
	$Title/btn_cancel.connect("button_down",self,"onCancelClick")
	$Panel/btn_create.connect("button_down",self,"onCreateClick")

func showFriendList():
	if !"friends" in GC.USER: GC.USER["friends"] = []
	for chk in $Panel/PlayerList/Scroll/VBox.get_children(): chk.queue_free()
	
	var chkUser = CheckBox.new()
	chkUser.text = GC.USER.name
	chkUser.pressed = true
	$Panel/PlayerList/Scroll/VBox.add_child(chkUser)
	
	for f in GC.USER["friends"]:
		var chk = CheckBox.new()
		chk.text = str(f)
		$Panel/PlayerList/Scroll/VBox.add_child(chk)
	
	for chk in $Panel/PlayerList/Scroll/VBox.get_children():
		(chk as CheckBox).connect("button_up",self,"onCheckPlayerList")

func onCancelClick():
	get_tree().change_scene("res://Scenes/Main.tscn")

func onCreateClick():
	FM.DATA.games_id += 1
	FM.push_var("","games_id",FM.DATA.games_id)
	yield(FM,"complete_push")
	var game_name = "partida "+str(FM.DATA.games_id)
	var players_data = {}
	for chk in $Panel/PlayerList/Scroll/VBox.get_children():
		if(chk.pressed): players_data[chk.text.to_upper()] = GC.get_player_start_config()
	FM.DATA.games[game_name] = {
		"name":game_name,
		"desc":game_name,
		"start_time": yield( CLOCK.get_time(),"complete" ),
		"start_os_date": OS.get_datetime(),
		"players": players_data,
		"own": GC.USER.name,
		"gameType": "StoneAge",
		
		"init_turns": 5,
		"max_turns": 40,
		"turns_phs": 10,
		"duration": 4,
		"wait_all": false,
	}
	FM.push_data("games/"+game_name)
	yield(FM,"complete_push")
	get_tree().change_scene("res://Scenes/Main.tscn")

func onCheckPlayerList():
	print("AAAAA")
	var cnt = 0
	for chk in $Panel/PlayerList/Scroll/VBox.get_children():
		if chk.get_index()==0: chk.pressed = true
		if(chk.pressed): cnt += 1
	$Panel/PlayerList/Title/cnt.text = "( "+str(cnt)+" )"
