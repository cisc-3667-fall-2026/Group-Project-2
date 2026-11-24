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
	if PlayerManager.get_players().size() <= 0:
		PlayerManager.register_player("Player A")
		PlayerManager.register_player("Player B")
		GameManager.reset()

	rounds = load_diseases()
	if rounds.is_empty():
		%QuestionLabel.text = "Couldn't load any diseases. Check diseases.json."
		return
	
	%MapViewport.map_clicked.connect(_on_map_clicked)
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
	%MapViewport.reset_view(false)
	$PrivacyScreen.show_for(PlayerManager.list_index)

# Called when PrivacyScreen sends its player_ready signal.
func _on_player_ready() -> void:
	%TurnLabel.text = "%s: click where you think it was first identified" % PlayerManager.get_players()[PlayerManager.list_index].name
	%MapViewport.input_enabled = true
	accepting_clicks = true

func _on_map_clicked(coordinates: Vector2) -> void:
	if accepting_clicks:
		place_guess(pixel_to_latlon(coordinates))

func place_guess(coordinates: Vector2) -> void:
	accepting_clicks = false
	
	guesses.append(coordinates)
	
	if PlayerManager.list_index < PlayerManager.get_players().size() - 1:
		PlayerManager.select_next_player()
		show_turn_screen()
	else:
		reveal()

func reveal() -> void:
	%MapViewport.reset_view(true)
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
		PlayerManager.get_players()[i].score += points
		
		var color: Color = PLAYER_COLORS[i]
		%Pins.add_line(guess, Vector2(answer["lat"], answer["lon"]), color)
		%Pins.add_pin(guess.x, guess.y, color)
		text += "[color=#%s]%s[/color]: %d km away, +%d points\n" % [color.to_html(false), PlayerManager.get_players()[i].name, int(km), points]
	
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
	PlayerManager.list_index = 0
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
	var order = PlayerManager.get_players()
	order.sort_custom(func(a, b): return a.score > b.score)
	var text := ""
	for rank in order.size():
		text += "%d. %s: %d\n" % [rank + 1, order[rank].name, order[rank].score]
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
