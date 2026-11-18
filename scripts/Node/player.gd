class_name Player

@export var name: String = "Player"

func _to_string():
	return "{name: %s}" % [name]
