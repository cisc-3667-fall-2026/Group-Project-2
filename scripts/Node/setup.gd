extends Control

var text_box: TextEdit
var add_button: Button
var continue_button: Button

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	text_box = $TextBox
	add_button = $GridContainer/AddButton
	continue_button = $GridContainer/ContinueButton
	
	pass # Replace with function body.

func _on_add_button_pressed() -> void:
	PlayerManager.register_player(text_box.text)
	text_box.text = "" # Clear after button is pressed

func _on_continue_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Game.tscn")
