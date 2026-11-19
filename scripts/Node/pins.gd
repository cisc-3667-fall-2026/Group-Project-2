extends Control

var pins: Array = []    # each: {"lat": float, "lon": float, "color": Color}
var lines: Array = []   # each: {"from": Vector2(lat, lon), "to": Vector2(lat, lon), "color": Color}

func latlon_to_pixel(lat: float, lon: float) -> Vector2:
	return Vector2((lon + 180.0) / 360.0 * size.x, (90.0 - lat) / 180.0 * size.y)

func add_pin(lat: float, lon: float, color: Color) -> void:
	pins.append({"lat": lat, "lon": lon, "color": color})
	queue_redraw()

func add_line(from_latlon: Vector2, to_latlon: Vector2, color: Color) -> void:
	lines.append({"from": from_latlon, "to": to_latlon, "color": color})
	queue_redraw()

func clear_all() -> void:
	pins.clear()
	lines.clear()
	queue_redraw()

func _draw() -> void:
	for l in lines:
		var a := latlon_to_pixel(l["from"].x, l["from"].y)
		var b := latlon_to_pixel(l["to"].x, l["to"].y)
		draw_line(a, b, l["color"], 2.0)
	for p in pins:
		var pos := latlon_to_pixel(p["lat"], p["lon"])
		draw_circle(pos, 8.0, Color.BLACK)   # outline
		draw_circle(pos, 6.0, p["color"])

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		queue_redraw()
