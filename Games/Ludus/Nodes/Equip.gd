extends Panel

var selected = null

func _ready():
	for b in $VBox.get_children():
		if b.get_class() != "Button": continue
		(b as Button).connect("button_down",self,"onSelectArms",[b])

func onSelectArms(btn):
	if selected == btn: selected = null
	else: selected = btn
	for b in $VBox.get_children():
		if b.get_class() != "Button": continue
		if b==selected: b.modulate = Color(2,2,.5,1)
		else: b.modulate = Color(1,1,1,1)
	if selected: print(selected.text.to_upper())
