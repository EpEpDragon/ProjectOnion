extends Control

@onready var _label_look_info = $LabelLookInfo

func set_look_info(info : String):
	_label_look_info.text = info
