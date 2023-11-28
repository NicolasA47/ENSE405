extends Node

class_name Wallet

@export var plastic_balance : int = 0
@export var scrap_metal_balance : int = 0
@export var electronics_balance : int = 0

@onready var level: Level = get_tree().get_first_node_in_group("level")


func make_verified_purchase(plastic_cost: int, scrap_metal_cost: int, electronics_cost: int) -> bool:
	if plastic_balance >= plastic_cost and scrap_metal_balance >= scrap_metal_cost and electronics_balance >= electronics_cost:
		plastic_balance -= plastic_cost
		scrap_metal_balance -= scrap_metal_cost
		electronics_balance -= electronics_cost
		return true
	else:
		return false

func init_default_balance():
	plastic_balance = 0
	scrap_metal_balance = 0
	electronics_balance = 0
