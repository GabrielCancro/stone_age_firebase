extends Control

var CONFIG_NAMES=["init_turns","phs_turns","duel_period","total_duels","duration"]
func _ready():
	pass

func _input(event):
	if event is InputEventKey and event.pressed:
		yield(get_tree().create_timer(.1),"timeout")
		check_config_errors()

func setReadOnly(val=true):
	$ReadOnlyStop.visible = val
	check_config_errors()

func set_data_from_game(game):
	for nm in CONFIG_NAMES:
		var le = get_node("Grid/"+nm+"/LineEdit")
		if !nm in game: game[nm] = 0
		le.text = str(game[nm])

func get_config_data():
	if !check_config_errors(): return null
	var result = {}
	for nm in CONFIG_NAMES:
		var le = get_node("Grid/"+nm+"/LineEdit")
		result[nm] = int(le.text)
	return result

func check_config_errors():
	var correct = true
	for nm in CONFIG_NAMES:
		var le = get_node("Grid/"+nm+"/LineEdit")
		if !le.text.is_valid_integer(): 
			le.text = ""
			correct = false
	if correct:
		var total_turns = int($Grid/total_duels/LineEdit.text) * int($Grid/duel_period/LineEdit.text)
		total_turns -= int($Grid/init_turns/LineEdit.text)
		var total_hs = ceil( total_turns/int($Grid/phs_turns/LineEdit.text) )
		$Grid/duration/LineEdit.text = str(total_hs)
	else: $Grid/duration/LineEdit.text = "?"
	return correct
