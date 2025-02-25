extends SubViewport

@onready var player := %Player

func _ready():
	var compositor_effect : PostProcessDither = %Player.camera.compositor.compositor_effects[0]
	compositor_effect.mask_viewport = self
