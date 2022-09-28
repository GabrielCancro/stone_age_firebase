extends Control

export var value = 0
export var step = 1
export var minim = 0
export var maxim = 10
export var label = ""

signal change
# Called when the node enters the scene tree for the first time.
func _ready():
	$dec.connect("button_down",self,"onDec")
	$inc.connect("button_down",self,"onInc")
	$Label.text = str(value)+label

func onDec():
	value -= step
	value = max(minim,value)
	$Label.text = str(value)+label
	emit_signal("change")

func onInc():
	value += step
	value = min(maxim,value)
	$Label.text = str(value)+label
	emit_signal("change")
