extends Control

const RACK_COST := 100.0

@onready var economy: Economy = $Economy
@onready var save_system: SaveSystem = $SaveSystem
@onready var income_timer: Timer = $IncomeTimer
@onready var racks_container: VBoxContainer = %RacksContainer

@onready var money_label: Label = %MoneyLabel
@onready var income_label: Label = %IncomeLabel
@onready var power_label: Label = %PowerLabel
@onready var cooling_label: Label = %CoolingLabel
@onready var event_label: Label = %EventLabel

var racks: Array[Rack] = []

func _ready() -> void:
	randomize()
	income_timer.timeout.connect(_on_income_timer_timeout)
	economy.stats_changed.connect(_refresh_ui)
	economy.event_started.connect(_on_event_started)
	economy.event_ended.connect(_on_event_ended)
	_load_or_start_new_game()
	_refresh_ui()

func _process(delta: float) -> void:
	economy.update_random_events(delta)

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		save_system.save_game(economy, racks)
		get_tree().quit()

func _on_income_timer_timeout() -> void:
	economy.tick_income()

func _on_buy_rack_button_pressed() -> void:
	if economy.money < RACK_COST:
		return
	economy.money -= RACK_COST
	var rack := Rack.new()
	rack.slots = 4
	rack.rack_changed.connect(_on_rack_changed)
	racks.append(rack)
	_render_racks_list()
	economy.stats_changed.emit()

func _on_buy_server_button_pressed() -> void:
	if racks.is_empty():
		return

	var target_rack := _first_available_rack()
	if target_rack == null:
		return

	var preset := _pick_server_preset()
	var server := Server.create_preset(preset, _pick_service())

	if economy.money < server.buy_cost:
		return

	if economy.get_total_power_usage(racks) + server.power_usage > economy.power_capacity:
		return

	if economy.get_total_cooling_usage(racks) + server.cooling_usage > economy.cooling_capacity:
		return

	economy.money -= server.buy_cost
	target_rack.add_server(server)
	economy.update_income_from_racks(racks)
	_render_racks_list()
	_refresh_ui()

func _on_upgrade_power_button_pressed() -> void:
	economy.try_upgrade_power()

func _on_upgrade_cooling_button_pressed() -> void:
	economy.try_upgrade_cooling()

func _on_save_button_pressed() -> void:
	save_system.save_game(economy, racks)

func _on_rack_changed() -> void:
	economy.update_income_from_racks(racks)
	_refresh_ui()

func _load_or_start_new_game() -> void:
	var data := save_system.load_game()
	if data.is_empty():
		return

	economy.load_state(data)

	racks.clear()
	for rack_data in data.get("racks", []):
		var rack := Rack.new()
		rack.from_dict(rack_data)
		rack.rack_changed.connect(_on_rack_changed)
		racks.append(rack)

	# Offline progression.
	var last_play := int(data.get("last_play_timestamp", 0))
	var seconds_offline := save_system.compute_offline_seconds(last_play)
	if seconds_offline > 0:
		var offline_income := economy.income_per_second * float(seconds_offline)
		economy.money += offline_income

	economy.update_income_from_racks(racks)
	_render_racks_list()

func _refresh_ui() -> void:
	money_label.text = "Money: $%.2f" % economy.money
	income_label.text = "Income/s: $%.2f" % (economy.income_per_second * economy.event_multiplier)
	power_label.text = "Power: %.1f / %.1f" % [economy.get_total_power_usage(racks), economy.power_capacity]
	cooling_label.text = "Cooling: %.1f / %.1f" % [economy.get_total_cooling_usage(racks), economy.cooling_capacity]

func _render_racks_list() -> void:
	for child in racks_container.get_children():
		child.queue_free()

	for i in racks.size():
		var rack := racks[i]
		var label := Label.new()
		label.text = "Rack %d | Slots: %d/%d | Income: $%.2f" % [i + 1, rack.servers.size(), rack.slots, rack.get_income()]
		racks_container.add_child(label)

func _first_available_rack() -> Rack:
	for rack in racks:
		if rack.can_add_server():
			return rack
	return null

func _pick_server_preset() -> String:
	var roll := randi() % 100
	if roll < 60:
		return "Micro Server"
	if roll < 90:
		return "Standard Server"
	return "Datacenter Server"

func _pick_service() -> String:
	var services := ["Web Hosting", "VPN", "Game Servers", "Streaming"]
	return services[randi() % services.size()]

func _on_event_started(event_name: String) -> void:
	event_label.text = "Event: %s (income reduced)" % event_name

func _on_event_ended() -> void:
	event_label.text = "Event: None"
