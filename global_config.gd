extends Node

var version = 1000400
var USER = null
var GAME = null
var PLAYER = null
var LOCAL = null
var NOW_TIME = 0
var ADVANCED_TIME = 0
var TOTAL_TURNS = 0
var WORK_VILLAGERS = 0
var BUILD_TO_CONSTRUCT = null
var CIV_TO_CONSTRUCT = null
var SOUND = null
var OWN_GAME_ID = null # if USER has any own game
var FINISHED = false #game is finished

signal complete_reload_data
signal complete_push

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func reload_data():
	FM.pull_data()
	yield(FM,"complete_pull")
	if USER: USER = FM.DATA.users[USER.name]
	if GAME: GAME = FM.DATA.games[GAME.name]
	if PLAYER: PLAYER = FM.DATA.games[GAME.name].players[USER.name]
	FINISHED = ( PLAYER.turn >= GAME.max_turns )
	emit_signal("complete_reload_data")

func get_total_turns():
	var hours_past = floor((GC.NOW_TIME - GC.GAME.start_time)/(60*60))
	var _total_turns = GC.GAME.init_turns + hours_past * GC.GAME.turns_phs # turns per hour
	if _total_turns > GC.GAME.max_turns: _total_turns = GC.GAME.max_turns
	return _total_turns

func get_version_str(ver = version):
	var st = "v" + str(int(str(ver).substr(1,2))) + "."
	st += str(int(str(ver).substr(3,2))) + "."
	st += str(int(str(ver).substr(5,2)))
	return st

func get_player_start_config():
	return {
		"turn":0, "tool":0, "camp":0,"villager":5,"score":0,
		"food":20,"wood":0,"adobe":0,"stone":0,"gold":0,"build":0,"looter":0,
		"build_cards":[],"civ_cards":[],"civ_bonif":[],
	}

func push_game(): pass
