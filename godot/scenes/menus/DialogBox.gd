extends PanelContainer

class_name DialogBox

@onready var dialog_text : RichTextLabel = $MarginContainer/RichTextLabel
@onready var level : Level = get_tree().get_first_node_in_group("level")


func _on_texture_button_pressed():
	self.hide()
