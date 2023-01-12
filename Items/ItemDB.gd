extends Node
const PATH = "res://Items/"

const ITEMS = {
	"Canister" : {
		"asset" : preload(PATH + "Canister.tscn"),
		"dimentions" : Vector2i(1,2)
	},
	"Box" : {
		"asset" : preload(PATH + "Box.tscn"),
		"dimentions" : Vector2i(3,3)
	},
	"error" : {
		"asset" : preload(PATH + "Box.tscn"),
		"dimentions" : Vector2i(1,1)
	}
}

func get_item(item_id):
	if item_id in ITEMS:
		return ITEMS[item_id]
	else:
		return ITEMS["error"]
