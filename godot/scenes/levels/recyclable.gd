extends Area2D

class_name Recyclable

@export var state : String = "not collected"
@export var type : String
@onready var recyclable_texture : Sprite2D = $Recyclable

var picked_up = false
var target_position = position

func _ready():
	pass
	
func _process(_delta):
	if picked_up:
		position = target_position
		
		
func _init_from_string(recyclable_type : String):
	if (recyclable_type == "plastic"):
		init_plastic()
	elif (recyclable_type == "scrap_metal"):
		init_scrap_metal()
	elif (recyclable_type == "electronic"):
		init_electronic()
		
	

func init_plastic():
	type = "plastic"
	$Recyclable.texture = load("res://assets/items/water_bottle.png")
	
func init_scrap_metal():
	type = "scrap_metal"
	$Recyclable.texture = load("res://assets/items/scrap_metal_32x32.png")
	
func init_electronic():
	type = "electronic"
	$Recyclable.texture = load("res://assets/items/circuit_board_32x32.png")
	
