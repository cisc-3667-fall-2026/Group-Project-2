extends Control

func _on_how_to_play_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Instructions.tscn")

func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Setup.tscn")

func _ready() -> void:
	await get_tree().process_frame
	queue_redraw()
