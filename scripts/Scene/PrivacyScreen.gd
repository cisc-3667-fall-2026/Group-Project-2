extends Control

signal player_ready


func _ready() -> void:
	%ReadyButton.pressed.connect(_on_ready_button_pressed)


func show_for(player_number: int) -> void:
	var player_name: String = PlayerManager.get_players()[player_number].name
	%TurnScreenLabel.text = "%s, it's your turn!\nEveryone else, look away." % player_name
	show()


func _on_ready_button_pressed() -> void:
	hide()
	player_ready.emit()
