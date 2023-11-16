extends PanelContainer

class_name UpgradeShop

@onready var upgrades_list: VBoxContainer = $VBoxContainer/HBoxContainer2/PanelContainer/UpgradesList
@export var upgrade_container_template: PackedScene

@onready var collector_count_upgrade : UpgradeContainer
@onready var collector_speed_upgrade : UpgradeContainer
@onready var level: Level = get_tree().get_first_node_in_group("level")


func _ready():

	collector_count_upgrade = upgrade_container_template.instantiate() as UpgradeContainer
	collector_speed_upgrade = upgrade_container_template.instantiate() as UpgradeContainer
	
	upgrades_list.add_child(collector_count_upgrade)
	upgrades_list.add_child(collector_speed_upgrade)
	
	collector_count_upgrade.update_upgrade(5, load("res://assets/items/water_bottle.png"), load("res://assets/characters/collector_icon.png"), level._get_max_collector_count(), "+1 Collector")
	collector_speed_upgrade.update_upgrade(10, load("res://assets/items/water_bottle.png"), load("res://assets/items/speed_icon.png"), 0, "+1 Speed")
	
	collector_count_upgrade.connect("commit_upgrade", _update_collector_count)
	collector_speed_upgrade.connect("commit_upgrade", _update_collector_speed)

	
func _update_collector_count(count: int):
	level._set_max_collector_count(count)
	
func _update_collector_speed(count: int):
	var modifier : float = 1 + (1.5*count/10)
	level._set_move_speed_modifier(modifier)

func _on_close_button_pressed():
	self.hide()

