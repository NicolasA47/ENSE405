extends PanelContainer

@export var current_goal : Goal = Goal.new()

@onready var plastic_collected : Goal = Goal.new()
@onready var scrap_collected : Goal = Goal.new()
@onready var electronics_collected: Goal = Goal.new()
@onready var goal_list = [plastic_collected, scrap_collected, electronics_collected]
@onready var goal_text = $MarginContainer/VBoxContainer/Goal
@onready var current_ammount = $MarginContainer/VBoxContainer/HBoxContainer/CurrentTotal
@onready var goal_target = $MarginContainer/VBoxContainer/HBoxContainer/GoalTotal
@onready var level: Level = get_tree().get_first_node_in_group("level")

signal goal_complete
var target_increments = [50, 200, 500, 1000, 5000, 10000, 100000, 250000, 1000000]

func _ready():
	plastic_collected.goal_text = "Total Plastic Collected"
	plastic_collected.current_ammount = 0
	plastic_collected.target_ammount = target_increments[plastic_collected.current_goal_increment]
	plastic_collected.get_percent_completed()
	plastic_collected.goal_fact = "About 50 recycled plastic bottles can be used to make one Buffy Cloud comforter, preventing these bottles from ending up in the trash.\n\n[url=https://www.climateofourfuture.org/creating-a-greener-world-what-can-be-made-from-recycled-plastic-water-bottles/#google_vignette]Source[/url]"
	
	scrap_collected.goal_text = "Total Scrap Metal Collected"
	scrap_collected.current_ammount = 0
	scrap_collected.target_ammount = target_increments[scrap_collected.current_goal_increment]
	scrap_collected.get_percent_completed()
	scrap_collected.goal_fact = "scrap metal can be used to create items like furniture, lighting fixtures, and office supplies.\n\n[url=https://www.scrapware.com/blog/more-products-made-from-recycled-scrap-as-manufacturers-seek-eco-responsibility/#:~:text=Home%20Furnishings%20%E2%80%94%20Indoor%20and,manufactured%20from%20recycled%20scrap%20metal]Source[/url]"
	
	electronics_collected.goal_text = "Total Electronics Collected"
	electronics_collected.current_ammount = 0
	electronics_collected.target_ammount = target_increments[electronics_collected.current_goal_increment]
	electronics_collected.get_percent_completed()
	electronics_collected.goal_fact = "Recycling cell phones helps recover valuable materials like copper, silver, gold, and palladium, reducing the environmental impact of mining.\n\nSource:(https://ecavo.com/benefits-recycling-electronics/#:~:text=%E3%80%9018%E2%80%A0This%20UN%20report%E2%80%A0www,metals%20being%20buried%20or%20burned)"
	
	current_goal = plastic_collected
	
	level.wallet_changed.connect(update_goals)

func update_goals(wallet: Wallet):
	plastic_collected.current_ammount = level.total_plastic
	plastic_collected.target_ammount = target_increments[plastic_collected.current_goal_increment]
	plastic_collected.get_percent_completed()
	
	scrap_collected.current_ammount = level.total_scrap
	scrap_collected.target_ammount = target_increments[scrap_collected.current_goal_increment]
	scrap_collected.get_percent_completed()
	
	electronics_collected.current_ammount = level.total_electronics
	electronics_collected.target_ammount = target_increments[electronics_collected.current_goal_increment]
	electronics_collected.get_percent_completed()
	
	get_highest_completion()
	
func get_highest_completion():
	for goal in goal_list:
		if (goal.current_ammount >= goal.target_ammount):	
			goal.current_goal_increment += 1
			emit_signal("goal_complete", goal)
		if (goal.get_percent_completed() > current_goal.percent_completed):
			current_goal = goal
	
	update_current_goal()
		

func update_current_goal():
	$MarginContainer/VBoxContainer/Goal.text = current_goal.goal_text
	$MarginContainer/VBoxContainer/HBoxContainer/CurrentTotal.text = str(current_goal.current_ammount)
	$MarginContainer/VBoxContainer/HBoxContainer/GoalTotal.text = str(current_goal.target_ammount)
	


	


