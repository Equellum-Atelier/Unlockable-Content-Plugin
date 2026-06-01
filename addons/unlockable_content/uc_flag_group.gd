class_name UCGroupInfo 
extends RefCounted

signal flag_group_resized(new_size: int)

enum RenameResult {
	SUCCES = 0,
	EMPTY_NAME,
	NO_ENTRY_FOUND,
	DUPLICATE_ENTRY,
}

var group_name: StringName
var max_index: int = -1
var _flag_definitions: Array[Dictionary]
var _definition_lookup: Dictionary[StringName, int]
var flags: Dictionary[StringName, int] = {}

func add_flag(flag_name: StringName, index: int) -> void:
	assert(index >= 0, "flag '%' has an index out of range, negative indices are not supported.")
	
	flags[flag_name] = index
	_definition_lookup[flag_name] = _flag_definitions.size()
	_flag_definitions.append({
		&"name": flag_name,
		&"value": index
	})
	
	sort_definitions()
	
	if index > max_index:
		max_index = index
		flag_group_resized.emit(max_index)

## Adds a new flag with it's value set to the previous highest value incremented by one.
func add_flag_auto_increment(flag_name: StringName) -> int:
	var index: int = max_index + 1
	flags[flag_name] = index
	max_index = index
	
	_definition_lookup[flag_name] = _flag_definitions.size()
	_flag_definitions.append({
		&"name": flag_name,
		&"value": index
	})
	
	flag_group_resized.emit(index)
	
	return index

## Sets a flag to a specific non-negative index.
func set_flag_index(flag_name: StringName, index: int) -> void:
	assert(index >= 0, "flag '%' has an index out of range, negative indices are not supported.")
	flags[flag_name] = index
	
	var definition_size: int = _flag_definitions.size()
	var definition_index: int = _definition_lookup.get_or_add(flag_name, definition_size)
	
	if definition_size == definition_index:
		_flag_definitions.append({
			&"name": flag_name,
			&"value": index
		})
	else:
		_flag_definitions[definition_index].set(&"value", index)
	
	#_definition_lookup[flag_name] = definition_index
	
	sort_definitions()
	
	var old_max: int = max_index
	_calculate_max_flag()
	if old_max != max_index:
		flag_group_resized.emit(max_index)

## Removes a flag with the given name. returns true if the flag was deleted, false if it was not found.
func remove_flag(flag_name: StringName) -> bool:
	var is_removed: bool = flags.erase(flag_name)
	if not is_removed:
		return false
	
	var definition_index: int = _definition_lookup.get(flag_name, -1)
	assert(definition_index >= 0, "UB detected, this should be avoided by previous if statement.")
	var swap = _flag_definitions.pop_back()
	_flag_definitions[definition_index] = swap
	_definition_lookup.erase(flag_name)
	sort_definitions()
	
	var old_max: int = max_index
	_calculate_max_flag()
	if old_max != max_index:
		flag_group_resized.emit(max_index)
	
	return true

## Returns a list of all flag names in this group.
func get_flag_names() -> PackedStringArray:
	var results: PackedStringArray = []
	
	for definition in _flag_definitions:
		results.append(definition[&"name"])
	
	return results

## Attempts to rename a flag to a new name. Returns RenameResult.SUCCES if no issues were encountered.
func rename_flag(old_flag_name: StringName, new_flag_name: StringName) -> RenameResult:
	if new_flag_name.is_empty():
		return RenameResult.EMPTY_NAME
	
	var definition_index: int = _definition_lookup.get(old_flag_name, -1)
	
	if definition_index == -1:
		return RenameResult.NO_ENTRY_FOUND
	
	if _definition_lookup.has(new_flag_name):
		return RenameResult.DUPLICATE_ENTRY
	
	var definition: Dictionary = _flag_definitions[definition_index]
	
	definition[&"name"] = new_flag_name
	
	flags[new_flag_name] = definition[&"value"]
	flags.erase(old_flag_name)
	
	_definition_lookup[new_flag_name] = definition_index
	_definition_lookup.erase(old_flag_name)
	
	return RenameResult.SUCCES

## Creates a (shallow) dictionary that represents the current state of the group information.
func to_dictionary() -> Dictionary:
	return {
		"group_name": group_name,
		"max_index": max_index,
		"flag_definitions": _flag_definitions
	}

static func from_dictionary(data: Dictionary) -> UCGroupInfo:
	var result: UCGroupInfo = UCGroupInfo.new()
	
	result.group_name = data["group_name"]
	result.max_index = data["max_index"]
	result._flag_definitions = data["flag_definitions"]
	
	for definition in result._flag_definitions:
		result.flags[definition[&"name"]] = definition[&"value"]
	
	result.sort_definitions()
	
	return result

## Recalculates the highest flag index based on the current state of the flags dictionary.
func _calculate_max_flag() -> void:
	var max: int = -1
	for flag_value: int in flags.values():
		if flag_value > max:
			max = flag_value
	
	max_index = max

## Reorders the flag definitions in order to rank from lowe
func sort_definitions() -> void:
	_flag_definitions.sort_custom(func(left: Dictionary, right: Dictionary) -> bool:
		if left[&"value"] < right[&"value"]:
			return true
		return false
	)
	
	for index: int in _flag_definitions.size():
		_definition_lookup[_flag_definitions[index][&"name"]] = index
