extends Control

signal player_ready

func _ready() -> void:
	%ReadyButton.pressed.connect(_on_ready_button_pressed)

func show_for(player_number: int) -> void:
	%TurnScreenLabel.text = "%s, it's your turn!\nEveryone else, look away." % PlayerManager.get_players()[player_number].name
	show()

func _on_ready_button_pressed() -> void:
	hide()
	player_ready.emit()
