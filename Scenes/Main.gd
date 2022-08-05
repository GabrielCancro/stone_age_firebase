extends Node2D

func _ready():
	$User/Label.text = "Bienvenido "+GC.USER.name+"!"
	$User/btn_logout.connect("button_down",self,"onClick",["logout"])
	CLOCK.init()
	check_time()

func onClick(btn):
	if btn=="logout":
		GC.USER = null
		get_tree().change_scene("res://Scenes/Login.tscn")

func check_time():
	var nowTime = yield(CLOCK.get_time(),"complete")
	var played_time = nowTime-FM.DATA.games.gm1.start_time
	print("START TIME: ",FM.DATA.games.gm1.start_time)
	print("NOW TIME: ",nowTime)
	print("PLAYED TIME: ",played_time)
	print("TURNS: ",floor(played_time/25))
