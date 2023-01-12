extends RayCast3D

func _process(_delta):
	if get_collider():
		if get_collider().get_node("../") is Item:
			HUD.set_look_info(get_collider().get_node("../").type)
	else:
		HUD.set_look_info("")
