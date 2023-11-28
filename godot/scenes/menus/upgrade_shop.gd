extends PanelContainer

class_name UpgradeShop

@onready var upgrades_list: VBoxContainer = $VBoxContainer/HBoxContainer2/PanelContainer/UpgradesList
@export var upgrade_container_template: PackedScene

@onready var collector_count_upgrade : UpgradeContainer
@onready var collector_speed_upgrade : UpgradeContainer
@onready var scrap_metal_upgrade : UpgradeContainer
@onready var electronics_upgrade : UpgradeContainer
@onready var recyclables_spawn_rate_upgrade : UpgradeContainer
@onready var max_recyclables_upgrade : UpgradeContainer
@onready var level: Level = get_tree().get_first_node_in_group("level")


func _ready():

	collector_count_upgrade = upgrade_container_template.instantiate() as UpgradeContainer
	collector_speed_upgrade = upgrade_container_template.instantiate() as UpgradeContainer
	scrap_metal_upgrade = upgrade_container_template.instantiate() as UpgradeContainer
	electronics_upgrade = upgrade_container_template.instantiate() as UpgradeContainer
	recyclables_spawn_rate_upgrade = upgrade_container_template.instantiate() as UpgradeContainer

	
	upgrades_list.add_child(collector_count_upgrade)
	upgrades_list.add_child(collector_speed_upgrade)
	upgrades_list.add_child(recyclables_spawn_rate_upgrade)
	recyclables_spawn_rate_upgrade.hide()
	collector_speed_upgrade.hide()
	upgrades_list.add_child(scrap_metal_upgrade)
	upgrades_list.add_child(electronics_upgrade)
	electronics_upgrade.hide()

	
	collector_count_upgrade.update_upgrade(5, 0, 0, load("res://assets/characters/collector_icon.png"), level._get_max_collector_count(), "+1 Collector", false)
	collector_speed_upgrade.update_upgrade(0, 5, 0, load("res://assets/items/speed_icon.png"), 0, "+1 Speed", false)
	recyclables_spawn_rate_upgrade.update_upgrade(0, 0, 5, load("res://assets/items/recylclables_spawn_increase.png"), 0, "Recyclables\nIncrease", false)
	scrap_metal_upgrade.update_upgrade(15, 0, 0, load("res://assets/items/scrap_metal_32x32.png"), 0, "Scrap Metal\nUnlock", true)
	electronics_upgrade.update_upgrade(15, 15, 0, load("res://assets/items/circuit_board_32x32.png"), 0, "Electronics\nUnlock", true)
	
	collector_count_upgrade.connect("commit_upgrade", _update_collector_count)
	collector_speed_upgrade.connect("commit_upgrade", _update_collector_speed)
	scrap_metal_upgrade.connect("commit_upgrade", _update_scrap_metal_upgrade)
	electronics_upgrade.connect("commit_upgrade", _update_electronics_upgrade)
	recyclables_spawn_rate_upgrade.connect("commit_upgrade", _update_recyclables_spawn_rate_upgrade)

func _update_collector_count(count: int):
	level._set_max_collector_count(count)
	
func _update_collector_speed(count: int):
	var modifier : float = 1 + (1.5*count/10)
	level._set_move_speed_modifier(modifier)
	
func _update_scrap_metal_upgrade(count: int):
	level.unlocked_recyclables.append("scrap_metal")
	level.collection_point.sprite.texture = load("res://assets/buildings/ME_Singles_City_Props_32x32_Container_House_1.png")
	level.clear_recyclables()
	electronics_upgrade.show()
	collector_speed_upgrade.show()
	scrap_metal_upgrade.hide()

func _update_electronics_upgrade(count: int):
	level.unlocked_recyclables.append("electronic")
	level.collection_point.sprite.texture = load("res://assets/buildings/ME_Singles_City_Props_32x32_Power_House_1.png")
	level.clear_recyclables()
	recyclables_spawn_rate_upgrade.show()
	electronics_upgrade.hide()
	
func _update_recyclables_spawn_rate_upgrade(count: int):
	var decay_factor : float = 0.9
	var new_value = 5 * (decay_factor ** count)
	
	level._set_number_of_recyclables_per_spawn(new_value)
	
func _on_close_button_pressed():
	self.hide()

