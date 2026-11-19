extends Control

var text_box: TextEdit
var add_button: Button
var continue_button: Button

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	text_box = $/root/Setup/Control/TextBox
	add_button = $/root/Setup/Control/Buttons/AddButton
	continue_button = $/root/Setup/Control/Buttons/ContinueButton

func _on_add_button_pressed() -> void:
	# Prevent empty names or duplicate names from being added
	if (text_box.text == ""): return
	if (PlayerManager.has_player(text_box.text)): return
	PlayerManager.register_player(text_box.text)
	text_box.text = "" # Clear after button is pressed

func _on_continue_button_pressed() -> void:
	if (PlayerManager.get_players().size() <= 1): return
	get_tree().change_scene_to_file("res://scenes/Game.tscn")


func _on_reset_button_pressed() -> void:
	PlayerManager.clear_players()
