extends Control

@onready var world = $"/root/World"
@onready var player : PlayerCharacter = $"/root/World/Player"

func _can_drop_data(at_position, data):
	return true

func _drop_data(at_position, data):
	var item_instance = ItemDb.ITEMS[data.id].asset.instantiate()
	print(item_instance)
	item_instance.position = player.global_position - player.camera.global_transform.basis.z*1.5
	world.add_child(item_instance)
	data.queue_free()
	data.call_deferred("free")
