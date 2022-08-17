extends Node

func _ready():
	GC.SOUND = self
	if StoreData.DATA["muted"]: $AudioStreamPlayer_MUSIC.free()

func play_villager():
	if StoreData.DATA["muted"]: return
	$AudioStreamPlayer_SFX.stream = load("res://assets/sfx/villager_"+str(randi()%8+1)+".wav")
	$AudioStreamPlayer_SFX.play()

func play_on_turn():
	if StoreData.DATA["muted"]: return
	$AudioStreamPlayer_SFX.stream = load("res://assets/sfx/on_turn.mp3")
	$AudioStreamPlayer_SFX.play()

func play_complete_turn():
	if StoreData.DATA["muted"]: return
	$AudioStreamPlayer_SFX.stream = load("res://assets/sfx/complete_turn.mp3")
	$AudioStreamPlayer_SFX.play()

func play_sfx(name):
	if StoreData.DATA["muted"]: return
	$AudioStreamPlayer_SFX.stream = load("res://assets/sfx/"+name+".mp3")
	$AudioStreamPlayer_SFX.pitch_scale = 0.8 + randf() * 0.4
	$AudioStreamPlayer_SFX.play()
