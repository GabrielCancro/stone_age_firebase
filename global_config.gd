extends Node

var USER = null
var GAME = null
var PLAYER = null
var LOCAL = null
var NOW_TIME = 0
var TOTAL_TURNS = 0
var DRAGING_ELEMENT = null

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
	emit_signal("complete_reload_data")
