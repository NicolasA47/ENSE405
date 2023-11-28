extends GridContainer

@export var item_display_template: PackedScene
@onready var display_container: HBoxContainer = $DisplayBackground/DisplayContainer

var plastic_display: ItemDisplay
var plastic_count : int
var collector_display: ItemDisplay
var collector_count : int
var scrap_metal_display : ItemDisplay
var scrap_metal_count : int
var electronics_display : ItemDisplay
var electronics_count : int

func _ready():
	var plastic_texture : String = "res://assets/items/water_bottle.png"
	var collector_texture : String = "res://assets/characters/collector_icon.png"
	var scrap_metal_texture : String = "res://assets/items/scrap_metal_32x32.png"
	var electronics_texture : String = "res://assets/items/circuit_board_32x32.png"
	
	var level: Level = get_tree().get_first_node_in_group("level")
	collector_count = level._get_max_collector_count()
	plastic_count = 0
	scrap_metal_count = 0
	electronics_count = 0
	
	level.connect("wallet_changed", _on_plastic_count_changed)
	level.connect("collector_count_changed", _on_collector_count_changed)
	level.connect("wallet_changed", _on_scrap_metal_count_changed)
	level.connect("wallet_changed", _on_electronics_count_changed)
	
	collector_display = item_display_template.instantiate() as ItemDisplay
	plastic_display = item_display_template.instantiate() as ItemDisplay
	scrap_metal_display = item_display_template.instantiate() as ItemDisplay
	electronics_display = item_display_template.instantiate() as ItemDisplay
		
	display_container.add_child(collector_display)
	collector_display.update_count(collector_count)
	collector_display.update_texture(collector_texture)
	
	display_container.add_child(plastic_display)
	plastic_display.update_count(plastic_count)
	plastic_display.update_texture(plastic_texture)
	
	display_container.add_child(scrap_metal_display)
	scrap_metal_display.update_count(scrap_metal_count)
	scrap_metal_display.update_texture(scrap_metal_texture)
	
	display_container.add_child(electronics_display)
	electronics_display.update_count(electronics_count)
	electronics_display.update_texture(electronics_texture)
	
func _on_collector_count_changed(count: int):
		collector_display.update_count(count)
		
func _on_plastic_count_changed(wallet: Wallet):
		plastic_display.update_count(int(wallet.plastic_balance))
		
func _on_scrap_metal_count_changed(wallet: Wallet):
		scrap_metal_display.update_count(int(wallet.scrap_metal_balance))
		
func _on_electronics_count_changed(wallet: Wallet):
		electronics_display.update_count(int(wallet.electronics_balance))
		
		
