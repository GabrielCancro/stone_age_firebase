extends Control

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
	if !"init_turns" in game: game.init_turns = 0
	$Grid/init_turns/LineEdit.text = str(game.init_turns)
	if !"max_turns" in game: game.max_turns = 0
	$Grid/total_turns/LineEdit.text = str(game.max_turns)
	if !"turns_phs" in game: game.turns_phs = 0
	$Grid/phs_turns/LineEdit.text = str(game.turns_phs)
	if !"duration" in game: game.duration = 0
	$Grid/duration/LineEdit.text = str(game.duration)
	if "wait_all"in game: $Grid/wait_all/CheckBox.pressed = game.wait_all

func get_config_data():
	if !check_config_errors(): return null
	return {
		"init_turns": int($Grid/init_turns/LineEdit.text),
		"max_turns": int($Grid/total_turns/LineEdit.text),
		"turns_phs": int($Grid/phs_turns/LineEdit.text),
		"duration": float($Grid/duration/LineEdit.text),
		"wait_all": $Grid/wait_all/CheckBox.pressed,
	}

func check_config_errors():
	var correct = true
	if !$Grid/init_turns/LineEdit.text.is_valid_integer():
		$Grid/init_turns/LineEdit.text = ""
		correct = false
	if !$Grid/phs_turns/LineEdit.text.is_valid_integer():
		$Grid/phs_turns/LineEdit.text = ""
		correct = false
	if !$Grid/total_turns/LineEdit.text.is_valid_integer():
		$Grid/total_turns/LineEdit.text = ""
		correct = false
	if !$Grid/final_await/LineEdit.text.is_valid_float():
		$Grid/final_await/LineEdit.text = ""
		correct = false
	if correct:
		var max_turns = int($Grid/total_turns/LineEdit.text)
		var init_turns = int($Grid/init_turns/LineEdit.text)
		var turns_phs = int($Grid/phs_turns/LineEdit.text)
		var hs_await = int($Grid/final_await/LineEdit.text)
		var duration = ceil( (max_turns-init_turns) / turns_phs ) + hs_await
		$Grid/duration/LineEdit.text = str(duration)
	else: $Grid/duration/LineEdit.text = "?"
	return correct

func get_player_start_config():
	return {
		"turn":0, "tool":0, "camp":0,"villager":5,"score":0,
		"food":20,"wood":0,"adobe":0,"stone":0,"gold":0,"build":0,"looter":0,
		"build_cards":[],"civ_cards":[],"civ_bonif":[],
	}
