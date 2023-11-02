extends GridContainer

@export var item_display_template: PackedScene
@onready var display_container: PanelContainer = $DisplayContainer

var displays: Array[ItemDisplay]
var recyclable_count : int
func _ready():
	var level: Level = get_tree().get_first_node_in_group("level")
	recyclable_count = level.current_recyclables
	level.connect("recyclables_count_changed", _on_recyclables_count_changed)
	
func _on_recyclables_count_changed(count: int):
	var current_display : ItemDisplay
	
	if displays.size() > 0:
		print("new count is: " + str(count))
		current_display = displays[0]
		current_display.update_count(count)
	else:
		var new_display: ItemDisplay = item_display_template.instantiate() as ItemDisplay
		display_container.add_child(new_display)
		new_display.update_count(count)
		displays.append(new_display)
		
		
