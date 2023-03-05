extends Camera2D

# self = Crafty_camera

onready var game = get_tree().get_current_scene()

# PAN
var is_panning:bool = false
var pan_position:Vector2 = Vector2.ZERO
# ZOOM
var is_zooming:bool = false
var zoom_default:Vector2 = Vector2.ONE
var zoom_limit:Vector2 = Vector2.ONE
var default_zoom_sensitivity := .5
var zoom_in_limit := .5
# KEYBOARD
var arrow_keys_move:Vector2 = Vector2.ZERO
var arrow_keys_speed := 4
# TOUCH
var pinch_sensitivity := 3
var _touches = {}
var _touches_info = {
	"num_touch_last_frame":0, 
	"radius":0,
	"last_radius":0, 
	"total_pan":0, 
	"last_avg_pos":Vector2.ZERO, 
	"cur_avg_pos":Vector2.ZERO
}

func _ready():
	zoom = zoom_default


func input(event):
	var pressed = event.is_pressed()
	# KEYBOARD
	if event is InputEventKey:
		
		match event.scancode:
			# LEADER KEYS
			KEY_1: focus_leader(1)
			KEY_2: focus_leader(2)
			KEY_3: focus_leader(3)
			KEY_4: focus_leader(4)
			KEY_5: focus_leader(5)
			
			# ARROW KEYS
			KEY_LEFT:  arrow_keys_move.x = -arrow_keys_speed if pressed else 0
			KEY_RIGHT: arrow_keys_move.x =  arrow_keys_speed if pressed else 0
			KEY_UP:    arrow_keys_move.y = -arrow_keys_speed if pressed else 0
			KEY_DOWN:  arrow_keys_move.y =  arrow_keys_speed if pressed else 0
		
		# NUMBER KEYPAD
		if not pressed:
			var cam_move = null;
			var x = WorldState.map_mid.x
			match event.scancode:
				# nine grid cam movement
				KEY_KP_1: cam_move = [-x, x]
				KEY_KP_2: cam_move = [0, x]
				KEY_KP_3: cam_move = [x, x]
				KEY_KP_4: cam_move = [-x, 0]
				KEY_KP_5: cam_move = [0, 0]
				KEY_KP_6: cam_move = [x, 0]
				KEY_KP_7: cam_move = [-x, -x]
				KEY_KP_8: cam_move = [0, -x]
				KEY_KP_9: cam_move = [x, -x]
				# ZOOM KEYS
				KEY_KP_SUBTRACT: full_zoom_out()
				KEY_KP_ADD: full_zoom_in()
			
			if cam_move: 
				zoom_reset()
				global_position = Vector2(cam_move[0], cam_move[1])
	
	if game:
		var over_minimap = game.ui.minimap.over_minimap(event)
		# MOUSE PAN
		if event.is_action("pan") and not over_minimap:
			is_panning = event.is_action_pressed("pan")
		elif event is InputEventMouseMotion:
			if is_panning: pan_position = Vector2(-1 * event.relative)
		
		
		# TOUCH PAN AND ZOOM
		if event is InputEventScreenTouch and not over_minimap:
			if not pressed:
				_touches.erase(event.index)
				if _touches.size() == 0:
					_touches_info.last_radius = 0
					_touches_info.last_avg_pos = Vector2.ZERO
					_touches_info.radius = 0
					_touches_info.cur_avg_pos = Vector2.ZERO
			else:
				is_panning = true
				if(_touches.size() == 0):
					_touches_info.last_avg_pos = event.position
					_touches_info.cur_avg_pos = event.position
				_touches[event.index] = {"start":event, "current":event}
		if event is InputEventScreenDrag:
			if not event.index in _touches:
				_touches[event.index] = {"start":event, "current":event}
				is_panning = true
			if is_panning : 
				_touches[event.index]["current"] = event
				var avg_touch = Vector2(0,0)
				for key in _touches:
					avg_touch += _touches[key]["current"].position
				avg_touch /= _touches.size()
				_touches_info.cur_avg_pos = avg_touch
				pan_position = Vector2(-1 * (_touches_info.cur_avg_pos - _touches_info.last_avg_pos))
		
	# ZOOM
	if event.is_action_pressed("zoom_in"):
		_zoom_camera(-1)
	if event.is_action_pressed("zoom_out"):
		_zoom_camera(1)


func map_loaded():
	var mid = WorldState.get_state("map_mid")
	limit_left = -mid.x
	limit_top = -mid.y
	limit_right = mid.x
	limit_bottom = mid.y


func focus_leader(index):
	if game.player_leaders.size() >= index:
		var leader = game.player_leaders[index-1]
		if leader:
			var mid = WorldState.get_state("map_mid")
			global_position = leader.global_position - mid
			game.selection.select_unit(leader)
			game.ui.leaders_icons.buttons_focus(leader)


func zoom_reset(): 
	zoom = zoom_default
	
	
func full_zoom_in(): 
	zoom = Vector2(zoom_limit.x,zoom_limit.x)
	
	
func full_zoom_out(): 
	zoom = Vector2(zoom_limit.y, zoom_limit.y)


func _zoom_camera(dir):
	var new_zoom = zoom + Vector2(default_zoom_sensitivity, default_zoom_sensitivity) * dir
	
	var zoom_out_limit = zoom_limit.y
	
	new_zoom.x = clamp(new_zoom.x, zoom_in_limit, zoom_out_limit)
	new_zoom.y = clamp(new_zoom.y, zoom_in_limit, zoom_out_limit)
	
	zoom = new_zoom
	
#	TODO: fix map zoom and remove zoom limits from the map
#	var size = get_viewport().size
#	var max_size = max(size.x, size.y)
#	var zoom_out_limit = game.map.size / max_size


func process():
	if game.started: 
		
		# APPLY MOUSE PAN
		if is_panning: translate(pan_position * zoom.x)
		# APPLY KEYBOARD PAN
		else: translate(arrow_keys_move)
		
		if(_touches.size()>0):
			_touches_info.radius = abs(_touches.values()[0].current.position.x - _touches_info.cur_avg_pos.x) + abs(_touches.values()[0].current.position.y - _touches_info.cur_avg_pos.y)
			if(_touches_info.last_radius != 0 && _touches.size() > 1):
				_zoom_camera(pinch_sensitivity * (_touches_info["last_radius"] - _touches_info["radius"]) / _touches_info["last_radius"])
		
		# RESET VARS AND SET LAST VARS
		_touches_info.last_radius = _touches_info.radius
		_touches_info.last_avg_pos = _touches_info.cur_avg_pos
		_touches_info.num_touch_last_frame = _touches.size()
		pan_position = Vector2.ZERO
		
		# KEEP CAMERA PAN LIMITS
		var x = game.map.camera_limit.x
		var y = game.map.camera_limit.y
		global_position.x = clamp(global_position.x, -x, x)
		global_position.y = clamp(global_position.y, -y, y)
		
