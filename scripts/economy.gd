extends Resource
class_name Economy

## Core economy state only (no orchestration logic).

@export var money: float = 100.0
@export var income_per_second: float = 0.0
@export var power_capacity: float = 25.0
@export var cooling_capacity: float = 25.0
@export var bandwidth: float = 100.0

@export var power_upgrade_cost: float = 200.0
@export var cooling_upgrade_cost: float = 200.0

func to_dict() -> Dictionary:
	return {
		"money": money,
		"income_per_second": income_per_second,
		"power_capacity": power_capacity,
		"cooling_capacity": cooling_capacity,
		"bandwidth": bandwidth,
		"power_upgrade_cost": power_upgrade_cost,
		"cooling_upgrade_cost": cooling_upgrade_cost
	}

func from_dict(data: Dictionary) -> void:
	money = data.get("money", money)
	income_per_second = data.get("income_per_second", income_per_second)
	power_capacity = data.get("power_capacity", power_capacity)
	cooling_capacity = data.get("cooling_capacity", cooling_capacity)
	bandwidth = data.get("bandwidth", bandwidth)
	power_upgrade_cost = data.get("power_upgrade_cost", power_upgrade_cost)
	cooling_upgrade_cost = data.get("cooling_upgrade_cost", cooling_upgrade_cost)
