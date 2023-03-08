extends Node2D

const FriendEntry := preload("res://Scenes/FriendEntry/FriendEntry.tscn")

var GameInfoScene = preload("res://Scenes/GameInfo/GameInfo.tscn")
onready var n_FriendList := $WinsPanel/scroll/FriendList

var OWN_GAME = null
var GameEntry = preload("res://Scenes/GameEntry/GameEntry.tscn")
var winners = []

func _ready():
#	$NewGamePopup.visible = false
	$lb_user.text = GC.USER.name
	$btn_logout.connect("button_down",self,"onClick",["logout"])
	$btn_new_game.connect("button_down",self,"onClick",["new_game"])
	$btn_new_game.visible = false
	CLOCK.init()
	FM.pull_data()
	yield(FM,"complete_pull")
	$btn_logout.disabled = false
#	update_winners()
	update_friend_list()
	set_game_button()
	check_own_game()

func onClick(btn):
	if btn=="logout":
		GC.USER = null
		get_tree().change_scene("res://Scenes/LoginNew.tscn")
	if btn=="new":
		$NewGamePopup.showNewGamePanel()
	if btn=="new_game":
#		get_tree().change_scene("res://Scenes/CreateGame.tscn")
#		return
		if !GC.OWN_GAME_ID: get_tree().change_scene("res://Scenes/CreateGame.tscn")
		else: onSelectGame(FM.DATA.games[GC.OWN_GAME_ID])

func set_game_button():
	if !"games" in FM.DATA:
		FM.DATA.games = {}
		FM.push_data("games")
		yield(FM,"complete_push")
	_add_break("Tus Partidas Activas")
	for i in FM.DATA.games: if(!"is_open" in FM.DATA.games[i]): FM.DATA.games[i]["is_open"] = false
	for i in FM.DATA.games: if(GC.USER.name in FM.DATA.games[i].players): _add_game_entry(i)
	_add_break("Partidas Públicas")
	for i in FM.DATA.games: if(!GC.USER.name in FM.DATA.games[i].players && FM.DATA.games[i].is_open): _add_game_entry(i)
	_add_break("Partidas Cerradas")
	for i in FM.DATA.games: if(!GC.USER.name in FM.DATA.games[i].players && !FM.DATA.games[i].is_open): _add_game_entry(i)
	CLOCK.get_time()
	GC.NOW_TIME =  yield( CLOCK,"complete" )
	for GE in $GameList/Games/VBox.get_children(): if(GE.name.find('GameEntry')!=-1): GE.updateDuration()

func _add_game_entry(i):
	var ge = GameEntry.instance()
	ge.set_game_data(FM.DATA.games[i])
	ge.connect("on_select",self,"onSelectGame")
	$GameList/Games/VBox.add_child(ge)

func _add_break(txt="------"):
	var lbl = Label.new()
	lbl.text = txt
	$GameList/Games/VBox.add_child(lbl)
		
#func update_winners():
#	if !"friends" in GC.USER: GC.USER["friends"] = []
#	if !"wins" in GC.USER: GC.USER["wins"] = 0
#	winners = [ { "name": GC.USER.name, "wins": GC.USER.wins } ]
#	for fr in GC.USER["friends"]:
#		if fr in FM.DATA.users.keys():
#			if !"wins" in FM.DATA.users[fr]: FM.DATA.users[fr]["wins"] = 0
#			winners.append( { "name": FM.DATA.users[fr].name, "wins": FM.DATA.users[fr].wins } )
#	winners.sort_custom(self, "customComparison")
#
#	for c in n_FriendList.get_children():
#		c.remove()
#
#	for w in winners:
#		var entry := FriendEntry.instance() as FriendEntry
#		n_FriendList.add_child(entry)
#		entry.update_data(w.name, w.wins)
#		entry.connect("remove_friend", self, "_on_friend_removed")

func update_friend_list():
	for c in n_FriendList.get_children(): c.remove()
	
	if !"friends" in GC.USER: GC.USER["friends"] = []
	
	FM.pull_users()
	yield(FM,"complete_pull")
	
	for fr in GC.USER["friends"]:
		if fr in FM.USERS.keys():
			var entry := FriendEntry.instance() as FriendEntry
			n_FriendList.add_child(entry)
			entry.update_data(fr, 0)
			entry.connect("remove_friend", self, "_on_friend_removed")

func _on_friend_removed(_friend_name : String) -> void:
	if _friend_name == GC.USER.name || !(_friend_name in GC.USER["friends"]):
		return
	
	if !FM.check_user_exists(_friend_name): return
	
	GC.USER["friends"].erase(_friend_name)
	FM.DATA.users[GC.USER.name] = GC.USER
	FM.update_current_user_friends()
	yield(FM,"complete_push")
#	update_winners()
	update_friend_list()

func add_friend(_friend_name : String):
	if _friend_name == GC.USER.name || _friend_name in GC.USER["friends"]:
		return
	
	if !FM.check_user_exists(_friend_name): return	
	$WinsPanel/LineEdit/btn_add.disabled = true
	
	if !"friends" in GC.USER: GC.USER["friends"] = []
	GC.USER["friends"].append(_friend_name)
	FM.USERS[GC.USER.name] = GC.USER
	FM.update_current_user_friends()
	yield(FM,"complete_push")
	
	$WinsPanel/LineEdit/btn_add.disabled = false
#	update_winners()
	update_friend_list()

func customComparison(a,b):
	return a.wins > b.wins

func onSelectGame(game):
	GC.GAME = game
	var GInfo = GameInfoScene.instance()
	add_child(GInfo)

func _on_btn_add_button_up():
	var _name = $WinsPanel/LineEdit.text.strip_edges().to_upper()
	$WinsPanel/LineEdit.text = ""
	add_friend(_name)
	
func check_own_game():
	GC.OWN_GAME_ID = null
	for game in FM.DATA.games:
		if GC.USER.name == FM.DATA.games[game].own:
			GC.OWN_GAME_ID = game
			break;
	if GC.OWN_GAME_ID: $btn_new_game/lb_enter.text = "IR A MI PARTIDA"
	$btn_new_game.visible = true
