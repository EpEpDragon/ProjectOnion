extends MeshInstance3D

func _process(delta):
	var time = Time.get_ticks_msec()
	position.x = sin(time*0.001)
