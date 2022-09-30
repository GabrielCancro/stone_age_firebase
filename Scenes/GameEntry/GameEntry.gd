extends Control

var gameData
signal on_select(gameData)

# Called when the node enters the scene tree for the first time.
func _ready():
	$Button.connect("button_down",self,"onClick")


func set_game_data(game):
	gameData = game
	$Title.text = game.name
	$Own.text = "Creada por "+game.own
	if("isOpen"in game && game.isOpen): 
		$OpenIcon.texture = preload("res://assets/world_icon.png")
		$OpenIcon.modulate = Color("ced48d")
		$Players.text = str(game.players.size())+"/6"
	else:
		$OpenIcon.texture = preload("res://assets/lock_icon.png")
		$Players.text = str(game.players.size())+"/"+str(game.players.size())
	$Time/Duration.text = str(game.duration)+"hs"
	if("finished"in game && game.finished):		
		$Time/ResTime.text = "finalizada"
	else: 
		$Time/Duration.text = str(game.duration)+"hs"
		$Time/ResTime.text = "en juego.."
		
	if( !game.isOpen && !GC.USER.name in game.players.keys() ): $Button.disabled = true 
	if( game.isOpen && game.players.keys().size()>=6 ): $Button.disabled = true
	if($Button.disabled): $Button.modulate.a = .3

func updateDuration():
	var rt = floor( (GC.NOW_TIME - gameData.start_time) / (60*60) )
	rt = max(0,gameData.duration-rt)
	$Time/ResTime.text = "quedan "+str(rt)+"hs"

func onClick():
	print(gameData)
	emit_signal("on_select",gameData)
