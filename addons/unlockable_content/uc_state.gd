class_name UCState
extends Resource

var _group_states: Dictionary[StringName, UCBitset] = {}

func initialize(database: UCFlagDatabase) -> void:
	_group_states.clear()
	
	for group_info in database.groups:
		if group_info == null:
			continue
		
		_group_states[group_info.group_name] = UCBitset.new(group_info.max_index + 1)

## Sets the value of a flag in the given flag group to true or false.
func set_flag(database: UCFlagDatabase, group_name: StringName, flag_name: StringName, value: bool) -> void:
	var flag_index: int = database.get_flag_index(group_name, flag_name)
	
	if flag_index == -1:
		push_error("Unknown flag '%s' in group '%s'" % [flag_name, group_name])
		return
	
	var bitset: UCBitset = _group_states[group_name]
	bitset.set_bit(flag_index, value)

## Determines if a flag from the given flag group has been set to true or false.
func is_flag_set(database: UCFlagDatabase, group_name: StringName, flag_name: StringName) -> bool:
	var flag_index: int = database.get_flag_index(group_name, flag_name)
	
	if flag_index == -1:
		push_error("Unknown flag '%s' in group '%s'" % [flag_name, group_name])
		return false
	
	var bitset: UCBitset = _group_states[group_name]
	return bitset.check_bit(flag_index)

## Determines if the flag at the given index isset in the given flag group.
func is_flag_index_set(group_name: StringName, flag_index: int) -> bool:
	var bitset: UCBitset = _group_states[group_name]
	return bitset.check_bit(flag_index)

## Creates a dictionary representation of the current state, resulting in a dictionary with the following shape:
## { "group_name": "base64_encoded_state_data", ... }
func data_to_dictionary() -> Dictionary:
	var result: Dictionary = {}
	
	for group_name in _group_states:
		var bitset: UCBitset = _group_states[group_name]
		result[group_name] = bitset.as_base_64()
	
	return result

## Retrieves a UCState object from a dictionary. Expects { "group_name": "base64_encoded_state_data", ... }
func data_from_dictionary(data: Dictionary) -> void:
	for group_name in data:
		if not _group_states.has(group_name):
			push_error("Untracked flag group: '%s'" % group_name)
			continue
		
		var bitset: UCBitset = _group_states[group_name]
		bitset.from_base64(data[group_name])
