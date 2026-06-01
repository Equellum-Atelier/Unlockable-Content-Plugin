@tool
class_name UCFlagRequirement
extends UCRequirement

## The group name used for looking up which flag set should be used for checking if the resource is unlocked.
var flag_group: StringName:
	set(group):
		if flag_group != group:
			unlock_flag = &""
		flag_group = group
		notify_property_list_changed()

## The flag index of the flag set that will be checked to see if the resource is unlocked.
var unlock_flag: StringName = &""

func is_met() -> bool:
	return UnlockableContent.is_flag_set(flag_group, unlock_flag)

func _get_property_list() -> Array[Dictionary]:
	var properties: Array[Dictionary] = []
	
	var flag_group_hint: String = ",".join(UnlockableContent.database.get_group_names())
	
	properties.append({
		"name": "flag_group",
		"type": TYPE_STRING_NAME,
		"hint": PROPERTY_HINT_ENUM,
		"hint_string": flag_group_hint,
	})
	
	var flag_group_info: UCGroupInfo = UnlockableContent.database.get_group_info(flag_group)
	if flag_group_info:
		var unlock_flag_hint: String = ",".join(flag_group_info.get_flag_names())
		
		properties.append({
		"name": "unlock_flag",
		"type": TYPE_STRING_NAME,
		"hint": PROPERTY_HINT_ENUM,
		"hint_string": unlock_flag_hint,
	})
	
	return properties
