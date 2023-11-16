extends HBoxContainer

class_name ItemDisplay

@onready var texture_rect: TextureRect = $TextureRect
@onready var label: Label = $Label


func update_count(count: int):
	label.text = str(count)

func update_texture(texture_path: String):
	texture_rect.texture = load(texture_path)
