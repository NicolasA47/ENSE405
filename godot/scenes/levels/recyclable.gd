extends Area2D

@export var state : String = "not collected"

var picked_up = false
var target_position = position

func _ready():
	pass
	
func _process(_delta):
	if picked_up:
		position = target_position
