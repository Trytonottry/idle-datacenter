extends Control

const RACK_COST := 100.0

@onready var economy_manager: EconomyManager = $EconomyManager
@onready var rack_manager: RackManager = $RackManager
@onready var event_manager: EventManager = $EventManager
@onready var save_system: SaveSystem = $SaveSystem
@onready var income_timer: Timer = $IncomeTimer

@onready var racks_container: VBoxContainer = %RacksContainer
@onready var money_label: Label = %MoneyLabel
@onready var income_label: Label = %IncomeLabel
@onready var power_label: Label = %PowerLabel
@onready var cooling_label: Label = %CoolingLabel
@onready var event_label: Label = %EventLabel

func _ready() -> void:
	randomize()
	income_timer.timeout.connect(_on_income_timer_timeout)
	rack_manager.racks_changed.connect(_on_racks_changed)
	economy_manager.stats_changed.connect(_refresh_ui)
	event_manager.event_started.connect(_on_event_started)
	event_manager.event_ended.connect(_on_event_ended)
	_load_or_start_new_game()
	_refresh_ui()

func _process(delta: float) -> void:
	event_manager.process_events(delta)

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		save_system.save_game(economy_manager, rack_manager)
		get_tree().quit()

func _on_income_timer_timeout() -> void:
	economy_manager.tick_income(event_manager.income_multiplier)

func _on_buy_rack_button_pressed() -> void:
	if not economy_manager.spend(RACK_COST):
		return
	rack_manager.add_rack(4)

func _on_buy_server_button_pressed() -> void:
	var preset := _pick_server_preset()
	var server := Server.create_preset(preset, _pick_service())

	if not economy_manager.can_afford(server.buy_cost):
		return
	if rack_manager.first_available_rack() == null:
		return
	if not economy_manager.can_host_server(rack_manager, server):
		return
	if not economy_manager.spend(server.buy_cost):
		return
	if rack_manager.add_server_to_first_available(server):
		economy_manager.sync_income_from_racks(rack_manager)

func _on_upgrade_power_button_pressed() -> void:
	economy_manager.try_upgrade_power()

func _on_upgrade_cooling_button_pressed() -> void:
	economy_manager.try_upgrade_cooling()

func _on_save_button_pressed() -> void:
	save_system.save_game(economy_manager, rack_manager)

func _on_racks_changed() -> void:
	economy_manager.sync_income_from_racks(rack_manager)
	_render_racks_list()
	_refresh_ui()

func _load_or_start_new_game() -> void:
	var data := save_system.load_game()
	if data.is_empty():
		return

	economy_manager.load_state(data)
	rack_manager.load_racks(data.get("racks", []))

	var seconds_offline := save_system.compute_offline_seconds(int(data.get("last_play_timestamp", 0)))
	if seconds_offline > 0:
		economy_manager.economy.money += economy_manager.economy.income_per_second * float(seconds_offline)

	_refresh_ui()

func _refresh_ui() -> void:
	var economy := economy_manager.economy
	money_label.text = "Money: $%.2f" % economy.money
	income_label.text = "Income/s: $%.2f" % (economy.income_per_second * event_manager.income_multiplier)
	power_label.text = "Power: %.1f / %.1f" % [economy_manager.get_total_power_usage(rack_manager), economy.power_capacity]
	cooling_label.text = "Cooling: %.1f / %.1f" % [economy_manager.get_total_cooling_usage(rack_manager), economy.cooling_capacity]

func _render_racks_list() -> void:
	for child in racks_container.get_children():
		child.queue_free()

	for i in rack_manager.racks.size():
		var rack := rack_manager.racks[i]
		var label := Label.new()
		label.text = "Rack %d | Slots: %d/%d | Income: $%.2f" % [i + 1, rack.servers.size(), rack.slots, rack.get_income()]
		racks_container.add_child(label)

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
	_refresh_ui()

func _on_event_ended() -> void:
	event_label.text = "Event: None"
	_refresh_ui()
