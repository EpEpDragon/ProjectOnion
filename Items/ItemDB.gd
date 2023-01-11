extends Node
const PATH = "res://Items/"

const ITEMS = {
	"canister" : {
		"asset" : preload(PATH + "Canister.tscn"),
	},
	"error" : {
		"asset" : preload(PATH + "Box.tscn"),
	}
}

func get_item(item_id):
	if item_id in ITEMS:
		return ITEMS[item_id]
	else:
		return ITEMS["error"]
