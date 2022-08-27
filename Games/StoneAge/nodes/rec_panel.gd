extends GridContainer

func _ready():
	update_panel()

func update_panel():
	for btn in get_children():
		if btn.name in GC.PLAYER: btn.text = str( GC.PLAYER[btn.name])
		else: btn.text = ""
