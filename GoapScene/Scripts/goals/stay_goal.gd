extends GoapGoal

class_name StayGoal

func get_clazz():
	return "StayGoal"

func is_valid() -> bool:
	return WorldState.get_state("player_in_range", true) 

func priority() -> int:
	return 2

func get_desired_state() -> Dictionary:
	return {
		"player_in_range": false
	}
