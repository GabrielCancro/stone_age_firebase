extends Control

var gameData
signal on_select(gameData)

# Called when the node enters the scene tree for the first time.
func _ready():
	$Button.connect("button_down",self,"onClick")


func set_game_data(game):
	gameData = game
	$Button.disabled = !(GC.USER.name in game.players.keys())
	$Title.text = game.name
	$Own.text = game.own
	$Open.text = "PARTIDA\nCERRADA"
	if("isOpen"in game && game.isOpen): 
		$Open.text = "PARTIDA\nABIERTA"
		$Open.modulate = Color(2,2,1,1)
	if("finished"in game && game.finished): 
		$Duration.text = "(finalizada)"
		$ResTime.text = "La partida ya finalizó"
	else: 
		$Duration.text = "Duración "+str(game.duration)+"hs"
		var rt = floor( (GC.NOW_TIME - game.start_time) / (60*60) )
		$ResTime.text = "Faltan "+str(game.duration-rt)+"hs para finalizar"
	$Button.disabled = !(GC.USER.name in game.players.keys())

func onClick():
	print(gameData)
	emit_signal("on_select",gameData)
