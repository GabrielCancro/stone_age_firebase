extends ColorRect

var table = null

func _ready():
	updateTable()

func updateTable():
	table = []
	$ScrollContainer/Control/Name.text = ""
	$ScrollContainer/Control/NameBr.text = ""
	$ScrollContainer/Control/Score.text = ""
	$ScrollContainer/Control/ScoreBr.text = ""
	$ScrollContainer/Control/Turn.text = ""	
	for p in GC.GAME.players.keys(): 
		table.append({"name":p,"score":GC.GAME.players[p].score,"turn":GC.GAME.players[p].turn})
	table.sort_custom(self, "customComparison")
	for p in table:
		if GC.USER.name == p.name: 
			$ScrollContainer/Control/NameBr.text += p.name.substr(0,10)+"\n"
			$ScrollContainer/Control/ScoreBr.text += str(p.score)+"\n"
		else: 
			$ScrollContainer/Control/NameBr.text += "\n"
			$ScrollContainer/Control/ScoreBr.text += "\n"
		$ScrollContainer/Control/Name.text += p.name.substr(0,10)+"\n"
		$ScrollContainer/Control/Score.text += str(p.score)+"\n"
		$ScrollContainer/Control/Turn.text += str(p.turn)+"\n"
	print(table)

func customComparison(a,b):
	return a.score > b.score
