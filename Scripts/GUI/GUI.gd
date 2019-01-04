extends CanvasLayer

func _ready():
	Global.GUI = self


func update_GUI(lives, points):
	$ColorRect/HBoxContainer/LivesCount.text = str(lives)
	$ColorRect/HBoxContainer/PointsCount.text = str(points)
