extends Control

var players: Array[Player]
var default_label = preload("res://assets/player_label_settings/default_label.tres")
var selected_label = preload("res://assets/player_label_settings/selected_label.tres")

func draw_player_list():
	var nodes = $Row.get_children()
		
	# Redraw if we already drew them
	for n in range(1, nodes.size()):
		$Row.remove_child(nodes[n])
	
	for n in PlayerManager.get_players().size():
		var PlayerName = $Row/PlayerName.duplicate()
		
		PlayerName.text = players[n].name
		
		if players[n].id == PlayerManager.player_selected:
			PlayerName.label_settings = default_label
		else:
			PlayerName.label_settings = selected_label
			
		$Row.add_child(PlayerName)
			
		PlayerName.visible = true

func _ready() -> void:	
	players = PlayerManager.get_players()
	
	print(players)
	
func _process(delta: float) -> void:
	draw_player_list()
