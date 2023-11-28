extends HBoxContainer

class_name UpgradeContainer

@onready var plastic_price : Label = $CostContainer/RecyclablesPrice
@onready var scrap_metal_price : Label = $CostContainer/ScrapMetalPrice
@onready var electronics_price : Label = $CostContainer/ElectronicsPrice
@onready var purchase_button : Button = $PurchaseButton
@onready var upgrade_texture: TextureRect = $PanelContainer/HBoxContainer/UpgradeTexture
@onready var upgrade_number : Label = $PanelContainer/HBoxContainer/UpgradeNumber
@onready var level: Level
@onready var is_single_purchase : bool = false

signal commit_upgrade(value)

func _ready():
	level = get_tree().get_first_node_in_group("level")
	purchase_button.disabled = true
	level.connect("wallet_changed", _check_for_ability_to_purchase)

func update_upgrade(plastic_cost: int, scrap_metal_cost: int, electronics_cost: int, new_upgrade_texture: Texture, upgrade_level: int, button_text: String, single_purchase_bool: bool):
	update_price(plastic_cost, scrap_metal_cost, electronics_cost)
	update_upgrade_texture(new_upgrade_texture)
	update_upgrade_number(upgrade_level)
	update_button_text(button_text)
	update_single_purchase(single_purchase_bool)

func update_price(plastic_cost: int, scrap_metal_cost: int, electronics_cost: int):
	plastic_price.text = str(plastic_cost)
	scrap_metal_price.text = str(scrap_metal_cost)
	electronics_price.text = str(electronics_cost)

func update_upgrade_texture(new_texture: Texture):
	upgrade_texture.texture = new_texture

func update_upgrade_number(upgrade_level: int):
	upgrade_number.text = str(upgrade_level)

func update_button_text(description: String):
	purchase_button.text = str(description)

func update_single_purchase(boolean_value: bool):
	is_single_purchase = boolean_value


func _on_purchase_button_pressed():

	var enough_balance: bool = level.wallet.make_verified_purchase(int(plastic_price.text), int(scrap_metal_price.text), int(electronics_price.text))
	if enough_balance:
		if (int(plastic_price.text) > 0):
			plastic_price.text = str(increment_price(int(plastic_price.text)))
		if (int(scrap_metal_price.text) > 0):
			scrap_metal_price.text = str(increment_price(int(scrap_metal_price.text)))
		if (int(electronics_price.text) > 0):
			electronics_price.text = str(increment_price(int(electronics_price.text)))
		
		update_upgrade_number(int(upgrade_number.text) + 1)
		
		emit_signal("commit_upgrade", int(upgrade_number.text))
		level.emit_signal("wallet_changed", level.wallet)
	else:
		pass
	
func _check_for_ability_to_purchase(wallet: Wallet):
	if (wallet.plastic_balance >= int(plastic_price.text) && wallet.scrap_metal_balance >= int(scrap_metal_price.text) && wallet.electronics_balance >= int(electronics_price.text)):
		purchase_button.disabled = false
	else:
		purchase_button.disabled = true
		
func increment_price(current_price: int) -> int:
		var new_price : int = current_price + (2 * int(upgrade_number.text))
		return ceil(new_price/5)*5
