extends Control

func _ready() -> void:
	%PlayAgainButton.pressed.connect(_on_play_again_pressed)

	# Sort players from highest to lowest score.
	var order := range(GameManager.num_players)
	order.sort_custom(func(a, b): return GameManager.scores[a] > GameManager.scores[b])

	var text := ""
	for rank in order.size():
		var p: int = order[rank]
		text += "%d.  Player %d    %d points\n" % [rank + 1, p + 1, GameManager.scores[p]]
	%ResultsLabel.text = text

	# Handle ties for first place.
	var best: int = GameManager.scores[order[0]]
	var winners: PackedStringArray = []
	for p in order:
		if GameManager.scores[p] == best:
			winners.append("Player %d" % (p + 1))
	if winners.size() == 1:
		%WinnerLabel.text = "%s wins!" % winners[0]
	else:
		%WinnerLabel.text = "It's a tie: " + ", ".join(winners)


func _on_play_again_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
