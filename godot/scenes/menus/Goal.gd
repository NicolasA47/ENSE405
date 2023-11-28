extends Node

class_name Goal

@export var goal_text : String
@export var target_ammount : int = 1
@export var current_ammount : int = 0
@export var current_goal_increment : int = 0
@onready var goal_fact : String = ""
@onready var percent_completed : float = 0


func get_percent_completed():
	percent_completed = float(current_ammount)/float(target_ammount)
	return percent_completed
