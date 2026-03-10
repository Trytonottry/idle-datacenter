extends Node
class_name SaveSystem

const SAVE_PATH := "user://savegame.json"

func save_game(economy: Economy, racks: Array[Rack]) -> void:
	var rack_data: Array = []
	for rack in racks:
		rack_data.append(rack.to_dict())

	var payload := {
		"money": economy.money,
		"income_per_second": economy.income_per_second,
		"power_capacity": economy.power_capacity,
		"cooling_capacity": economy.cooling_capacity,
		"bandwidth": economy.bandwidth,
		"power_upgrade_cost": economy.power_upgrade_cost,
		"cooling_upgrade_cost": economy.cooling_upgrade_cost,
		"racks": rack_data,
		"upgrades": {
			"power_capacity": economy.power_capacity,
			"cooling_capacity": economy.cooling_capacity
		},
		"servers": _flatten_servers(racks),
		"last_play_timestamp": Time.get_unix_time_from_system()
	}

	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(payload, "\t"))

func load_game() -> Dictionary:
	if not FileAccess.file_exists(SAVE_PATH):
		return {}

	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return {}

	var parsed := JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		return {}

	return parsed

func compute_offline_seconds(last_play_timestamp: int) -> int:
	if last_play_timestamp <= 0:
		return 0
	var now := int(Time.get_unix_time_from_system())
	return max(0, now - last_play_timestamp)

func _flatten_servers(racks: Array[Rack]) -> Array:
	var all_servers: Array = []
	for rack in racks:
		for server in rack.servers:
			all_servers.append(server.to_dict())
	return all_servers
