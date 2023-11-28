extends Node2D

class_name Level

@export var max_recyclable_count: int = 30
@export var starting_recyclables : int = 6
@export var max_collector_count: int = 3 : set = _set_max_collector_count, get = _get_max_collector_count
@export var move_speed_modifier : float = 1.0 : set = _set_move_speed_modifier, get = _get_move_speed_modifier 
@export var recyclables_spawn_timer = Timer.new()
@export var number_of_recyclables_per_spawn : int = 3 : set = _set_number_of_recyclables_per_spawn, get = _get_number_of_recyclables_per_spawn

@export var total_plastic : int = 0
@export var total_scrap : int = 0
@export var total_electronics : int = 0

@onready var unlocked_recyclables = ["plastic"]
@onready var wallet : Wallet
@onready var upgrade_shop : UpgradeShop = $CanvasLayer/VBoxContainer/upgrade_shop
@onready var tutorial_dialog : DialogBox = $CanvasLayer/DialogBox
@onready var fact_popup : DialogBox = $CanvasLayer/FactPopup
@onready var collection_point = $CollectionPoint
@onready var recyclable = preload("res://scenes/levels/recyclable.tscn")


var recycling_facts = [
	"In Canada, recycling responsibilities are shared between federal, provincial, territorial, and municipal governments.\n\nSource: Made in CA (https://madeinca.ca/recycling-canada-statistics/)",
	"Only 28% of waste was recycled in Canada in 2018 with the rest of it going into landfills, shipped abroad, or burned.\n\nSource: Made in CA (https://madeinca.ca/recycling-canada-statistics/)",
	"Prince Edward Island, British Columbia, Quebec, and Nova Scotia recycle more than the national average.\n\nSource: Made in CA (https://madeinca.ca/recycling-canada-statistics/)",
	"97% of Canadian households with access to recycling programs utilize it regularly.\n\nSource: Made in CA (https://madeinca.ca/recycling-canada-statistics/)",
	"Only 9% of all plastic waste is recycled in Canada.\n\nSource: Made in CA (https://madeinca.ca/recycling-canada-statistics/)",
	"96% of Canadians have access to paper and cardboard recycling facilities.\n\nSource: Made in CA (https://madeinca.ca/recycling-canada-statistics/))",
	"Canada has over 10,000 landfills, many of which are reaching capacity.\n\nSource: Made in CA (https://madeinca.ca/recycling-canada-statistics/)",
	"Over 66% of steel is recycled in Canada.\n\nSource: Made in CA (https://madeinca.ca/recycling-canada-statistics/)",
	"Each Canadian throws away about half a kilogram of packaging daily.\n\nSource: Made in CA (https://madeinca.ca/recycling-canada-statistics/)",
	"The top five companies contributing to plastic pollution in Canada are Nestle, Tim Hortons, Starbucks, McDonald’s, and The Coca-Cola Company.\n\nSource: Made in CA (https://madeinca.ca/recycling-canada-statistics/)",
	"The recycling industry in Canada faces challenges with the recycling of plastic, with much of it accumulating in facilities without a market.\n\nSource: Global News (https://globalnews.ca/news/7143337/canada-recycling-industry/)",
	"The residual rate in recycling plants, indicating non-recyclable materials, has increased to around 25-30%.\n\nSource: Global News (https://globalnews.ca/news/7143337/canada-recycling-industry/)",
	"12% of Canada’s plastic recycling is shipped overseas, often leading to environmental harm.\n\nSource: Review Moose (https://reviewmoose.ca/blog/recycling-statistics-canada/)",
	"Recycling glass is difficult due to its weight, abrasiveness, and sorting issues.\n\nSource: Review Moose (https://reviewmoose.ca/blog/recycling-statistics-canada/)"
]

var rng = RandomNumberGenerator.new()
var recycling_collector = preload("res://scenes/characters/collector.tscn")
var collectors_list = []
var recyclables_list: Array[Recyclable] = []
var collected_recyclables_queue = []

signal wallet_changed
signal collector_count_changed
signal move_speed_modifier_changed

func _update_wallet(plastic: int, scrap_metal: int, electronics: int):
	wallet.plastic_balance += plastic
	wallet.scrap_metal_balance += scrap_metal
	wallet.electronics_balance += electronics
	emit_signal("wallet_changed", wallet)

func _get_wallet():
	return wallet
	
func _set_max_collector_count(count : int):
	max_collector_count = count
	emit_signal("collector_count_changed", max_collector_count)
	fact_popup.dialog_text.text = get_random_recycling_fact()
	fact_popup.show()
	

func _get_max_collector_count():
	return max_collector_count
	
func _set_number_of_recyclables_per_spawn(count: int):
	number_of_recyclables_per_spawn = count
	fact_popup.dialog_text.text = get_random_recycling_fact()
	fact_popup.show()
	
func _get_number_of_recyclables_per_spawn():
	return number_of_recyclables_per_spawn
	
	
func _set_move_speed_modifier(value : float):
	move_speed_modifier = value
	emit_signal("move_speed_modifier_changed", move_speed_modifier)
	fact_popup.dialog_text.text = get_random_recycling_fact()
	fact_popup.show()

func _get_move_speed_modifier():
	return move_speed_modifier
	
func clear_recyclables():
	for item in recyclables_list:
		item.queue_free()
		
	recyclables_list.clear()
	
func _on_area_2d_input_event(_viewport, event, _shape_idx):
	if event.is_action_pressed("left_click"):
		_spawn_collector(event.position.x, event.position.y - 100)
		tutorial_dialog.hide()

func get_random_recycling_fact():
	if(recycling_facts.size() > 0):
		var index = rng.randi_range(0, recycling_facts.size() - 1)
		
		
		var fact = recycling_facts[index]
		recycling_facts.remove_at(index)
		return fact
	else:
		return "No Facts Left, Sorry!"

func _ready():
	wallet = Wallet.new()
	wallet.init_default_balance()
	_set_max_collector_count(3)
	_set_move_speed_modifier(1.0)
	for i in range(starting_recyclables):
		_spawn_recyclable()

	recyclables_spawn_timer.set_wait_time(1.0)
	recyclables_spawn_timer.set_one_shot(false)
	recyclables_spawn_timer.connect("timeout", _spawn_recyclable)
	add_child(recyclables_spawn_timer)
	recyclables_spawn_timer.start()
	upgrade_shop.hide()
	fact_popup.hide()
	tutorial_dialog.show()
	$CanvasLayer/Goals.connect("goal_complete", display_goal_complete_message)
	
	
func display_goal_complete_message(goal: Goal):
	fact_popup.dialog_text.text = "Congrats on Achieving your Goal\n"+goal.goal_text+"\n"+str(goal.target_ammount)+"/"+str(goal.target_ammount)+"\n"+goal.goal_fact
	fact_popup.show()
	
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
		collected_recyclables_queue.append(recyclable)
		recyclables_list.erase(recyclable)
		recyclable.hide()
		
func _on_movement_complete(instance, recyclable):
	if(recyclable.type == "plastic"):
		_update_wallet(1, 0, 0)
		total_plastic += 1
	elif(recyclable.type == "scrap_metal"):
		_update_wallet(0, 1, 0)
		total_scrap += 1
	elif(recyclable.type == "electronic"):
		_update_wallet(0, 0, 1)
		total_electronics += 1
	collected_recyclables_queue.remove_at(0)
	recyclable.queue_free()
	collectors_list.erase(instance)
	instance.queue_free()

func _on_wallet_changed():
	emit_signal("wallet_changed", wallet)
	
func _spawn_recyclable():
	for i in range(number_of_recyclables_per_spawn):
		if(recyclables_list.size() < max_recyclable_count):
			var view_width = get_viewport_rect().size.x
			var view_height = get_viewport_rect().size.y
			var instance = recyclable.instantiate() as Recyclable
			instance._init_from_string(unlocked_recyclables[rng.randi_range(0, unlocked_recyclables.size()-1)])
			rng.randomize()
			instance.position.x = rng.randi_range(0, view_width)
			instance.position.y = rng.randi_range(0, view_height-150)
			add_child(instance)
			recyclables_list.append(instance)


func _on_shop_button_pressed():
	upgrade_shop.show()
