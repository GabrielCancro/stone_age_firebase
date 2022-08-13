extends Node

var DATA = {}

func _ready():
	load_store_data()

func save_store_data():
	var file = File.new()
	file.open("user://stone_age_store.res", File.WRITE)
	file.store_string(var2str(DATA))
	file.close()
	print("STORE_DATA SAVE: ",DATA)

func load_store_data():      
	var file = File.new()
	file.open("user://stone_age_store.res", File.READ)
	DATA = str2var(file.get_as_text())
	if(!DATA): DATA = {}
	file.close()
	print("STORE_DATA LOAD: ",DATA)
