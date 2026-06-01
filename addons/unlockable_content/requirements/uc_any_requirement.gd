## A requirement that dictates that any child requirements must be met,
## even if other requirements have not been met yet.
class_name UCAnyRequirement
extends UCRequirement

@export var requirements: Array[UCRequirement]

func is_met() -> bool:
	if requirements.is_empty():
		return true
	
	for requirement in requirements:
		if requirement.is_met():
			return true
	
	return false
