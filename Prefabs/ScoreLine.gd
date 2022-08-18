extends ColorRect


func _ready():
	pass

func set_data(pl):
	var bonif = pl["end_bonif"]
	$HBox/name.text = pl.name
	$HBox/score.text = str(pl.score)
	$HBox/villager/top.text = str(pl.villager)+"x"+str(bonif.villager)
	$HBox/villager.text = str(pl.villager*bonif.villager)
	$HBox/camp/top.text = str(pl.camp)+"x"+str(bonif.camp)
	$HBox/camp.text = str(pl.camp*bonif.camp)
	$HBox/tool/top.text = str(pl.tool)+"x"+str(bonif.tool)
	$HBox/tool.text = str(pl.tool*bonif.tool)
	$HBox/build/top.text = str(pl.build)+"x"+str(bonif.build)
	$HBox/build.text = str(pl.build*bonif.build)
	$HBox/looter/top.text = ""
	$HBox/looter.text = "-"
	$HBox/total.text = str(pl.end_score)
