class_name UCState
extends Resource

var _group_states: Dictionary[StringName, UCBitset] = {}

func initialize(database: UCFlagDatabase) -> void:
	_group_states.clear()
	
	for group_info in database.groups:
		if group_info == null:
			continue
		
		_group_states[group_info.group_name] = UCBitset.new(group_info.max_index + 1)

func set_flag(database: UCFlagDatabase, group_name: StringName, flag_name: StringName, value: bool) -> void:
	var flag_index: int = database.get_flag_index(group_name, flag_name)
	
	if flag_index == -1:
		push_error("Unknown flag '%s' in group '%s'" % [flag_name, group_name])
		return
	
	var bitset: UCBitset = _group_states[group_name]
	bitset.set_bit(flag_index, value)

func is_flag_set(database: UCFlagDatabase, group_name: StringName, flag_name: StringName) -> bool:
	var flag_index: int = database.get_flag_index(group_name, flag_name)
	
	if flag_index == -1:
		push_error("Unknown flag '%s' in group '%s'" % [flag_name, group_name])
		return false
	
	var bitset: UCBitset = _group_states[group_name]
	return bitset.check_bit(flag_index)

func data_to_dictionary() -> Dictionary:
	var result: Dictionary = {}
	
	for group_name in _group_states:
		var bitset: UCBitset = _group_states[group_name]
		result[group_name] = bitset.as_base_64()
	
	return result

func data_from_dictionary(data: Dictionary) -> void:
	for group_name in data:
		if not _group_states.has(group_name):
			push_error("Untracked flag group: '%s'" % group_name)
			continue
		
		var bitset: UCBitset = _group_states[group_name]
		bitset.from_base64(data[group_name])
