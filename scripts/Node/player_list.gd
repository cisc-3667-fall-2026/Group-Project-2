extends Control

@export var show_selected_player: bool = true
@export var show_score_for_players: bool = true

var players: Array[Player]
var default_label = preload("res://assets/player_label_settings/default_label.tres")
var selected_label = preload("res://assets/player_label_settings/selected_label.tres")

func draw_player_list():
	var nodes = $Row.get_children()

	# Redraw if we already drew them
	for n in range(1, nodes.size()):
		$Row.remove_child(nodes[n])

	for n in PlayerManager.get_players().size():
		var player_name = $Row/PlayerName.duplicate()

		var score_text := str(players[n].score) if show_score_for_players else ""
		player_name.text = players[n].name + " " + score_text

		if n == PlayerManager.list_index and show_selected_player:
			player_name.label_settings = selected_label
		else:
			player_name.label_settings = default_label

		$Row.add_child(player_name)

		player_name.visible = true

func _ready() -> void:
	players = PlayerManager.get_players()

	PlayerManager.player_select_changed.connect(draw_player_list)
	draw_player_list() # draw it at least once

	print(players)
