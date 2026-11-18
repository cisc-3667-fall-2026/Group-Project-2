class_name Player

@export var name: String = "Player"
@export var id: int = 0

func _to_string():
	return "{name: %s, id: %s}" % [name, id]
