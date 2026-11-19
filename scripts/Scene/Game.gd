extends Control

const PLAYER_COLORS := [
	Color.RED, Color.DODGER_BLUE, Color.ORANGE, Color.MAGENTA, Color.CYAN, Color.YELLOW
]

var rounds: Array = []
var round_idx := 0
var current_player := 0
var guesses: Array = []          # one Vector2(lat, lon) per player
var accepting_clicks := false


func _ready() -> void:
	# Lets you test this scene directly with F6, without going through the menu.
	if GameManager.scores.size() != GameManager.num_players:
		GameManager.reset()

	rounds = load_diseases()
	if rounds.is_empty():
		%QuestionLabel.text = "Couldn't load any diseases. Check diseases.json."
		return

	%Map.gui_input.connect(_on_map_gui_input)
	$PrivacyScreen.player_ready.connect(_on_player_ready)
	%NextButton.pressed.connect(_on_next_pressed)
	start_round()


#Round flow

func start_round() -> void:
	var d: Dictionary = rounds[round_idx]
	%QuestionLabel.text = (
		"Round %d of %d: Where was %s first identified?"
		% [round_idx + 1, rounds.size(), d["name"]]
	)
	guesses.clear()
	current_player = 0
	%Pins.clear_all()
	%RevealPanel.hide()
	show_turn_screen()


func show_turn_screen() -> void:
	accepting_clicks = false
	$PrivacyScreen.show_for(current_player + 1)


# Called when PrivacyScreen sends its player_ready signal.
func _on_player_ready() -> void:
	%TurnLabel.text = "Player %d: click where you think it was first identified" % (current_player + 1)
	accepting_clicks = true


func _on_map_gui_input(event: InputEvent) -> void:
	if not accepting_clicks:
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		place_guess(pixel_to_latlon(event.position))


func place_guess(latlon: Vector2) -> void:
	accepting_clicks = false
	guesses.append(latlon)
	current_player += 1
	if current_player < GameManager.num_players:
		show_turn_screen()
	else:
		reveal()


func reveal() -> void:
	%TurnLabel.text = "Results"
	var d: Dictionary = rounds[round_idx]

	# Green pin at every correct location.
	for loc in d["locations"]:
		%Pins.add_pin(loc["lat"], loc["lon"], Color.GREEN)

	var text := "[b]This round[/b]\n"
	for i in guesses.size():
		var guess: Vector2 = guesses[i]
		var answer := nearest_answer(guess, d)
		var km: float = answer["km"]
		var points := score_for(km)
		GameManager.scores[i] += points

		var color: Color = PLAYER_COLORS[i]
		%Pins.add_line(guess, Vector2(answer["lat"], answer["lon"]), color)
		%Pins.add_pin(guess.x, guess.y, color)
		text += (
			"[color=#%s]Player %d[/color]: %d km away, +%d points\n"
			% [color.to_html(false), i + 1, int(km), points]
		)

	text += "\n[b]Standings[/b]\n" + standings_text()
	%ResultsLabel.text = text

	%FactLabel.text = (
		"[b]%s[/b]\nFirst identified: %s, %s\n\n%s"
		% [d["name"], d["place"], d["year"], d["fact"]]
	)

	var last_round := round_idx == rounds.size() - 1
	%NextButton.text = "See final results" if last_round else "Next round"
	%RevealPanel.show()


func _on_next_pressed() -> void:
	round_idx += 1
	if round_idx >= rounds.size():
		get_tree().change_scene_to_file("res://scenes/Leaderboard.tscn")
	else:
		start_round()


#Helpers

func pixel_to_latlon(pos: Vector2) -> Vector2:
	var map_size: Vector2 = %Map.size
	var lon: float = pos.x / map_size.x * 360.0 - 180.0
	var lat: float = 90.0 - pos.y / map_size.y * 180.0
	return Vector2(lat, lon)   # x = latitude, y = longitude


func haversine_km(lat1: float, lon1: float, lat2: float, lon2: float) -> float:
	var dlat := deg_to_rad(lat2 - lat1)
	var dlon := deg_to_rad(lon2 - lon1)
	var a := sin(dlat / 2) ** 2 + cos(deg_to_rad(lat1)) * cos(deg_to_rad(lat2)) * sin(dlon / 2) ** 2
	return 6371.0 * 2.0 * atan2(sqrt(a), sqrt(1.0 - a))


# Some diseases have two locations. Score against whichever is closer.
func nearest_answer(guess: Vector2, d: Dictionary) -> Dictionary:
	var best := {"km": INF, "lat": 0.0, "lon": 0.0}
	for loc in d["locations"]:
		var km := haversine_km(guess.x, guess.y, loc["lat"], loc["lon"])
		if km < best["km"]:
			best = {"km": km, "lat": loc["lat"], "lon": loc["lon"]}
	return best


func score_for(km: float) -> int:
	return int(round(5000.0 * exp(-km / 2000.0)))


# Players sorted from highest score to lowest.
func standings_text() -> String:
	var order := range(GameManager.num_players)
	order.sort_custom(func(a, b): return GameManager.scores[a] > GameManager.scores[b])
	var text := ""
	for rank in order.size():
		var p: int = order[rank]
		text += "%d. Player %d: %d\n" % [rank + 1, p + 1, GameManager.scores[p]]
	return text


func load_diseases() -> Array:
	var file := FileAccess.open("res://data/diseases.json", FileAccess.READ)
	if file == null:
		push_error("Could not open diseases.json")
		return []
	var all_diseases = JSON.parse_string(file.get_as_text())
	if all_diseases == null:
		push_error("diseases.json has a syntax error")
		return []
	var pool: Array = all_diseases
	pool.shuffle()
	return pool.slice(0, GameManager.total_rounds)
