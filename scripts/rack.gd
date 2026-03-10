extends Node
class_name Rack

signal rack_changed

## Rack stores a list of servers and tracks local usage totals.

@export var slots: int = 4
@export var power_usage: float = 0.0
@export var cooling_usage: float = 0.0
var servers: Array[Server] = []

func can_add_server() -> bool:
	return servers.size() < slots

func add_server(server: Server) -> bool:
	if not can_add_server():
		return false
	servers.append(server)
	recalculate_usage()
	rack_changed.emit()
	return true

func recalculate_usage() -> void:
	power_usage = 0.0
	cooling_usage = 0.0
	for server in servers:
		power_usage += server.power_usage
		cooling_usage += server.cooling_usage

func get_income() -> float:
	var income := 0.0
	for server in servers:
		income += server.get_income()
	return income

func to_dict() -> Dictionary:
	var serialized_servers: Array = []
	for server in servers:
		serialized_servers.append(server.to_dict())
	return {
		"slots": slots,
		"power_usage": power_usage,
		"cooling_usage": cooling_usage,
		"servers": serialized_servers
	}

func from_dict(data: Dictionary) -> void:
	slots = data.get("slots", slots)
	servers.clear()
	for server_data in data.get("servers", []):
		var server := Server.new()
		server.from_dict(server_data)
		servers.append(server)
	recalculate_usage()
	rack_changed.emit()
