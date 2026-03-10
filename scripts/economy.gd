extends Node
class_name Economy

signal stats_changed
signal event_started(event_name: String)
signal event_ended

@export var money: float = 100.0
@export var income_per_second: float = 0.0
@export var power_capacity: float = 25.0
@export var cooling_capacity: float = 25.0
@export var bandwidth: float = 100.0

@export var power_upgrade_cost: float = 200.0
@export var cooling_upgrade_cost: float = 200.0

var event_multiplier: float = 1.0
var active_event_name: String = ""
var _event_timer: float = 0.0

const EVENT_POOL := [
	{"name": "DDoS Attack", "duration": 12.0, "multiplier": 0.6},
	{"name": "Power Outage", "duration": 8.0, "multiplier": 0.35},
	{"name": "Server Failure", "duration": 10.0, "multiplier": 0.5}
]

func tick_income() -> void:
	money += income_per_second * event_multiplier
	stats_changed.emit()

func update_income_from_racks(racks: Array[Rack]) -> void:
	income_per_second = 0.0
	for rack in racks:
		income_per_second += rack.get_income()
	stats_changed.emit()

func get_total_power_usage(racks: Array[Rack]) -> float:
	var total := 0.0
	for rack in racks:
		total += rack.power_usage
	return total

func get_total_cooling_usage(racks: Array[Rack]) -> float:
	var total := 0.0
	for rack in racks:
		total += rack.cooling_usage
	return total

func can_support(racks: Array[Rack]) -> bool:
	return get_total_power_usage(racks) <= power_capacity and get_total_cooling_usage(racks) <= cooling_capacity

func try_upgrade_power() -> bool:
	if money < power_upgrade_cost:
		return false
	money -= power_upgrade_cost
	power_capacity += 20.0
	power_upgrade_cost *= 1.5
	stats_changed.emit()
	return true

func try_upgrade_cooling() -> bool:
	if money < cooling_upgrade_cost:
		return false
	money -= cooling_upgrade_cost
	cooling_capacity += 20.0
	cooling_upgrade_cost *= 1.5
	stats_changed.emit()
	return true

func update_random_events(delta: float) -> void:
	if active_event_name != "":
		_event_timer -= delta
		if _event_timer <= 0.0:
			active_event_name = ""
			event_multiplier = 1.0
			event_ended.emit()
			stats_changed.emit()
		return

	# ~2% chance each second while idle.
	if randf() < 0.02 * delta:
		var event_data: Dictionary = EVENT_POOL[randi() % EVENT_POOL.size()]
		active_event_name = event_data["name"]
		event_multiplier = event_data["multiplier"]
		_event_timer = event_data["duration"]
		event_started.emit(active_event_name)
		stats_changed.emit()

func get_state_dict() -> Dictionary:
	return {
		"money": money,
		"income_per_second": income_per_second,
		"power_capacity": power_capacity,
		"cooling_capacity": cooling_capacity,
		"bandwidth": bandwidth,
		"power_upgrade_cost": power_upgrade_cost,
		"cooling_upgrade_cost": cooling_upgrade_cost
	}

func load_state(data: Dictionary) -> void:
	money = data.get("money", money)
	income_per_second = data.get("income_per_second", income_per_second)
	power_capacity = data.get("power_capacity", power_capacity)
	cooling_capacity = data.get("cooling_capacity", cooling_capacity)
	bandwidth = data.get("bandwidth", bandwidth)
	power_upgrade_cost = data.get("power_upgrade_cost", power_upgrade_cost)
	cooling_upgrade_cost = data.get("cooling_upgrade_cost", cooling_upgrade_cost)
	stats_changed.emit()
