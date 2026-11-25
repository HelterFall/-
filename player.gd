extends CharacterBody3D

var mobile_move: Vector2 = Vector2.ZERO
var mobile_look: Vector2 = Vector2.ZERO
var camera: Camera3D
var look_sensitivity: float = 0.0022
var walk_speed: float = 4.4
var gravity_strength: float = 22.0


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func set_mobile_move(value: Vector2) -> void:
	mobile_move = value.limit_length(1.0)


func add_mobile_look(delta_pixels: Vector2) -> void:
	mobile_look += delta_pixels


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	elif event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	elif event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		_apply_look(event.relative)


func _process(_delta: float) -> void:
	if mobile_look.length_squared() > 0.0:
		_apply_look(mobile_look)
		mobile_look = Vector2.ZERO


func _physics_process(delta: float) -> void:
	var keyboard := Vector2.ZERO
	keyboard.x = float(Input.is_key_pressed(KEY_D)) - float(Input.is_key_pressed(KEY_A))
	keyboard.y = float(Input.is_key_pressed(KEY_S)) - float(Input.is_key_pressed(KEY_W))
	if Input.is_key_pressed(KEY_RIGHT):
		keyboard.x += 1.0
	if Input.is_key_pressed(KEY_LEFT):
		keyboard.x -= 1.0
	if Input.is_key_pressed(KEY_DOWN):
		keyboard.y += 1.0
	if Input.is_key_pressed(KEY_UP):
		keyboard.y -= 1.0

	var move_input := keyboard.normalized() if keyboard.length_squared() > 0.0 else mobile_move
	var local_direction := Vector3(move_input.x, 0.0, move_input.y)
	var world_direction := (global_transform.basis * local_direction).normalized()

	velocity.x = world_direction.x * walk_speed
	velocity.z = world_direction.z * walk_speed
	if is_on_floor():
		if velocity.y < 0.0:
			velocity.y = 0.0
	else:
		velocity.y -= gravity_strength * delta

	move_and_slide()


func _apply_look(delta_pixels: Vector2) -> void:
	rotate_y(-delta_pixels.x * look_sensitivity)
	if camera != null:
		camera.rotate_x(-delta_pixels.y * look_sensitivity)
		camera.rotation.x = clampf(camera.rotation.x, deg_to_rad(-82.0), deg_to_rad(82.0))
