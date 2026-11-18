class_name Player

@export var name: String = "Player"
@export var score: int = 0

func _to_string():
	return "{name: %s}, {score: %s}" % [name, str(score)]
