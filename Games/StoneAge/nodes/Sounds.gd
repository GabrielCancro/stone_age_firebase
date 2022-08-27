extends Node

var SOUNDS = {
	"villager_1": preload("res://Games/StoneAge/assets/sfx/villager_1.mp3"),
	"villager_2": preload("res://Games/StoneAge/assets/sfx/villager_2.mp3"),
	"villager_3": preload("res://Games/StoneAge/assets/sfx/villager_3.mp3"),
	"villager_4": preload("res://Games/StoneAge/assets/sfx/villager_4.mp3"),
	"villager_5": preload("res://Games/StoneAge/assets/sfx/villager_5.mp3"),
	"villager_6": preload("res://Games/StoneAge/assets/sfx/villager_6.mp3"),
	"villager_7": preload("res://Games/StoneAge/assets/sfx/villager_7.mp3"),
	"villager_8": preload("res://Games/StoneAge/assets/sfx/villager_8.mp3"),
	"on_turn": preload("res://Games/StoneAge/assets/sfx/on_turn.mp3"),
	"win": preload("res://Games/StoneAge/assets/sfx/win.mp3"),
	"wood": preload("res://Games/StoneAge/assets/sfx/wood.mp3"),
	"rec": preload("res://Games/StoneAge/assets/sfx/rec.mp3"),
	"extract": preload("res://Games/StoneAge/assets/sfx/extract.mp3"),
	"complete_turn": preload("res://Games/StoneAge/assets/sfx/complete_turn.mp3")
}

func _ready():
	GC.SOUND = self
	if StoreData.DATA["muted"]: $AudioStreamPlayer_MUSIC.free()

func play_villager():
	if StoreData.DATA["muted"]: return
	$AudioStreamPlayer_SFX.stream = SOUNDS["villager_"+str(randi()%8+1)]
	$AudioStreamPlayer_SFX.play()

func play_on_turn():
	if StoreData.DATA["muted"]: return
	$AudioStreamPlayer_SFX.stream = SOUNDS["on_turn"]
	$AudioStreamPlayer_SFX.play()

func play_complete_turn():
	if StoreData.DATA["muted"]: return
	$AudioStreamPlayer_SFX.stream = SOUNDS["complete_turn"]
	$AudioStreamPlayer_SFX.play()

func play_sfx(name):
	if StoreData.DATA["muted"]: return
	$AudioStreamPlayer_SFX.stream = SOUNDS[name]
	$AudioStreamPlayer_SFX.pitch_scale = 0.8 + randf() * 0.4
	$AudioStreamPlayer_SFX.play()
