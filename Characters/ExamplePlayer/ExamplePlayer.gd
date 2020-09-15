extends "res://Characters/BaseFighter/Fighter.gd"

func _ready():
	connect("move", self, "Move", [])
	connect("jump", self, "Jump")

func Move(direction):
	print(direction)
