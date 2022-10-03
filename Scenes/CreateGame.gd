extends Control

var configValues
# Called when the node enters the scene tree for the first time.
func _ready():
	showFriendList()
	CLOCK.init()
	$Creating.visible = false
	$Title/btn_cancel.connect("button_down",self,"onCancelClick")
	$Panel/btn_create.connect("button_down",self,"onCreateClick")
	$Panel/Options/Scroll/Grid/init_turns/NumberSelector.connect("change",self,"onChangeConfig")
	$Panel/Options/Scroll/Grid/turns_phs/NumberSelector.connect("change",self,"onChangeConfig")
	$Panel/Options/Scroll/Grid/open_close/OptionButton.connect("item_selected",self,"onChangeConfig")
	$Panel/Options/Scroll/Grid/total_turns/NumberSelector.connect("change",self,"onChangeConfig")
	$Panel/Options/Scroll/Grid/final_await/NumberSelector.connect("change",self,"onChangeConfig")
	$Panel/Options/Scroll/Grid/early_finish/CheckBox.connect("button_up",self,"onChangeConfig")
	$Panel/Options/Scroll/Grid/wait_all/CheckBox.connect("button_up",self,"onChangeConfig")
	onChangeConfig()

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
	$Creating.visible = true
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
	}
	for cnf in configValues.keys(): FM.DATA.games[game_name][cnf] = configValues[cnf]
	FM.push_data("games/"+game_name)
	yield(FM,"complete_push")
	get_tree().change_scene("res://Scenes/Main.tscn")

func onChangeConfig(id=-1):
	configValues = {
		"init_turns": $Panel/Options/Scroll/Grid/init_turns/NumberSelector.value,
		"turns_phs": $Panel/Options/Scroll/Grid/turns_phs/NumberSelector.value,
		"max_turns": $Panel/Options/Scroll/Grid/total_turns/NumberSelector.value,
		"isOpen": ($Panel/Options/Scroll/Grid/open_close/OptionButton.selected == 1),
		"duration": 0,
		"final_await": $Panel/Options/Scroll/Grid/final_await/NumberSelector.value,
		"wait_all": $Panel/Options/Scroll/Grid/wait_all/CheckBox.pressed,
		"early_finish": $Panel/Options/Scroll/Grid/early_finish/CheckBox.pressed,
	}
	
	var duration = ceil( (configValues.max_turns - configValues.init_turns) / configValues.turns_phs )
	configValues.duration = duration + configValues.final_await
	$Panel/Options/Title/total_hs.text = str(configValues.duration)+" hs"
	
	if(configValues.wait_all):
		$Panel/Options/Scroll/Grid/final_await.modulate.a = .2
		$Panel/Options/Title/total_hs.text = "?? hs"
	else: $Panel/Options/Scroll/Grid/final_await.modulate.a = 1


func onCheckPlayerList():
	var cnt = 0
	for chk in $Panel/PlayerList/Scroll/VBox.get_children():
		if chk.get_index()==0: chk.pressed = true
		if(chk.pressed): cnt += 1
	$Panel/PlayerList/Title/cnt.text = "( "+str(cnt)+" )"
