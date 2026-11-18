extends Node

# Call this at the start of every new game
func reset() -> void:
	var player_list = PlayerManager.get_players()
	for n in range(player_list.size()):
		var player: Player = player_list[n]
		
		player.score = 0
