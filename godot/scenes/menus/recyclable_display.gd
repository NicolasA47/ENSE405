extends GridContainer

@export var item_display_template: PackedScene
@onready var display_container: HBoxContainer = $DisplayBackground/DisplayContainer

var recyclable_display: ItemDisplay
var recyclable_count : int
var collector_display: ItemDisplay
var collector_count : int
func _ready():
	var recyclable_texture : String = "res://assets/items/water_bottle.png"
	var collector_texture : String = "res://assets/characters/collector_icon.png"
	var level: Level = get_tree().get_first_node_in_group("level")
	recyclable_count = level._get_current_recyclables()
	collector_count = level._get_max_collector_count()
	level.connect("recyclables_count_changed", _on_recyclables_count_changed)
	level.connect("collector_count_changed", _on_collector_count_changed)
	
	collector_display = item_display_template.instantiate() as ItemDisplay
	recyclable_display = item_display_template.instantiate() as ItemDisplay
		
	display_container.add_child(collector_display)
	collector_display.update_count(collector_count)
	collector_display.update_texture(collector_texture)
	
	display_container.add_child(recyclable_display)
	recyclable_display.update_count(recyclable_count)
	recyclable_display.update_texture(recyclable_texture)
	
func _on_recyclables_count_changed(count: int):
		recyclable_display.update_count(count)
		
func _on_collector_count_changed(count: int):
		collector_display.update_count(count)
		
		
