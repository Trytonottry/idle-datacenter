extends Node
class_name EconomyManager

signal stats_changed

@export var economy: Economy = Economy.new()

func tick_income(income_multiplier: float = 1.0) -> void:
	economy.money += economy.income_per_second * income_multiplier
	stats_changed.emit()

func sync_income_from_racks(rack_manager: RackManager) -> void:
	economy.income_per_second = rack_manager.get_total_income()
	stats_changed.emit()

func can_afford(cost: float) -> bool:
	return economy.money >= cost

func spend(cost: float) -> bool:
	if not can_afford(cost):
		return false
	economy.money -= cost
	stats_changed.emit()
	return true

func can_host_server(rack_manager: RackManager, server: Server) -> bool:
	return rack_manager.get_total_power_usage() + server.power_usage <= economy.power_capacity \
		and rack_manager.get_total_cooling_usage() + server.cooling_usage <= economy.cooling_capacity

func try_upgrade_power() -> bool:
	if not spend(economy.power_upgrade_cost):
		return false
	economy.power_capacity += 20.0
	economy.power_upgrade_cost *= 1.5
	stats_changed.emit()
	return true

func try_upgrade_cooling() -> bool:
	if not spend(economy.cooling_upgrade_cost):
		return false
	economy.cooling_capacity += 20.0
	economy.cooling_upgrade_cost *= 1.5
	stats_changed.emit()
	return true

func get_total_power_usage(rack_manager: RackManager) -> float:
	return rack_manager.get_total_power_usage()

func get_total_cooling_usage(rack_manager: RackManager) -> float:
	return rack_manager.get_total_cooling_usage()

func load_state(data: Dictionary) -> void:
	economy.from_dict(data)
	stats_changed.emit()

func get_state_dict() -> Dictionary:
	return economy.to_dict()
