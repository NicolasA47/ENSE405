extends HBoxContainer

class_name UpgradeContainer

@onready var purchase_button : Button = $PurchaseButton
@onready var price : Label = $CostContainer/Price
@onready var cost_texture: TextureRect = $CostContainer/CostTexture
@onready var upgrade_texture: TextureRect = $PanelContainer/HBoxContainer/UpgradeTexture
@onready var upgrade_number : Label = $PanelContainer/HBoxContainer/UpgradeNumber
@onready var level: Level

signal commit_upgrade(value)

func _ready():
	level = get_tree().get_first_node_in_group("level")
	purchase_button.disabled = true
	level.connect("recyclables_count_changed", _check_for_ability_to_purchase)

func update_upgrade(price_amount: int, new_cost_texture: Texture, new_upgrade_texture: Texture, upgrade_level: int, button_text: String):
	update_price(price_amount)
	update_cost_texture(new_cost_texture)
	update_upgrade_texture(new_upgrade_texture)
	update_upgrade_number(upgrade_level)
	update_button_text(button_text)

func update_price(price_amount: int):
	price.text = str(price_amount)

func update_cost_texture(new_texture: Texture):
	cost_texture.texture = new_texture

func update_upgrade_texture(new_texture: Texture):
	upgrade_texture.texture = new_texture

func update_upgrade_number(upgrade_level: int):
	upgrade_number.text = str(upgrade_level)

func update_button_text(description: String):
	purchase_button.text = str(description)


func _on_purchase_button_pressed():
	var price_amount = int(price.text)
	var enough_balance = bool(level._get_current_recyclables() >= price_amount)
	if enough_balance:
		var new_price : int = price_amount + (2 * int(upgrade_number.text))
		update_price(ceil(new_price/5)*5)
		update_upgrade_number(int(upgrade_number.text) + 1)
		level._set_current_recyclables(level._get_current_recyclables() - price_amount)
		
		emit_signal("commit_upgrade", int(upgrade_number.text))
	else:
		pass
	
func _check_for_ability_to_purchase(count: int):
	print("recycle count changed")
	if (level._get_current_recyclables() >= int(price.text)):
		purchase_button.disabled = false
	else:
		purchase_button.disabled = true
		
