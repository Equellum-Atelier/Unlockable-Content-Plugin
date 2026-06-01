class_name UCFlagDatabase
extends RefCounted

const ROOT: String = "unlockable_content/flag_groups"

var groups: Array[UCGroupInfo] = []
var _groups_lookup: Dictionary[StringName, UCGroupInfo] = {}

func reload() -> void:
	groups.clear()
	_groups_lookup.clear()
	
	var properties := ProjectSettings.get_property_list()
	
	for property in properties:
		var property_name: String = property["name"] as String
		
		if not property_name.begins_with(ROOT + '/'):
			continue
		
		var group_info_data: Dictionary = ProjectSettings.get_setting(property_name)
		var group_info: UCGroupInfo = UCGroupInfo.from_dictionary(group_info_data)
		
		_groups_lookup[group_info.group_name] = group_info
		groups.append(group_info)

## Registers a new flag group to the registery, if a group with the given name
## already exists, it will have no effect. Returns the group instance.
func register_group(group_name: StringName) -> UCGroupInfo:
	if group_name.is_empty():
		push_error("Group name must not be empty")
		return
	
	var group: UCGroupInfo = _groups_lookup.get(group_name) as UCGroupInfo
	if not group:
		group = UCGroupInfo.new()
		group.group_name = group_name
		groups.append(group)
		_groups_lookup[group_name] = group
		
		var setting_name: String = ROOT.path_join(group_name)
		ProjectSettings.set_setting(setting_name, group.to_dictionary())
		ProjectSettings.set_as_internal(setting_name, true)
		ProjectSettings.save()
	return group

## Registers a new flag under a set index in the given group. If the group does not
## exist yet it will be automatically created.
func register_flag(group_name: StringName, flag_name: StringName, index: int = -1) -> void:
	if group_name.is_empty():
		push_error("Group name must not be empty")
		return
	
	if flag_name.is_empty():
		push_error("Flag name must not be empty")
		return
	
	var group: UCGroupInfo = _groups_lookup.get(group_name) as UCGroupInfo
	if not group:
		group = UCGroupInfo.new()
		group.group_name = group_name
		groups.append(group)
		_groups_lookup[group_name] = group
	
	if index < 0:
		index = group.add_flag_auto_increment(flag_name)
	else:
		group.add_flag(flag_name, index)
	
	var setting_name: String = ROOT.path_join(group_name)
	ProjectSettings.set_setting(setting_name, group.to_dictionary())
	ProjectSettings.set_as_internal(setting_name, true)
	ProjectSettings.save()

func rename_flag(group_name: StringName, old_flag_name: StringName, new_flag_name: StringName) -> void:
	if group_name.is_empty():
		push_error("Group name must not be empty")
		return
	
	if new_flag_name.is_empty():
		push_error("New flag name must not be empty")
		return
	
	var group: UCGroupInfo = _groups_lookup.get(group_name) as UCGroupInfo
	if not group:
		push_error("No group found: '%s'" % group_name)
		return
	
	group.rename_flag(old_flag_name, new_flag_name)
	ProjectSettings.set_setting(ROOT.path_join(group_name), group.to_dictionary())
	ProjectSettings.save()

func update_or_register_group(group: UCGroupInfo) -> void:
	register_group(group.group_name)
	
	ProjectSettings.set_setting(ROOT.path_join(group.group_name), group.to_dictionary())
	ProjectSettings.save()

## Returns a list of registered groups.
func get_group_names() -> Array[StringName]:
	var result: Array[StringName] = []
	for group_info in groups:
		result.append(group_info.group_name)
	return result

## Returns the group information for the given group. If no group exists, null is returned.
func get_group_info(group_name: StringName) -> UCGroupInfo:
	return _groups_lookup.get(group_name)

## Checks if a given flag group exists.
func has_flag_group(group_name: StringName) -> bool:
	return _groups_lookup.has(group_name)

## Removes a flag group by it's name. Returns the removed group, or null if no group was removed
func remove_group_by_name(group_name: StringName) -> UCGroupInfo:
	var group: UCGroupInfo = _groups_lookup.get(group_name)
	if not group:
		return null
	
	groups.erase(group)
	_groups_lookup.erase(group_name)
	ProjectSettings.set_setting(ROOT.path_join(group_name), null)
	ProjectSettings.save()
	return group

## Removes a flag group by it's position in the group array
func remove_group_by_index(index: int) -> UCGroupInfo:
	var group: UCGroupInfo = groups.get(index) as UCGroupInfo
	if not group:
		return null
	
	groups.erase(group)
	_groups_lookup.erase(group.group_name)
	ProjectSettings.set_setting(ROOT.path_join(group.group_name), null)
	return group

## Checks if a given flag exists in a flag group.
func has_flag(group_name: StringName, flag_name: StringName) -> bool:
	var group_info: UCGroupInfo = _groups_lookup.get(group_name) as UCGroupInfo
	if not group_info:
		return false
	
	return group_info.flags.has(flag_name)

## Returns the index of a given flag in a group. If the flag does not exist, -1 is returned.
func get_flag_index(group_name: StringName, flag_name: StringName) -> int:
	var group_info: UCGroupInfo = _groups_lookup.get(group_name) as UCGroupInfo
	if not group_info:
		return -1
	
	return group_info.flags.get(flag_name, -1)
