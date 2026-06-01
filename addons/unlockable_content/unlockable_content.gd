## An interface into the unlockable database, used to check flags of specific groups.
@tool
extends Node

## A signal that gets emited when a flag in a flag group's value gets changed.
signal flag_changed(flag_group: StringName, flag: StringName, value: bool)

var database: UCFlagDatabase
var state: UCState

func _init() -> void:
	database = UCFlagDatabase.new()
	state = UCState.new()


func _enter_tree() -> void:
	database.reload()
	state.initialize(database)


## Returns a list of flag names in a given group, returns an empty array if no group was found.
func get_flag_names(group_name: StringName) -> PackedStringArray:
	var group: UCGroupInfo = database.get_group_info(group_name)
	if group == null:
		return []
	
	var flag_names: PackedStringArray = []
	flag_names.append_array(group.flags.keys())
	return flag_names

## Checks if the flag in the desired group is set to true or false. 
func is_flag_set(group_name: StringName, flag_name: StringName) -> bool:
	return state.is_flag_set(database, group_name, flag_name)

## Sets the flag in the desired group to the passed value. 
func set_flag(group_name: StringName, flag_name: StringName, value: bool) -> void:
	state.set_flag(database, group_name, flag_name, value)
