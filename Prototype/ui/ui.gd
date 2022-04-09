extends CanvasLayer
var game:Node


var fps:Node
var stats:Node
var minimap:Camera2D
var shop:Node
var shop_button:Node
var gold_label:Node


func _ready():
	game = get_tree().get_current_scene()
	fps = get_node("top_left/fps")
	stats = get_node("bot_mid/stats")
	minimap = game.get_node("map_camera")
	shop = get_node("top_right/shop")
	shop_button = get_node("top_right/shop_button")
	gold_label = get_node("top_right/gold_label")


func process():
	# if opt.show.fps:
	var f = Engine.get_frames_per_second()
	var n = game.all_units.size()
	fps.set_text('fps: '+str(f)+' u:'+str(n))
	
	if minimap and game.camera.zoom.x <= 1:
		if minimap.update_map_texture: minimap.get_map_texture()
		minimap.move_symbols()


# STATS


func update_stats():
	var unit = game.selected_unit
	if unit:
		stats.show()
		stats.get_node("name").text = "%s (%s) %s" % [unit.subtype, unit.type, unit.current_hp]
		stats.get_node("damage").text = "Damage: %s" % unit.current_damage
		stats.get_node("vision").text = "Vision: %s" % unit.current_vision
		if unit.moves: stats.get_node("speed").text = "Speed: %s" % unit.current_speed
		else: stats.get_node("speed").text = ""
		var texture = unit.get_texture()
		var portrait = stats.get_node("portrait/sprite")
		set_texture(portrait, texture)
	else:
		stats.hide()

func set_texture(portrait, texture):
	portrait.texture = texture.data
	portrait.region_rect = texture.region
	portrait.material = texture.material
	portrait.scale = texture.scale
	var sx = abs(portrait.scale.x)
	portrait.scale.x = -1 * sx if texture.mirror else sx


# HPBAR


func hide_hpbar():
	for unit in game.all_units:
		if (unit != game.selected_unit and 
				unit.has_node("hud") and 
				unit.current_hp == unit.hp):
			unit.get_node("hud/hpbar").visible = false


func show_hpbar():
	for unit in game.all_units:
		if unit.has_node("hud"):
			unit.get_node("hud/state").visible = true

func update_hpbar(unit):
	if unit.current_hp <= 0:
		unit.get_node("hud/hpbar/green").region_rect.size.x = 0
	else:
		if unit.has_node("hud") and game.camera.zoom.x >= 1:
			unit.get_node("hud/hpbar").visible = true
		var scale = float(unit.current_hp) / float(unit.hp)
		if scale < 0: scale = 0
		if scale > 1: scale = 1
		var size = unit.get_node("hud/hpbar/red").region_rect.size.x 
		unit.get_node("hud/hpbar/green").region_rect.size.x = scale * size


# STATE LABEL


func hide_state():
	for unit in game.all_units:
		if unit != game.selected_unit and unit.has_node("hud"):
			unit.get_node("hud/state").visible = false


func show_state():
	for unit in game.all_units:
		if unit.has_node("hud"):
			unit.get_node("hud/hpbar").visible = true
