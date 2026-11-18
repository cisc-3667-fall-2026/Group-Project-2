extends Node

var player_list: Array[Player] = [];
var player_count: int = 0;
var player_selected: int = 0;

func register_player(name: String):
	var player = Player.new()
	player.name = name
	player.id = player_count
	
	player_count += 1
	
	player_list.append(player);
	
	print("Registered " + player.name + " with ID of " + str(player.id))
	
func get_players():
	return player_list
