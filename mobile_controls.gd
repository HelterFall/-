extends Control

signal movement_changed(value: Vector2)
signal look_delta(value: Vector2)

const JOYSTICK_RADIUS: float = 66.0
const JOYSTICK_CENTER_OFFSET: Vector2 = Vector2(112.0, -128.0)

var _joystick_id: int = -1
var _look_id: int = -1
var _joystick_center: Vector2 = Vector2.ZERO
var _joystick_position: Vector2 = Vector2.ZERO
var _last_look_position: Vector2 = Vector2.ZERO
var _show_touch_hints: bool = false


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_show_touch_hints = OS.has_feature("android") or OS.has_feature("ios") or DisplayServer.is_touchscreen_available()
	set_process_input(true)
	queue_redraw()


func _input(event: InputEvent) -> void:
	var viewport_size := get_viewport_rect().size
	_joystick_center = Vector2(JOYSTICK_CENTER_OFFSET.x, viewport_size.y + JOYSTICK_CENTER_OFFSET.y)

	if event is InputEventScreenTouch:
		if event.pressed:
			if event.position.x < viewport_size.x * 0.46 and _joystick_id == -1:
				_joystick_id = event.index
				_joystick_position = _joystick_center
				_update_joystick(event.position)
			elif _look_id == -1:
				_look_id = event.index
				_last_look_position = event.position
		else:
			if event.index == _joystick_id:
				_joystick_id = -1
				_joystick_position = _joystick_center
				movement_changed.emit(Vector2.ZERO)
			if event.index == _look_id:
				_look_id = -1
			queue_redraw()

	elif event is InputEventScreenDrag:
		if event.index == _joystick_id:
			_update_joystick(event.position)
		elif event.index == _look_id:
			var delta_pixels: Vector2 = event.position - _last_look_position
			_last_look_position = event.position
			look_delta.emit(delta_pixels)
		queue_redraw()


func _update_joystick(touch_position: Vector2) -> void:
	var offset: Vector2 = (touch_position - _joystick_center).limit_length(JOYSTICK_RADIUS)
	_joystick_position = _joystick_center + offset
	movement_changed.emit(Vector2(offset.x / JOYSTICK_RADIUS, -offset.y / JOYSTICK_RADIUS))


func _draw() -> void:
	if not _show_touch_hints:
		return
	var size := get_viewport_rect().size
	var center := Vector2(JOYSTICK_CENTER_OFFSET.x, size.y + JOYSTICK_CENTER_OFFSET.y)
	var active_position := _joystick_position if _joystick_id != -1 else center
	draw_circle(center, JOYSTICK_RADIUS + 5.0, Color(0.68, 0.78, 0.88, 0.10))
	draw_arc(center, JOYSTICK_RADIUS, 0.0, TAU, 56, Color(0.78, 0.86, 0.95, 0.35), 2.0, true)
	draw_circle(active_position, 25.0, Color(0.82, 0.89, 0.97, 0.28))
	draw_arc(active_position, 25.0, 0.0, TAU, 40, Color(0.9, 0.95, 1.0, 0.48), 1.5, true)
	draw_string(get_theme_default_font(), Vector2(size.x - 138.0, size.y - 38.0), "СМОТРЕТЬ", HORIZONTAL_ALIGNMENT_CENTER, 110.0, 13, Color(0.85, 0.9, 0.96, 0.35))
