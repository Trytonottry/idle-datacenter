extends Node
class_name RackManager

signal racks_changed

var racks: Array[Rack] = []

func clear_racks() -> void:
	for rack in racks:
		if rack.rack_changed.is_connected(_on_rack_changed):
			rack.rack_changed.disconnect(_on_rack_changed)
	racks.clear()
	racks_changed.emit()

func add_rack(slots: int = 4) -> Rack:
	var rack := Rack.new()
	rack.slots = slots
	rack.rack_changed.connect(_on_rack_changed)
	racks.append(rack)
	racks_changed.emit()
	return rack

func load_racks(racks_data: Array) -> void:
	clear_racks()
	for rack_data in racks_data:
		var rack := Rack.new()
		rack.from_dict(rack_data)
		rack.rack_changed.connect(_on_rack_changed)
		racks.append(rack)
	racks_changed.emit()

func first_available_rack() -> Rack:
	for rack in racks:
		if rack.can_add_server():
			return rack
	return null

func add_server_to_first_available(server: Server) -> bool:
	var rack := first_available_rack()
	if rack == null:
		return false
	return rack.add_server(server)

func get_total_income() -> float:
	var total := 0.0
	for rack in racks:
		total += rack.get_income()
	return total

func get_total_power_usage() -> float:
	var total := 0.0
	for rack in racks:
		total += rack.power_usage
	return total

func get_total_cooling_usage() -> float:
	var total := 0.0
	for rack in racks:
		total += rack.cooling_usage
	return total

func to_dict_array() -> Array:
	var out: Array = []
	for rack in racks:
		out.append(rack.to_dict())
	return out

func _on_rack_changed() -> void:
	racks_changed.emit()
