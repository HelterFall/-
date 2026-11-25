extends Node3D

var rng := RandomNumberGenerator.new()
var player: CharacterBody3D


func _ready() -> void:
	rng.randomize()
	_build_world_environment()
	_build_ground()
	_build_buildings()
	_build_playground()
	_build_trees_and_benches()
	_build_lamps()
	_build_parked_car()
	_build_snowfall()
	_build_player()
	_build_hud()


func _material(color: Color, roughness: float = 0.92, emission: Color = Color.BLACK) -> StandardMaterial3D:
	var result := StandardMaterial3D.new()
	result.albedo_color = color
	result.roughness = roughness
	if emission != Color.BLACK:
		result.emission_enabled = true
		result.emission = emission
		result.emission_energy_multiplier = 1.25
	return result


func _build_world_environment() -> void:
	var world := WorldEnvironment.new()
	var environment := Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color(0.006, 0.012, 0.027)
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color(0.19, 0.25, 0.38)
	environment.ambient_light_energy = 0.32
	environment.reflected_light_source = Environment.REFLECTION_SOURCE_BG
	environment.fog_enabled = true
	environment.fog_light_color = Color(0.12, 0.17, 0.27)
	environment.fog_density = 0.012
	environment.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	world.environment = environment
	add_child(world)

	var moonlight := DirectionalLight3D.new()
	moonlight.rotation_degrees = Vector3(-48.0, -28.0, 0.0)
	moonlight.light_color = Color(0.46, 0.58, 0.82)
	moonlight.light_energy = 0.22
	moonlight.shadow_enabled = true
	add_child(moonlight)


func _build_ground() -> void:
	var snow := _material(Color(0.48, 0.55, 0.65))
	var packed_snow := _material(Color(0.22, 0.28, 0.37))
	_box(self, Vector3(0.0, -0.24, -8.0), Vector3(100.0, 0.48, 100.0), snow, true)
	_box(self, Vector3(0.0, 0.015, 6.0), Vector3(3.4, 0.035, 45.0), packed_snow)
	_box(self, Vector3(-7.0, 0.015, -9.0), Vector3(1.2, 0.035, 30.0), packed_snow)
	_box(self, Vector3(7.0, 0.015, -9.0), Vector3(1.2, 0.035, 30.0), packed_snow)

	var drift_material := _material(Color(0.63, 0.69, 0.77))
	for i in range(42):
		var x := rng.randf_range(-18.0, 18.0)
		var z := rng.randf_range(-29.0, 18.0)
		var mound := _sphere(self, Vector3(x, 0.10, z), Vector3(rng.randf_range(0.45, 1.8), rng.randf_range(0.12, 0.36), rng.randf_range(0.45, 1.25)), drift_material)
		mound.rotation.y = rng.randf_range(0.0, TAU)


func _build_buildings() -> void:
	_build_building(Vector3(-20.0, 0.0, -10.0), PI * 0.5, 34.0, 8)
	_build_building(Vector3(20.0, 0.0, -10.0), -PI * 0.5, 34.0, 8)
	_build_building(Vector3(0.0, 0.0, -34.0), 0.0, 48.0, 9)


func _build_building(origin: Vector3, angle: float, width: float, floors: int) -> void:
	var building := Node3D.new()
	building.position = origin
	building.rotation.y = angle
	add_child(building)

	var wall := _material(Color(0.30, 0.34, 0.40))
	var side_wall := _material(Color(0.21, 0.25, 0.31))
	var concrete := _material(Color(0.42, 0.45, 0.49))
	var dark_glass := _material(Color(0.035, 0.065, 0.11), 0.28)
	var lit_glass := _material(Color(0.85, 0.59, 0.28), 0.3, Color(1.0, 0.43, 0.12))
	var height := 2.55 * float(floors)
	_box(building, Vector3(0.0, height * 0.5, 0.0), Vector3(width, height, 5.7), wall)
	_box(building, Vector3(0.0, height + 0.18, 0.0), Vector3(width + 0.6, 0.36, 6.1), concrete)
	_box(building, Vector3(0.0, 0.48, 2.92), Vector3(width, 0.8, 0.18), side_wall)

	var columns := int(width / 2.35)
	for floor_index in range(floors):
		var y := 1.35 + float(floor_index) * 2.48
		_box(building, Vector3(0.0, float(floor_index) * 2.55 + 0.05, 2.91), Vector3(width, 0.12, 0.22), concrete)
		for column in range(columns):
			var x := -width * 0.5 + 1.25 + float(column) * (width - 2.5) / maxf(1.0, float(columns - 1))
			var is_lit := rng.randf() < 0.22
			var glass := lit_glass if is_lit else dark_glass
			_box(building, Vector3(x, y, 2.99), Vector3(1.30, 1.54, 0.09), glass)

	_box(building, Vector3(-width * 0.5 + 0.2, height * 0.5, 0.0), Vector3(0.35, height, 5.9), concrete)
	_box(building, Vector3(width * 0.5 - 0.2, height * 0.5, 0.0), Vector3(0.35, height, 5.9), concrete)


func _build_playground() -> void:
	var metal := _material(Color(0.16, 0.22, 0.29), 0.58)
	var faded_red := _material(Color(0.46, 0.19, 0.17))
	var faded_blue := _material(Color(0.20, 0.32, 0.43))
	var old_yellow := _material(Color(0.66, 0.48, 0.20))
	var rubber := _material(Color(0.16, 0.20, 0.27))
	var wood := _material(Color(0.31, 0.25, 0.21))

	# Старые качели.
	var swing_z := -7.0
	var left := Vector3(-5.1, 0.0, swing_z)
	var right := Vector3(-1.0, 0.0, swing_z)
	_rod(self, left + Vector3(0.0, 4.0, 0.0), left + Vector3(0.0, 0.12, 0.0), 0.105, metal)
	_rod(self, right + Vector3(0.0, 4.0, 0.0), right + Vector3(0.0, 0.12, 0.0), 0.105, metal)
	_rod(self, Vector3(-5.1, 3.95, swing_z), Vector3(-1.0, 3.95, swing_z), 0.12, faded_blue)
	for seat_x in [-4.2, -2.0]:
		_rod(self, Vector3(seat_x - 0.32, 3.88, swing_z), Vector3(seat_x - 0.32, 1.05, swing_z), 0.025, metal)
		_rod(self, Vector3(seat_x + 0.32, 3.88, swing_z), Vector3(seat_x + 0.32, 1.05, swing_z), 0.025, metal)
		_box(self, Vector3(seat_x, 1.0, swing_z), Vector3(0.95, 0.16, 0.42), faded_red)

	# Горка с площадкой и лестницей.
	var tower := Vector3(3.3, 0.0, -8.2)
	_box(self, tower + Vector3(0.0, 1.82, 0.0), Vector3(2.0, 0.18, 2.0), faded_blue)
	for x in [-0.82, 0.82]:
		_rod(self, tower + Vector3(x, 0.05, -0.72), tower + Vector3(x, 1.9, -0.72), 0.075, metal)
		_rod(self, tower + Vector3(x, 0.05, 0.72), tower + Vector3(x, 1.9, 0.72), 0.075, metal)
	for step in range(5):
		_box(self, tower + Vector3(0.0, 0.24 + float(step) * 0.28, -0.72 - float(step) * 0.08), Vector3(1.0, 0.07, 0.23), old_yellow)
	var slide := _box(self, tower + Vector3(0.0, 0.93, 1.78), Vector3(1.3, 0.16, 3.1), faded_red)
	slide.rotation.x = PI / 5.8
	_rod(self, tower + Vector3(-0.58, 1.75, 0.82), tower + Vector3(-0.58, 0.15, 3.05), 0.065, metal)
	_rod(self, tower + Vector3(0.58, 1.75, 0.82), tower + Vector3(0.58, 0.15, 3.05), 0.065, metal)
	_box(self, Vector3(0.8, 0.08, -5.2), Vector3(13.0, 0.12, 8.8), rubber)

	# Невысокая карусель.
	_cylinder(self, Vector3(7.1, 0.42, -12.7), 0.12, 0.82, metal)
	_cylinder(self, Vector3(7.1, 0.83, -12.7), 0.11, 0.82, old_yellow)
	for i in range(4):
		var a := float(i) * PI * 0.5
		var end := Vector3(7.1 + cos(a) * 1.25, 0.82, -12.7 + sin(a) * 1.25)
		_rod(self, Vector3(7.1, 0.82, -12.7), end, 0.055, faded_blue)
		_box(self, end, Vector3(0.42, 0.12, 0.42), faded_red)


func _build_trees_and_benches() -> void:
	var bark := _material(Color(0.19, 0.22, 0.27))
	var branch := _material(Color(0.24, 0.28, 0.34))
	var snow := _material(Color(0.69, 0.75, 0.82))
	var bench_wood := _material(Color(0.25, 0.22, 0.21))
	var bench_metal := _material(Color(0.13, 0.17, 0.22))

	var tree_positions := [
		Vector3(-10.8, 0.0, -3.0), Vector3(-12.2, 0.0, -15.0),
		Vector3(11.0, 0.0, -4.0), Vector3(12.0, 0.0, -19.0),
		Vector3(-8.8, 0.0, -25.0), Vector3(8.8, 0.0, -27.0)
	]
	for base in tree_positions:
		var height := rng.randf_range(4.2, 6.0)
		_rod(self, base + Vector3(0.0, 0.0, 0.0), base + Vector3(0.0, height, 0.0), 0.18, bark)
		for branch_index in range(7):
			var y := rng.randf_range(1.5, height - 0.3)
			var sign_x := -1.0 if branch_index % 2 == 0 else 1.0
			var length := rng.randf_range(1.0, 2.3)
			var start: Vector3 = base + Vector3(0.0, y, 0.0)
			var finish: Vector3 = start + Vector3(sign_x * length, rng.randf_range(0.45, 1.25), rng.randf_range(-0.65, 0.65))
			_rod(self, start, finish, 0.055, branch)
			if branch_index % 2 == 0:
				_sphere(self, finish, Vector3(0.22, 0.12, 0.22), snow)

	for z in [-1.5, -18.0]:
		_box(self, Vector3(-8.2, 0.62, z), Vector3(2.6, 0.18, 0.65), bench_wood)
		_box(self, Vector3(-8.2, 1.15, z - 0.25), Vector3(2.6, 0.9, 0.16), bench_wood)
		for x in [-9.1, -7.3]:
			_rod(self, Vector3(x, 0.1, z - 0.2), Vector3(x, 0.65, z - 0.2), 0.055, bench_metal)
			_rod(self, Vector3(x, 0.1, z + 0.2), Vector3(x, 0.65, z + 0.2), 0.055, bench_metal)


func _build_lamps() -> void:
	var pole_material := _material(Color(0.12, 0.16, 0.22), 0.55)
	var glow := _material(Color(1.0, 0.72, 0.42), 0.2, Color(1.0, 0.52, 0.20))
	for point in [Vector3(-9.0, 0.0, 7.0), Vector3(9.0, 0.0, -3.0), Vector3(-9.0, 0.0, -18.0), Vector3(9.0, 0.0, -24.0)]:
		_rod(self, point, point + Vector3(0.0, 6.2, 0.0), 0.085, pole_material)
		_rod(self, point + Vector3(0.0, 6.0, 0.0), point + Vector3(0.9, 6.2, 0.0), 0.065, pole_material)
		_sphere(self, point + Vector3(0.92, 6.05, 0.0), Vector3(0.19, 0.14, 0.19), glow)
		var light := OmniLight3D.new()
		light.position = point + Vector3(0.92, 5.9, 0.0)
		light.light_color = Color(1.0, 0.68, 0.39)
		light.light_energy = 1.15
		light.omni_range = 11.0
		light.shadow_enabled = false
		add_child(light)


func _build_parked_car() -> void:
	var car := Node3D.new()
	car.position = Vector3(10.8, 0.0, 8.8)
	car.rotation.y = -0.32
	add_child(car)
	var body := _material(Color(0.16, 0.21, 0.27), 0.48)
	var glass := _material(Color(0.035, 0.065, 0.09), 0.22)
	var tire := _material(Color(0.035, 0.04, 0.05))
	var lamp := _material(Color(0.8, 0.65, 0.42), 0.25, Color(0.85, 0.42, 0.15))
	_box(car, Vector3(0.0, 0.78, 0.0), Vector3(4.2, 1.0, 2.0), body)
	_box(car, Vector3(-0.15, 1.48, 0.0), Vector3(2.45, 0.68, 1.72), body)
	_box(car, Vector3(-0.15, 1.5, 0.9), Vector3(2.05, 0.48, 0.045), glass)
	_box(car, Vector3(-0.15, 1.5, -0.9), Vector3(2.05, 0.48, 0.045), glass)
	for x in [-1.32, 1.32]:
		for z in [-0.93, 0.93]:
			var wheel := _cylinder(car, Vector3(x, 0.43, z), 0.43, 0.24, tire)
			wheel.rotation.z = PI * 0.5
	for z in [-0.74, 0.74]:
		_box(car, Vector3(2.12, 0.84, z), Vector3(0.08, 0.22, 0.34), lamp)


func _build_snowfall() -> void:
	var flakes := CPUParticles3D.new()
	flakes.name = "Snowfall"
	flakes.amount = 320
	flakes.lifetime = 9.0
	flakes.preprocess = 4.0
	flakes.emitting = true
	flakes.position = Vector3(0.0, 12.0, -8.0)
	flakes.emission_shape = CPUParticles3D.EMISSION_SHAPE_BOX
	flakes.emission_box_extents = Vector3(26.0, 8.0, 36.0)
	flakes.direction = Vector3(-0.08, -1.0, -0.04)
	flakes.spread = 12.0
	flakes.gravity = Vector3(0.12, -0.8, 0.04)
	flakes.initial_velocity_min = 0.35
	flakes.initial_velocity_max = 1.0
	flakes.scale_amount_min = 0.035
	flakes.scale_amount_max = 0.09
	flakes.mesh = QuadMesh.new()
	flakes.visibility_aabb = AABB(Vector3(-30.0, -16.0, -44.0), Vector3(60.0, 34.0, 72.0))
	var flake_material := StandardMaterial3D.new()
	flake_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	flake_material.albedo_color = Color(0.82, 0.9, 1.0, 0.78)
	flake_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	flake_material.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	flakes.material_override = flake_material
	add_child(flakes)


func _build_player() -> void:
	player = CharacterBody3D.new()
	player.name = "Player"
	player.set_script(load("res://player.gd"))
	player.position = Vector3(0.0, 0.0, 14.0)
	add_child(player)

	var capsule := CollisionShape3D.new()
	var shape := CapsuleShape3D.new()
	shape.radius = 0.34
	shape.height = 1.8
	capsule.shape = shape
	capsule.position.y = 0.9
	player.add_child(capsule)

	var camera := Camera3D.new()
	camera.position = Vector3(0.0, 1.62, 0.0)
	camera.fov = 78.0
	camera.current = true
	player.add_child(camera)
	player.set("camera", camera)


func _build_hud() -> void:
	var layer := CanvasLayer.new()
	layer.layer = 5
	add_child(layer)
	var label := Label.new()
	label.position = Vector2(24.0, 20.0)
	label.text = "ДВОР\n23:47   •   −12°C"
	label.add_theme_font_size_override("font_size", 19)
	label.add_theme_color_override("font_color", Color(0.82, 0.88, 0.96, 0.84))
	label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.75))
	label.add_theme_constant_override("shadow_offset_x", 1)
	label.add_theme_constant_override("shadow_offset_y", 2)
	layer.add_child(label)

	var crosshair := Label.new()
	crosshair.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	crosshair.position = Vector2(-5.0, -12.0)
	crosshair.text = "·"
	crosshair.add_theme_font_size_override("font_size", 28)
	crosshair.add_theme_color_override("font_color", Color(0.88, 0.93, 1.0, 0.65))
	layer.add_child(crosshair)

	var hint := Label.new()
	hint.position = Vector2(24.0, 92.0)
	var mobile_mode := OS.has_feature("android") or OS.has_feature("ios")
	hint.text = "Стик слева — идти   •   свайп справа — смотреть" if mobile_mode else "Нажми ЛКМ, затем WASD + мышь"
	hint.add_theme_font_size_override("font_size", 13)
	hint.add_theme_color_override("font_color", Color(0.70, 0.78, 0.88, 0.58))
	layer.add_child(hint)

	var controls := Control.new()
	controls.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	controls.set_script(load("res://mobile_controls.gd"))
	layer.add_child(controls)
	controls.connect("movement_changed", Callable(player, "set_mobile_move"))
	controls.connect("look_delta", Callable(player, "add_mobile_look"))


func _box(parent: Node3D, position: Vector3, size: Vector3, material: Material, with_collision: bool = false) -> Node3D:
	var holder: Node3D = StaticBody3D.new() if with_collision else Node3D.new()
	holder.position = position
	parent.add_child(holder)
	var mesh_instance := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = size
	mesh_instance.mesh = mesh
	mesh_instance.material_override = material
	holder.add_child(mesh_instance)
	if with_collision:
		var collision := CollisionShape3D.new()
		var collision_shape := BoxShape3D.new()
		collision_shape.size = size
		collision.shape = collision_shape
		holder.add_child(collision)
	return holder


func _sphere(parent: Node3D, position: Vector3, scale_value: Vector3, material: Material) -> MeshInstance3D:
	var instance := MeshInstance3D.new()
	var mesh := SphereMesh.new()
	mesh.radius = 1.0
	mesh.height = 2.0
	instance.mesh = mesh
	instance.position = position
	instance.scale = scale_value
	instance.material_override = material
	parent.add_child(instance)
	return instance


func _cylinder(parent: Node3D, position: Vector3, radius: float, height: float, material: Material) -> MeshInstance3D:
	var instance := MeshInstance3D.new()
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = height
	mesh.radial_segments = 12
	instance.mesh = mesh
	instance.position = position
	instance.material_override = material
	parent.add_child(instance)
	return instance


func _rod(parent: Node3D, start: Vector3, finish: Vector3, radius: float, material: Material) -> MeshInstance3D:
	var difference := finish - start
	var instance := MeshInstance3D.new()
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = difference.length()
	mesh.radial_segments = 10
	instance.mesh = mesh
	instance.transform = Transform3D(Basis(Quaternion(Vector3.UP, difference.normalized())), (start + finish) * 0.5)
	instance.material_override = material
	parent.add_child(instance)
	return instance
