extends TileMap
var game:Node

var tile_map_size:int
var trees:TileMap

var clear_skip:int = 30
var clear_frame:int = 0


func _ready():
	game = get_tree().get_current_scene()
	
	trees = get_node("../trees")
	
	tile_map_size = floor(game.size / 8)


func skip_start():
	clear_frame += 1
	if clear_frame%clear_skip == 0: cover_map()


func cover_map():
	for y in floor(tile_map_size):
		for x in floor(tile_map_size):
			game.map.fog.set_cell(x, y, 0)



var sight_mem:Dictionary = {}

func compute_sight(unit):
	var id = unit.current_vision
	if id in sight_mem: return sight_mem[id]
	var a = []
	if unit.current_vision > 0:
		var rad = round(unit.current_vision/cell_size.x)
		for y in range(0, 2*rad):
			a.append([])
			for x in range(0, 2*rad):
				var r = Vector2(x-rad, y-rad)
				var d = r.length()
				a[a.size()-1].append(d < rad)
	sight_mem[id] = a
	return a


func clear_sigh_skip(unit):
	if clear_frame%clear_skip == 0:
		clear_sight(unit)


func clear_sight(unit):
	if unit.current_vision > 0:
		var rad = round(unit.current_vision/cell_size.x)
		var pos = world_to_map(unit.global_position)
		var a = compute_sight(unit)
		
		for y in a.size():
			for x in a[y].size():
				if (a[y][x]):
					var p = pos - Vector2(rad,rad) + Vector2(x,y)
					if (unit.type == "building"): 
						game.map.fog.set_cellv(p, -1)
					else: 
						if game.map.fog.get_cellv(p) >= 0:
							var line = game.unit.path.path_finder.expandPath([[pos.x, pos.y], [p.x, p.y]])
							var blocked = false
							for point in line:
								var tree = trees.get_cell(point[0]/3, point[1]/3)
								if tree > 0: 
									blocked = true
									
							if not blocked: game.map.fog.set_cellv(p, -1)
							
#				var la = PI/6
#				var a = abs(game.utils.limit_angle(r.angle() - unit.angle))
#				if d > rad and (unit.type == "building" or a<la):
#					game.map.fog.set_cellv(pos + r, -1)