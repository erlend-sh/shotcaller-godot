extends Node

# self = Goap.Goals

# Lists all Goal contracts

var _goals = {
	"AttackEnemiesGoal": preload("goals/attack_enemies.gd").new(),
	"CommandAttackGoal": preload("goals/command_attack.gd").new(),
	"CommandAttackEnemyGoal": preload("goals/command_attack_enemy.gd").new(),
	"NeedLumberGoal": preload("goals/need_lumber.gd").new(),
	"NeedSafetyGoal": preload("goals/need_safety.gd").new(),
	"PursueEnemiesGoal": preload("goals/pursue_enemies.gd").new(),
	"RetreatGoal": preload("goals/retreat_goal.gd").new(),
}


func get_goal(goal_name, default = null):
	return _goals.get(goal_name, default)


func set_goal(goal_name, value):
	_goals[goal_name] = value