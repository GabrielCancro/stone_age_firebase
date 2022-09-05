extends Control

var data = {}

func _ready():
	$add.visible = false
	update_chars()

func update_chars():
	data = GC.PLAYER
	$hp.text = "HP "+str(data.hp)
	$atk.text = "ATK "+str(data.atk)
	$atk/type.text = data.atk_type
	$def.text = "DEF "+str(data.def)
	$def/esp.text = "ESPADA +"+str(data.def_esp)
	$def/lan.text = "LANZA +"+str(data.def_lan)
	$def/maz.text = "MAZA +"+str(data.def_maz)
	$en.text = "ENERGÍA "+str(data.en)+"/"+str(data.en_max)
	$mo.text = "ORO x"+str(data.mo)

func add_char(ch,cnt):
	$add.visible = true
	$add.text = "+"+str(cnt)
	$add.rect_position = get_node(ch).rect_position
	$add/Tween.interpolate_property($add,"rect_position",$add.rect_position,$add.rect_position+Vector2(0,-20),1,Tween.TRANS_EXPO,Tween.EASE_OUT)
	$add/Tween.start()
	data[ch] += cnt
	update_chars()
	yield($add/Tween,"tween_completed")
	yield(get_tree().create_timer(.5),"timeout")
	$add.visible = false
