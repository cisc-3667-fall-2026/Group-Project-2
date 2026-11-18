extends Control

var rounds: Array = []

func _ready() -> void:
	rounds = load_diseases()
	print("Loaded ", rounds.size(), " rounds:")
	for d in rounds:
		print("  ", d["name"])
	%QuestionLabel.text = "Where was %s first identified?" % rounds[0]["name"]


# Reads and shuffles all the diseases, and takes the first 5.
func load_diseases() -> Array:
	var file := FileAccess.open("res://data/diseases.json", FileAccess.READ)
	if file == null:
		push_error("Could not open diseases.json")
		return []
	var all_diseases = JSON.parse_string(file.get_as_text())
	if all_diseases == null:
		push_error("diseases.json has a syntax error (missing comma or quote?)")
		return []

	var pool: Array = all_diseases
	pool.shuffle()
	return pool.slice(0, GameManager.total_rounds)
