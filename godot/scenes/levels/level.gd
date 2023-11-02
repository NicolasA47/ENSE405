extends Node2D

class_name Level

@export var max_recyclable_count: int = 8
@export var max_collector_count: int = 3
@export var starting_recyclables : int = 6
@export var current_recyclables : int = 0

var rng = RandomNumberGenerator.new()
var recycling_collector = preload("res://scenes/levels/collector.tscn")
var recyclable = preload("res://scenes/levels/recyclable.tscn")
var recyclables_list = []
var collectors_list = []

signal recyclables_count_changed

func _on_area_2d_input_event(_viewport, event, _shape_idx):
	if event.is_action_pressed("left_click"):
		_spawn_collector(event.position.x, event.position.y - 100)
		

func _ready():
	for i in range(starting_recyclables):
		_spawn_recyclable()
	var timer = Timer.new()

	timer.set_wait_time(4.0)
	timer.set_one_shot(false)
	timer.connect("timeout", Callable(self, "_spawn_recyclable"))
	add_child(timer)
	timer.start()
	
func _spawn_collector(position_x, position_y):
	if(collectors_list.size() < max_collector_count and recyclables_list.size() > 0):

		var instance = recycling_collector.instantiate()
		instance.position.x = position_x
		instance.position.y = position_y
		collectors_list.append(instance)
		add_child(instance)
		var player_starting_position = instance.position
		instance.returning_started.connect(self._on_returning_started.bind(recyclables_list[0]))
		instance.movement_complete.connect(self._on_movement_complete.bind(instance, recyclables_list[0]))
		
		instance.move_player_to(instance.position, recyclables_list[0].position)

		recyclables_list.remove_at(0)
		
func _on_returning_started(recyclable):
		recyclable.queue_free()
		recyclables_list.erase(recyclable)
		
func _on_movement_complete(instance, _recyclable):
	collectors_list.erase(instance)
	instance.queue_free()
	current_recyclables += 1
	emit_signal("recyclables_count_changed", current_recyclables)
	
func _spawn_recyclable():
	if(recyclables_list.size() < max_recyclable_count):
		var view_width = get_viewport_rect().size.x
		var view_height = get_viewport_rect().size.y
		var instance = recyclable.instantiate()
		rng.randomize()
		instance.position.x = rng.randi_range(0, view_width)
		instance.position.y = rng.randi_range(0, view_height-150)
		add_child(instance)
		recyclables_list.append(instance)
