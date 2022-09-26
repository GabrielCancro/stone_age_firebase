extends Node2D

const FriendEntry := preload("res://Scenes/FriendEntry/FriendEntry.tscn")

onready var n_FriendList := $WinsPanel/scroll/FriendList

var OWN_GAME = null
var GameLine = preload("res://Panels/gameLine.tscn")
var winners = []

func _ready():
	$NewGamePopup.visible = false
	$User/Label.text = "Bienvenido "+GC.USER.name+"!"
	$User/btn_logout.connect("button_down",self,"onClick",["logout"])
	$User/btn_new.connect("button_down",self,"onClick",["new"])
	$User/btn_new_game.connect("button_down",self,"onClick",["new_game"])
	CLOCK.init()
	FM.pull_data()
	yield(FM,"complete_pull")
	$User/btn_logout.disabled = false
	update_winners()
	set_game_button()

func onClick(btn):
	if btn=="logout":
		GC.USER = null
		get_tree().change_scene("res://Scenes/Login.tscn")
	if btn=="new":
		$NewGamePopup.showNewGamePanel()
	if btn=="new_game":
		get_tree().change_scene("res://Scenes/CreateGame/CreateGame.tscn")

func set_game_button():
	if !"games" in FM.DATA:
		FM.DATA.games = {}
		FM.push_data("games")
		yield(FM,"complete_push")
	for i in FM.DATA.games:
		var game = FM.DATA.games[i]
		if GC.USER.name in game.players.keys():
			var btn = GameLine.instance()
			if(!"desc" in game): game.desc = game.name
			btn.get_node("Button/Title").text = game.desc + "  ("+game.own+")"
			if !"gameType" in game: game["gameType"] = "StoneAge"
			btn.get_node("Button/Desc").text = game.gameType
			if("finished"in game && game.finished): btn.get_node("Button/Desc").text += " (finalizada)"
			else: btn.get_node("Button/Desc").text += " (duración total "+str(game.duration)+"hs)"
			$Games/VBox.add_child(btn)
			if !GC.USER.name in game.players: btn.disabled = true
			btn.get_node("Button").connect("button_down",self,"onSelectGame",[game])

func update_winners():
	if !"friends" in GC.USER: GC.USER["friends"] = []
	if !"wins" in GC.USER: GC.USER["wins"] = 0
	winners = [ { "name": GC.USER.name, "wins": GC.USER.wins } ]
	for fr in GC.USER["friends"]:
		if fr in FM.DATA.users.keys():
			if !"wins" in FM.DATA.users[fr]: FM.DATA.users[fr]["wins"] = 0
			winners.append( { "name": FM.DATA.users[fr].name, "wins": FM.DATA.users[fr].wins } )
	winners.sort_custom(self, "customComparison")
	
	for c in n_FriendList.get_children():
		c.remove()
	
	for w in winners:
		var entry := FriendEntry.instance() as FriendEntry
		n_FriendList.add_child(entry)
		entry.update_data(w.name, w.wins)
		entry.connect("remove_friend", self, "_on_friend_removed")

func _on_friend_removed(_friend_name : String) -> void:
	if _friend_name == GC.USER.name || !(_friend_name in GC.USER["friends"]):
		return
	
	if !FM.check_user_exists(_friend_name): return
	
	GC.USER["friends"].erase(_friend_name)
	FM.DATA.users[GC.USER.name] = GC.USER
	FM.push_data("users/"+GC.USER.name)
	yield(FM,"complete_push")
	update_winners()

func add_friend(_friend_name : String):
	if _friend_name == GC.USER.name || _friend_name in GC.USER["friends"]:
		return
	
	if !FM.check_user_exists(_friend_name): return
	
	$WinsPanel/LineEdit/btn_add.disabled = true
	
	if !"friends" in GC.USER: GC.USER["friends"] = []
	GC.USER["friends"].append(_friend_name)		
	FM.DATA.users[GC.USER.name] = GC.USER
	FM.push_data("users/"+GC.USER.name)	
	yield(FM,"complete_push")
	
	$WinsPanel/LineEdit/btn_add.disabled = false
	update_winners()

func customComparison(a,b):
	return a.wins > b.wins

func onSelectGame(game):
	GC.GAME = game
	GC.PLAYER = game.players[GC.USER.name]
	$NewGamePopup.showNewGamePanel(game.name)
#	get_tree().change_scene("res://Scenes/Game.tscn")

func _on_btn_add_button_up():
	var _name = $WinsPanel/LineEdit.text.strip_edges().to_upper()
	$WinsPanel/LineEdit.text = ""
	add_friend(_name)
