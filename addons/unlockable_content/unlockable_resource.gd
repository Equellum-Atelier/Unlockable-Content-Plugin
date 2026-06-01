@tool
## A resource that can be managed by the UnlockableContent autoload singleton. This class is not meant
## to be instantiated by itself and instead it should be extended by specialized classes.
## Child classes need to be annotated with @tool in order to be used inside the editor itself.
class_name UnlockableResource
extends Resource


## Determines if the unlockable resource requires a specific flag to be set. If set to false, it is considered unlocked by default.
@export var has_requirement: bool:
	set(state):
		has_requirement = state
		notify_property_list_changed()


## The group name used for looking up which flag set should be used for checking if the resource is unlocked.
var flag_group: StringName:
	set(group):
		if flag_group != group:
			unlock_flag = &""
		flag_group = group
		notify_property_list_changed()

## The flag index of the flag set that will be checked to see if the resource is unlocked.
var unlock_flag: StringName = &""


## Determines if the resources should be considered unlocked.
func is_unlocked() -> bool:
	if has_requirement:
		assert(not flag_group.is_empty(), "No flag group set.")
		assert(not unlock_flag.is_empty(), "Flag is in invalid state.")
		return UnlockableContent.is_flag_set(flag_group, unlock_flag)
	
	return true


func _get_display_name() -> String:
	return resource_name


func _get_display_name_property_name() -> StringName:
	return &"resource_name"


## Editor function: Override to get icons in the resource management tabs when creating new resources.
func _get_icon() -> Texture2D:
	return null


## Editor function: The name of the property in charge of supplying the icon. Used for monitoring when to refresh the icon.
func _get_icon_property_name() -> StringName:
	return &""


func _get_property_list() -> Array[Dictionary]:
	var properties: Array[Dictionary] = []
	
	if not has_requirement:
		return properties
	
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

# TODO: keep an eye out on https://github.com/godotengine/godot/pull/115182. if it gets merged, 
#		it allows for added descriptions to the properties created here.
