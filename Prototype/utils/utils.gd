extends Node
var game:Node


func _ready():
	game = get_tree().get_current_scene()



func circle_point_collision(p, c, r):
	return Vector2(p - c).length() < r


func circle_collision(c1, r1, c2, r2):
	return Vector2(c1 - c2).length() < (r1 + r2)


func sort_by_hp(array):
	var sorted = []
	for neighbor in array:
		sorted.append({
			"unit": neighbor,
			"hp": neighbor.current_hp
		})
	sorted.sort_custom(self, "compare_hp")
	return sorted


func compare_hp(a: Dictionary, b: Dictionary) -> bool:
	return a.hp < b.hp


func sort_by_distance(unit1, array):
	var sorted = []
	for unit2 in array:
		sorted.append({
			"unit": unit2,
			"distance": unit1.global_position.distance_to(unit2.global_position)
		})
	sorted.sort_custom(self, "compare_distance")
	return sorted


func compare_distance(a: Dictionary, b: Dictionary) -> bool:
	return a.distance < b.distance


func limit_angle(a):
	if (a > PI): a -= PI*2
	if (a < -PI): a += PI*2
	return a


func random_point():
	var o = 50
	return Vector2(o+randf()*(game.size-o*2), o+randf()*(game.size-o*2))


func unit_collides(unit1, p):
	var c1 = p + unit1.collision_position
	var r1 = unit1.collision_radius
	for unit2 in game.all_units:
		if unit2.collide:
			var c2 = unit2.global_position + unit2.collision_position
			var r2 = unit2.collision_radius
			if circle_collision(c1, r1, c2, r2):
				return true
	return false


func random_no_coll(unit):
	var p = random_point()
	while unit_collides(unit, p):
		p = random_point()
	return p

func point_random_no_coll(unit, point, offset):
	var x = (-offset) + (randf()*offset*2)
	var y = (-offset) + (randf()*offset*2)
	var p = point + Vector2(x, y)
	while unit_collides(unit, p):
		p = point_random_no_coll(unit, point, offset)
	return p