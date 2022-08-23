extends ColorRect


func _ready():
	pass

func set_data(pl):
	var bonif = pl["end_bonif"]
	$HBox/name.text = pl.name
	$HBox/score.text = str(pl.score)
	$HBox/villager/top.text = str(pl.villager)+"x"+str(bonif.villager)
	$HBox/villager.text = format(pl.villager*bonif.villager)
	$HBox/camp/top.text = str(pl.camp)+"x"+str(bonif.camp)
	$HBox/camp.text = format(pl.camp*bonif.camp)
	$HBox/tool/top.text = str(pl.tool)+"x"+str(bonif.tool)
	$HBox/tool.text = format(pl.tool*bonif.tool)
	$HBox/build/top.text = str(pl.build)+"x"+str(bonif.build)
	$HBox/build.text = format(pl.build*bonif.build)
	$HBox/looter/top.text = "-"+str(pl.percent_looter*100)+"%"
	$HBox/looter.text = "-"+str(floor(pl.score*pl.percent_looter))
	$HBox/looter2/top.text = "("+str(pl.looter)+"x"+str(pl.points_per_looter)+")"
	$HBox/looter2.text = "+"+str(pl.looter*pl.points_per_looter)
	$HBox/total.text = str(pl.end_score)

func format(num):
	if num == 0: return "-"
	if num > 0: return "+"+str(num)+"  "
	if num < 0: return str(num)+"  "
