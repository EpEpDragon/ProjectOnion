extends Node


const ITEMS = {
	"stick" : {
		"slot" : "MAIN"
	},
	"rock": {
		"slot" : "MAIN"
	},
	"error": {
		"slot" : "NONE"
	}
}

func get_item(item_id):
	if item_id in ITEMS:
		return ITEMS[item_id]
	else:
		return ITEMS["error"]
