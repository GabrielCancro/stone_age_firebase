class_name FriendEntry extends HBoxContainer

signal remove_friend(name)

onready var n_LabelName := $LabelName
onready var n_LabelWins := $LabelWins
onready var n_Button := $Button

func update_data(_name : String, _wins : int) -> void:
	n_LabelName.text = _name.strip_edges().to_upper()
	n_LabelWins.text = String(_wins)

func _on_Button_button_up():
	emit_signal("remove_friend", n_LabelName.text)
	remove()

func equals(_name : String) -> bool:
	return _name.to_upper() == n_LabelName.text
	
func remove() -> void:
	call_deferred("queue_free")
