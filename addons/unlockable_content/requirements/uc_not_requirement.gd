## A negative requirement, indicating the child requirement must not be met in order for 
## this requirement to be met.
extends UCRequirement
class_name UCNotRequirement

@export var requirement: UCRequirement

func is_met() -> bool:
	return not requirement.is_met()
