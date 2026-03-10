extends Node
class_name EventManager

signal event_started(event_name: String)
signal event_ended

var income_multiplier: float = 1.0
var active_event_name: String = ""
var _event_timer: float = 0.0

const EVENT_POOL := [
	{"name": "DDoS Attack", "duration": 12.0, "multiplier": 0.6},
	{"name": "Power Outage", "duration": 8.0, "multiplier": 0.35},
	{"name": "Server Failure", "duration": 10.0, "multiplier": 0.5}
]

func reset() -> void:
	income_multiplier = 1.0
	active_event_name = ""
	_event_timer = 0.0
	event_ended.emit()

func process_events(delta: float) -> void:
	if active_event_name != "":
		_event_timer -= delta
		if _event_timer <= 0.0:
			active_event_name = ""
			income_multiplier = 1.0
			event_ended.emit()
		return

	if randf() < 0.02 * delta:
		var event_data: Dictionary = EVENT_POOL[randi() % EVENT_POOL.size()]
		active_event_name = event_data["name"]
		income_multiplier = event_data["multiplier"]
		_event_timer = event_data["duration"]
		event_started.emit(active_event_name)
