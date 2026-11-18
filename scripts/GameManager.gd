extends Node
var num_players :=2
var total_rounds :=5
var scores: Array[int] = []

# Call this at the start of every new game
func reset() -> void:
	scores.clear()
	for i in num_players:
		scores.append(0)
