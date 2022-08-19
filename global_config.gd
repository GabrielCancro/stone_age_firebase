extends Node

var version = "v0.2.0"
var USER = null
var GAME = null
var PLAYER = null
var LOCAL = null
var NOW_TIME = 0
var TOTAL_TURNS = 0
var DRAGING_ELEMENT = null
var WORK_VILLAGERS = 0
var BUILD_TO_CONSTRUCT = null
var CIV_TO_CONSTRUCT = null
var SOUND = null
var FINISHED = false #game is finished

signal complete_reload_data

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _process(delta):
	if DRAGING_ELEMENT:
		DRAGING_ELEMENT
		DRAGING_ELEMENT.position = DRAGING_ELEMENT.get_global_mouse_position() + DRAGING_ELEMENT.grabbed_offset

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
