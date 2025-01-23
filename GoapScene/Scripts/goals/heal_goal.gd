extends GoapGoal

class_name HealGoal

func get_clazz():
	return "HealGoal"

func is_valid() -> bool:
	return WorldState.get_state("enemy_need_heal", true) 

func priority() -> int:
	return 3

func get_desired_state() -> Dictionary:
	return {
		"enemy_need_heal": false
	}
