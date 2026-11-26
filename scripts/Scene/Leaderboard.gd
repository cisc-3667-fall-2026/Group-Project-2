extends Control

func _ready() -> void:
	%MainMenuButton.pressed.connect(_on_play_again_pressed)

	# Sort players from highest to lowest score.
	var order = PlayerManager.get_players()
	order.sort_custom(func(a, b): return a.score > b.score)

	var text := ""
	for rank in order.size():
		text += "%d.  %s    %d points\n" % [rank + 1, order[rank].name, order[rank].score]
	%ResultsLabel.text = text

	# Handle ties for first place.
	var best = order[0]
	var winners: PackedStringArray = []
	for p in order.size():
		if order[p].score == best.score:
			winners.append("%s" % order[p].name)
	if winners.size() == 1:
		%WinnerLabel.text = "%s wins!" % winners[0]
	else:
		%WinnerLabel.text = "It's a tie: " + ", ".join(winners)


func _on_play_again_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
