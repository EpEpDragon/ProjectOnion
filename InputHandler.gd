extends Node

@onready var player : PlayerCharacter = $/root/World/Player

func _unhandled_key_input(event):
	if event.is_action_pressed("invenotry"):
		if not EscMenu.visible:
			if Inventory.visible:
				Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
				Inventory.visible = false
			else:
				Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
				Inventory.visible = true
	elif event.is_action_pressed("menu"):
		if Inventory.visible:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			Inventory.visible = false
		else:
			if EscMenu.visible:
				EscMenu.visible = false
				Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			else:
				EscMenu.visible = true
				Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
