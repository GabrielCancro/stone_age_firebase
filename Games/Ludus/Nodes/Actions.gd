extends Panel

onready var cnt_lbl = $VBoxValues/Label

func _ready():
	for b in $VBox.get_children():
		if b.get_class() != "Button": continue
		(b as Button).connect("button_down",self,"onSelectAction",[b])
	for b in $VBoxValues.get_children():
		if b.get_class() != "Button": continue
		(b as Button).connect("button_down",self,"onDeselectAction",[b])

func onSelectAction(btn):
	print(btn.text," +1")
	if int(cnt_lbl.text)<=0: return
	cnt_lbl.text = str( int(cnt_lbl.text)-1 )
	var btnVal = $VBoxValues.get_child( btn.get_index() )
	btnVal.text = str( int(btnVal.text)+1 )

func onDeselectAction(btn):
	print(btn.text," -1")
	if int(btn.text)<=0: return	
	btn.text = str( int(btn.text)-1 )
	cnt_lbl.text = str( int(cnt_lbl.text)+1 )

func get_settings():
	var result = {}
	for b in $VBoxValues.get_children():
		if b.get_class() != "Button": continue
		result[b.name] = str(b.text)
	return result
	
	
