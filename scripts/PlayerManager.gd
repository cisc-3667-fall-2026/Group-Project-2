extends Node

var player_list: Array[Player] = [];
var player_count: int = 0;
var player_selected: int = 0;
var list_index: int = 0;

signal player_select_changed

func register_player(name: String):
	var player = Player.new()
	player.name = name
	player.id = player_count
	
	player_count += 1
	
	player_list.append(player);
	
	player_select_changed.emit()
	
	print("Registered " + player.name + " with ID of " + str(player.id))
	
func select_player():
	list_index += 1
	if (list_index > player_list.size() - 1): list_index = 0
	player_selected = player_list[list_index].id
	
	player_select_changed.emit()

func get_players():
	return player_list
