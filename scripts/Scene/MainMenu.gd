extends Control

func _ready() -> void:
	%StartButton.pressed.connect(_on_start_pressed)
	%Instructions.pressed.connect(_on_how_to_play_pressed)

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Setup.tscn")

func _on_how_to_play_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Instructions.tscn")
