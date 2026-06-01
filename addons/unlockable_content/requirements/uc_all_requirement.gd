## A requirement that dictates that all child requirements must be met.
class_name UCAllRequirement
extends UCRequirement

@export var requirements: Array[UCRequirement]

func is_met() -> bool:
	for requirement in requirements:
		if not requirement.is_met():
			return false
	
	return true
