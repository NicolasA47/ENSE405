extends Node2D

class_name Level

@export var max_recyclable_count: int = 20
@export var starting_recyclables : int = 6
@export var max_collector_count: int = 3 : set = _set_max_collector_count, get = _get_max_collector_count
@export var current_recyclables : int = 0 : set = _set_current_recyclables, get = _get_current_recyclables
@export var move_speed_modifier : float = 1.0 : set = _set_move_speed_modifier, get = _get_move_speed_modifier 

@onready var upgrade_shop : UpgradeShop = $CanvasLayer/upgrade_shop
@onready var tutorial_dialog : DialogBox = $CanvasLayer/DialogBox
@onready var fact_popup : DialogBox = $CanvasLayer/FactPopup

var recycling_facts = [
	"In Canada, recycling responsibilities are shared between federal, provincial, territorial, and municipal governments.\n\nSource: Made in CA (https://madeinca.ca/2023-recycling-statistics-in-canada/)",
	"Canadians produce 694 kg of waste per person per year, the highest in the world.\n\nSource: Made in CA (https://madeinca.ca/2023-recycling-statistics-in-canada/)",
	"In 2018, Canada generated 35.6 million tonnes of solid waste, but only 28% was recycled.\n\nSource: Made in CA (https://madeinca.ca/2023-recycling-statistics-in-canada/)",
	"Prince Edward Island, British Columbia, Quebec, and Nova Scotia recycle more than the national average.\n\nSource: Made in CA (https://madeinca.ca/2023-recycling-statistics-in-canada/)",
	"97% of Canadian households with access to recycling programs utilize at least one.\n\nSource: Made in CA (https://madeinca.ca/2023-recycling-statistics-in-canada/)",
	"Only 9% of all plastic waste is recycled in Canada.\n\nSource: Made in CA (https://madeinca.ca/2023-recycling-statistics-in-canada/)",
	"96% of Canadians have access to paper and cardboard recycling facilities.\n\nSource: Made in CA (https://madeinca.ca/2023-recycling-statistics-in-canada/)",
	"Canada has over 10,000 landfills, many of which are reaching capacity.\n\nSource: Made in CA (https://madeinca.ca/2023-recycling-statistics-in-canada/)",
	"Over 66% of steel is recycled in Canada.\n\nSource: Made in CA (https://madeinca.ca/2023-recycling-statistics-in-canada/)",
	"Canadians produce around 7 million tonnes of organic waste per year.\n\nSource: Made in CA (https://madeinca.ca/2023-recycling-statistics-in-canada/)",
	"Each Canadian throws away about half a kilogram of packaging daily.\n\nSource: Made in CA (https://madeinca.ca/2023-recycling-statistics-in-canada/)",
	"The top five companies contributing to plastic pollution in Canada are Nestle, Tim Hortons, Starbucks, McDonald’s, and The Coca-Cola Company.\n\nSource: Made in CA (https://madeinca.ca/2023-recycling-statistics-in-canada/)",
	"The recycling industry in Canada faces challenges with the recycling of plastic, with much of it accumulating in facilities without a market.\n\nSource: Global News (https://globalnews.ca/news/7143337/canada-recycling-industry/)",
	"Many recyclables no longer bring profit and now cost money to dispose of.\n\nSource: Global News (https://globalnews.ca/news/7143337/canada-recycling-industry/)",
	"China’s 2018 ban on certain types of waste significantly impacted Canada’s recycling industry.\n\nSource: Global News (https://globalnews.ca/news/7143337/canada-recycling-industry/)",
	"The residual rate in recycling plants, indicating non-recyclable materials, has increased to around 25-30%.\n\nSource: Global News (https://globalnews.ca/news/7143337/canada-recycling-industry/)",
	"Some Canadian cities have reduced the types of materials accepted in blue bin recycling programs.\n\nSource: Global News (https://globalnews.ca/news/7143337/canada-recycling-industry/)",
	"12% of Canada’s plastic recycling is shipped overseas, often leading to environmental harm.\n\nSource: Review Moose (https://reviewmoose.ca/blog/recycling-statistics-canada/)",
	"Recycling glass is difficult due to its weight, abrasiveness, and sorting issues.\n\nSource: Review Moose (https://reviewmoose.ca/blog/recycling-statistics-canada/)"
]

var rng = RandomNumberGenerator.new()
var recycling_collector = preload("res://scenes/characters/collector.tscn")
var recyclable = preload("res://scenes/levels/recyclable.tscn")
var recyclables_list = []
var collectors_list = []

signal recyclables_count_changed
signal collector_count_changed
signal move_speed_modifier_changed

func _set_current_recyclables(count : int):
	current_recyclables = count
	emit_signal("recyclables_count_changed", current_recyclables)

func _get_current_recyclables():
	return current_recyclables
	
func _set_max_collector_count(count : int):
	max_collector_count = count
	emit_signal("collector_count_changed", max_collector_count)
	fact_popup.dialog_text.text = get_random_recycling_fact()
	fact_popup.show()
	

func _get_max_collector_count():
	return max_collector_count
	
func _set_move_speed_modifier(value : float):
	move_speed_modifier = value
	emit_signal("move_speed_modifier_changed", move_speed_modifier)
	fact_popup.dialog_text.text = get_random_recycling_fact()
	fact_popup.show()

func _get_move_speed_modifier():
	return move_speed_modifier
	
	
	
func _on_area_2d_input_event(_viewport, event, _shape_idx):
	if event.is_action_pressed("left_click"):
		_spawn_collector(event.position.x, event.position.y - 100)
		tutorial_dialog.hide()

func get_random_recycling_fact():
	var index = rng.randi_range(0, recycling_facts.size() - 1)
	return recycling_facts[index]

func _ready():
	_set_current_recyclables(0)
	_set_max_collector_count(3)
	_set_move_speed_modifier(1.0)
	for i in range(starting_recyclables):
		_spawn_recyclable()
	var timer = Timer.new()

	timer.set_wait_time(1.0)
	timer.set_one_shot(false)
	timer.connect("timeout", _spawn_recyclable)
	add_child(timer)
	timer.start()
	upgrade_shop.hide()
	fact_popup.hide()
	tutorial_dialog.show()
	
func _spawn_collector(position_x, position_y):
	if(collectors_list.size() < max_collector_count and recyclables_list.size() > 0):

		var instance = recycling_collector.instantiate()
		instance.position.x = position_x
		instance.position.y = position_y
		instance.move_speed_modifier = _get_move_speed_modifier()
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
	_set_current_recyclables(_get_current_recyclables()+1)
	
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


func _on_shop_button_pressed():
	upgrade_shop.show()
