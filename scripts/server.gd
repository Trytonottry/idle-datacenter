extends Node
class_name Server

## Represents a single physical server that can run a hosted service.

const SERVICE_MULTIPLIERS := {
	"Web Hosting": 1.0,
	"VPN": 1.25,
	"Game Servers": 1.5,
	"Streaming": 1.75
}

@export var server_name: String = "Micro Server"
@export var cpu: int = 1
@export var ram: int = 2
@export var power_usage: float = 1.0
@export var cooling_usage: float = 1.0
@export var base_income: float = 1.0
@export var buy_cost: float = 15.0
@export var service_type: String = "Web Hosting"

func get_income() -> float:
	var multiplier := SERVICE_MULTIPLIERS.get(service_type, 1.0)
	return base_income * multiplier

func to_dict() -> Dictionary:
	return {
		"server_name": server_name,
		"cpu": cpu,
		"ram": ram,
		"power_usage": power_usage,
		"cooling_usage": cooling_usage,
		"base_income": base_income,
		"buy_cost": buy_cost,
		"service_type": service_type
	}

func from_dict(data: Dictionary) -> void:
	server_name = data.get("server_name", server_name)
	cpu = data.get("cpu", cpu)
	ram = data.get("ram", ram)
	power_usage = data.get("power_usage", power_usage)
	cooling_usage = data.get("cooling_usage", cooling_usage)
	base_income = data.get("base_income", base_income)
	buy_cost = data.get("buy_cost", buy_cost)
	service_type = data.get("service_type", service_type)

static func create_preset(preset_name: String, service: String = "Web Hosting") -> Server:
	var server := Server.new()
	match preset_name:
		"Micro Server":
			server.server_name = "Micro Server"
			server.cpu = 1
			server.ram = 2
			server.power_usage = 1
			server.cooling_usage = 1
			server.base_income = 1
			server.buy_cost = 15
		"Standard Server":
			server.server_name = "Standard Server"
			server.cpu = 4
			server.ram = 8
			server.power_usage = 3
			server.cooling_usage = 2
			server.base_income = 5
			server.buy_cost = 60
		"Datacenter Server":
			server.server_name = "Datacenter Server"
			server.cpu = 16
			server.ram = 32
			server.power_usage = 8
			server.cooling_usage = 6
			server.base_income = 20
			server.buy_cost = 200
		_:
			server.server_name = "Micro Server"
	server.service_type = service
	return server
