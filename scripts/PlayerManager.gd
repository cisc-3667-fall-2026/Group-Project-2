extends Node

var player_list: Array[Player] = [];
var list_index: int = 0;

signal player_select_changed

func register_player(name: String):
	if name.length() <= 0: return
	
	var player = Player.new()
	player.name = name
	
	player_list.append(player);
	
	player_select_changed.emit()
	
	print("Registered " + player.name)
	
func select_next_player():
	list_index += 1
	if (list_index > player_list.size() - 1): list_index = 0
	
	player_select_changed.emit()
	
func get_selected_player():
	return player_list[list_index]

func get_players():
	return player_list
