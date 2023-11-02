class_name BuildingData
extends Resource


@export var name: String
@export var type: RecyclableType
@export var texture: Texture
@export var worker_capacity: int = 5
@export var worker_count: int = 2
@export var recyclable_capacity: int = 10
@export var recyclable_count: int = 0
@export var purchased_upgrades: Array[Upgrade]
@export var available_upgrades: Array[Upgrade]



enum RecyclableType {
	glass,
	plastic,
	paper,
}
