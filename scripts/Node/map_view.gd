extends Control

signal map_clicked(map_pixel: Vector2)

const DRAG_THRESHOLD := 6.0
const ZOOM_STEP := 1.2

var input_enabled := false
var zoom := 1.0
var held := false
var dragging := false
var press_position := Vector2.ZERO
var previous_position := Vector2.ZERO

@onready var map: TextureRect = $Map

func _ready() -> void:
	resized.connect(_resize_map)
	get_window().focus_exited.connect(_cancel_press)
	reset_view(false)

func reset_view(enable_input: bool) -> void:
	_cancel_press()

	input_enabled = enable_input
	zoom = 1.0
	map.position = Vector2.ZERO
	map.size = size

func _cancel_press() -> void:
	held = false
	dragging = false

func _resize_map() -> void:
	var center := Vector2(0.5, 0.5)

	if map.size.x > 0 and map.size.y > 0:
		center = (map.size / zoom / 2.0 - map.position) / map.size

	map.size = size * zoom

	_move_map(size / 2.0 - center * map.size)

func _move_map(target: Vector2) -> void:
	map.position = target.clamp(size - map.size, Vector2.ZERO)

func _zoom_at(pointer: Vector2, steps: float) -> void:
	_cancel_press()

	var next_zoom := clampf(zoom * pow(ZOOM_STEP, steps), 1.0, 2.0)
	var target := pointer - (pointer - map.position) * (next_zoom / zoom)
	zoom = next_zoom
	map.size = size * zoom

	_move_map(target)

func _gui_input(event: InputEvent) -> void:
	if not input_enabled:
		return
	if event is InputEventPanGesture:
		_zoom_at(event.position, -event.delta.y)
	elif event is InputEventMouseMotion and held:
		_update_drag(event.position)
	elif event is InputEventMouseButton:
		if event.canceled:
			_cancel_press()
		elif event.button_index == MOUSE_BUTTON_LEFT:
			_handle_left_button(event)
		elif event.pressed and event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_zoom_at(event.position, event.factor)
		elif event.pressed and event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_zoom_at(event.position, -event.factor)

func _handle_left_button(event: InputEventMouseButton) -> void:
	var inside := Rect2(Vector2.ZERO, size).has_point(event.position)

	if event.pressed:
		held = inside
		dragging = false
		press_position = event.position
		previous_position = event.position
	elif held:
		_update_drag(event.position)

		var clicked := inside and not dragging

		_cancel_press()

		if clicked:
			map_clicked.emit(event.position - map.position)

func _update_drag(pointer: Vector2) -> void:
	var screen_delta := get_screen_transform().basis_xform(pointer - press_position)

	if screen_delta.length() >= DRAG_THRESHOLD:
		dragging = true
	if dragging:
		_move_map(map.position + pointer - previous_position)

		previous_position = pointer
