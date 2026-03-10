extends Node
class_name SaveSystem

const SAVE_PATH := "user://savegame.json"

func save_game(economy_manager: EconomyManager, rack_manager: RackManager) -> void:
	var payload := economy_manager.get_state_dict()
	payload["racks"] = rack_manager.to_dict_array()
	payload["upgrades"] = {
		"power_capacity": economy_manager.economy.power_capacity,
		"cooling_capacity": economy_manager.economy.cooling_capacity
	}
	payload["servers"] = _flatten_servers(rack_manager.racks)
	payload["last_play_timestamp"] = Time.get_unix_time_from_system()

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
