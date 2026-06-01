@tool
## A resource that can be managed by the UnlockableContent autoload singleton. This class is not meant
## to be instantiated by itself and instead it should be extended by specialized classes.
## Child classes need to be annotated with @tool in order to be used inside the editor itself.
class_name UnlockableResource
extends Resource


## Determines what prerequisites have to be met before the resource is unlocked. 
## If not set, it is considered unlocked by default.
@export var requirement: UCRequirement

## Determines if the resources should be considered unlocked.
func is_unlocked() -> bool:
	if requirement:
		return requirement.is_met()
	
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
