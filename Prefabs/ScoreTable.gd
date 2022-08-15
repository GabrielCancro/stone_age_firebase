extends ColorRect

var table = null

func _ready():
	updateTable()

func updateTable():
	table = []
	$Name.text = ""
	$NameBr.text = ""
	$Score.text = ""
	$ScoreBr.text = ""
	$Turn.text = ""	
	for p in GC.GAME.players.keys(): 
		table.append({"name":p,"score":GC.GAME.players[p].score,"turn":GC.GAME.players[p].turn})
	table.sort_custom(self, "customComparison")
	for p in table:
		if GC.USER.name == p.name: 
			$NameBr.text += p.name+"\n"
			$ScoreBr.text += str(p.score)+"\n"
		else: 
			$NameBr.text += "\n"
			$ScoreBr.text += "\n"
		$Name.text += p.name+"\n"
		$Score.text += str(p.score)+"\n"
		$Turn.text += str(p.turn)+"\n"
	print(table)

func customComparison(a,b):
	return a.score > b.score
