extends RefCounted

func build(root: Node3D) -> void:
	var car := Node3D.new()
	car.name = "SnowCoveredSedan"
	car.position = Vector3(10.8, 0.0, 8.8)
	car.rotation.y = -0.32
	root.add_child(car)

	var paint := _car_paint(Color(0.10, 0.16, 0.23))
	var glass := _material(Color(0.018, 0.038, 0.062), 0.15, 0.34)
	var tire := _material(Color(0.018, 0.022, 0.028), 0.96)
	var rubber_trim := _material(Color(0.045, 0.055, 0.067), 0.82)
	var chrome := _material(Color(0.42, 0.48, 0.54), 0.27, 0.72)
	var rim_dark := _material(Color(0.16, 0.20, 0.25), 0.35, 0.72)
	var headlamp := _material(Color(0.98, 0.79, 0.52), 0.18, 0.9)
	headlamp.emission_enabled = true
	headlamp.emission = Color(1.0, 0.56, 0.25)
	headlamp.emission_energy_multiplier = 1.4
	var tail_lamp := _material(Color(0.54, 0.07, 0.055), 0.22, 0.15)
	tail_lamp.emission_enabled = true
	tail_lamp.emission = Color(0.85, 0.035, 0.02)
	tail_lamp.emission_energy_multiplier = 0.55
	var snow := _material(Color(0.72, 0.79, 0.88), 0.96)

	_build_body(car, paint)
	_build_windows(car, glass)
	_build_wheels(car, tire, rim_dark, chrome)
	_build_trim(car, rubber_trim, chrome, headlamp, tail_lamp)
	_build_snow(car, snow)


func _build_body(parent: Node3D, material: Material) -> void:
	var profile: Array[Vector2] = [
		Vector2(-2.05, 0.57),
		Vector2(-2.02, 0.98),
		Vector2(-1.47, 1.12),
		Vector2(-1.06, 1.70),
		Vector2(-0.72, 1.90),
		Vector2(0.67, 1.88),
		Vector2(1.18, 1.20),
		Vector2(1.90, 1.08),
		Vector2(2.06, 0.60)
	]
	var widths: Array[float] = [0.88, 0.99, 0.96, 0.74, 0.71, 0.71, 0.92, 0.99, 0.88]
	var tool := SurfaceTool.new()
	tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	var center := Vector2.ZERO
	for point in profile:
		center += point
	center /= float(profile.size())

	# Side skins, plus the curved perimeter joining both sides of the shell.
	for side in [-1.0, 1.0]:
		var side_center := Vector3(center.x, center.y, side * 0.82)
		for index in range(profile.size()):
			var next_index := (index + 1) % profile.size()
			var p0 := Vector3(profile[index].x, profile[index].y, side * widths[index])
			var p1 := Vector3(profile[next_index].x, profile[next_index].y, side * widths[next_index])
			_add_triangle(tool, side_center, p0, p1)
	for index in range(profile.size()):
		var next_index := (index + 1) % profile.size()
		var front_a := Vector3(profile[index].x, profile[index].y, widths[index])
		var front_b := Vector3(profile[next_index].x, profile[next_index].y, widths[next_index])
		var rear_a := Vector3(profile[index].x, profile[index].y, -widths[index])
		var rear_b := Vector3(profile[next_index].x, profile[next_index].y, -widths[next_index])
		_add_quad(tool, front_a, rear_a, rear_b, front_b)
	tool.generate_normals()
	var body_mesh := MeshInstance3D.new()
	body_mesh.name = "SculptedBody"
	body_mesh.mesh = tool.commit()
	body_mesh.material_override = material
	body_mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	parent.add_child(body_mesh)

	# Dark rocker panels visually separate the body from the snowy road.
	for side in [-1.0, 1.0]:
		_box(parent, Vector3(0.0, 0.61, side * 0.91), Vector3(2.65, 0.19, 0.09), _material(Color(0.07, 0.09, 0.12), 0.76))


func _build_windows(parent: Node3D, material: Material) -> void:
	var tool := SurfaceTool.new()
	tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	for side in [-1.0, 1.0]:
		var z: float = float(side) * 0.755
		# Rear side window.
		_add_quad(tool,
			Vector3(-1.28, 1.23, z), Vector3(-0.98, 1.68, z * 0.96),
			Vector3(-0.35, 1.76, z * 0.96), Vector3(-0.28, 1.24, z))
		# Front side window.
		_add_quad(tool,
			Vector3(-0.16, 1.24, z), Vector3(-0.12, 1.76, z * 0.96),
			Vector3(0.63, 1.74, z * 0.96), Vector3(1.02, 1.22, z))
		# Narrow centre pillar.
		_box(parent, Vector3(-0.23, 1.49, z * 1.01), Vector3(0.075, 0.51, 0.045), _material(Color(0.075, 0.09, 0.11), 0.35))
	# Front windscreen and rear glass are separate slanted surfaces.
	_add_quad(tool,
		Vector3(1.19, 1.19, -0.76), Vector3(1.19, 1.19, 0.76),
		Vector3(0.70, 1.79, 0.70), Vector3(0.70, 1.79, -0.70))
	_add_quad(tool,
		Vector3(-1.48, 1.14, 0.76), Vector3(-1.48, 1.14, -0.76),
		Vector3(-1.02, 1.74, -0.70), Vector3(-1.02, 1.74, 0.70))
	tool.generate_normals()
	var windows := MeshInstance3D.new()
	windows.name = "Glazing"
	windows.mesh = tool.commit()
	windows.material_override = material
	windows.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	parent.add_child(windows)


func _build_wheels(parent: Node3D, tire: Material, rim: Material, chrome: Material) -> void:
	var tread_transforms: Array[Transform3D] = []
	for x in [-1.34, 1.34]:
		for side in [-1.0, 1.0]:
			var wheel := _cylinder(parent, Vector3(x, 0.47, side * 0.91), 0.43, 0.25, tire, 28)
			wheel.rotation.x = PI * 0.5
			var rim_disc := _cylinder(parent, Vector3(x, 0.47, side * 1.045), 0.285, 0.045, rim, 28)
			rim_disc.rotation.x = PI * 0.5
			var hub := _cylinder(parent, Vector3(x, 0.47, side * 1.073), 0.09, 0.055, chrome, 20)
			hub.rotation.x = PI * 0.5
			for spoke in range(8):
				var angle := float(spoke) * TAU / 8.0
				var spoke_start := Vector3(x + cos(angle) * 0.075, 0.47 + sin(angle) * 0.075, side * 1.078)
				var spoke_end := Vector3(x + cos(angle) * 0.235, 0.47 + sin(angle) * 0.235, side * 1.078)
				_rod(parent, spoke_start, spoke_end, 0.018, chrome)
			# Batch the chunky winter-tire tread blocks into a single draw call.
			for tread in range(16):
				var tread_angle := float(tread) * TAU / 16.0
				var tread_pos := Vector3(x + cos(tread_angle) * 0.426, 0.47 + sin(tread_angle) * 0.426, side * 0.91)
				var tread_basis := Basis(Vector3(0.0, 0.0, 1.0), tread_angle)
				tread_transforms.append(Transform3D(tread_basis, tread_pos))
	var tread_mesh := BoxMesh.new()
	tread_mesh.size = Vector3(0.12, 0.045, 0.265)
	var tread_multi := MultiMesh.new()
	tread_multi.transform_format = MultiMesh.TRANSFORM_3D
	tread_multi.mesh = tread_mesh
	tread_multi.instance_count = tread_transforms.size()
	for tread_index in range(tread_transforms.size()):
		tread_multi.set_instance_transform(tread_index, tread_transforms[tread_index])
	var tread_instance := MultiMeshInstance3D.new()
	tread_instance.multimesh = tread_multi
	tread_instance.material_override = tire
	parent.add_child(tread_instance)


func _build_trim(parent: Node3D, rubber: Material, chrome: Material, headlamp: Material, tail_lamp: Material) -> void:
	# Front and rear bumpers, radiator grille and lower air intake.
	_box(parent, Vector3(2.055, 0.66, 0.0), Vector3(0.13, 0.17, 1.76), chrome)
	_box(parent, Vector3(-2.045, 0.65, 0.0), Vector3(0.12, 0.16, 1.76), chrome)
	_box(parent, Vector3(2.105, 0.88, 0.0), Vector3(0.035, 0.28, 0.66), rubber)
	for z in [-0.34, -0.22, -0.10, 0.10, 0.22, 0.34]:
		_box(parent, Vector3(2.13, 0.89, z), Vector3(0.035, 0.17, 0.035), chrome)
	for side in [-1.0, 1.0]:
		var lamp := _sphere(parent, Vector3(2.015, 0.97, side * 0.62), Vector3(0.075, 0.16, 0.22), headlamp)
		lamp.rotation.z = -0.12
		_box(parent, Vector3(-2.045, 0.91, side * 0.65), Vector3(0.06, 0.22, 0.30), tail_lamp)
		_box(parent, Vector3(0.0, 0.78, side * 0.985), Vector3(0.13, 0.055, 2.05), chrome)
		# Door seams and handles.
		_rod(parent, Vector3(-0.95, 0.72, side * 0.987), Vector3(0.78, 0.72, side * 0.987), 0.012, rubber)
		_box(parent, Vector3(-0.30, 1.03, side * 0.985), Vector3(0.20, 0.045, 0.045), chrome)
		# Mirrors on short black stalks.
		_rod(parent, Vector3(0.82, 1.29, side * 0.80), Vector3(0.93, 1.37, side * 1.07), 0.028, rubber)
		var mirror := _sphere(parent, Vector3(0.98, 1.39, side * 1.09), Vector3(0.19, 0.11, 0.12), chrome)
		mirror.rotation.y = side * 0.12
	# Wipers at the foot of the front windscreen.
	for side in [-1.0, 1.0]:
		_rod(parent, Vector3(1.23, 1.22, side * 0.52), Vector3(1.02, 1.29, side * 0.13), 0.012, rubber)


func _build_snow(parent: Node3D, material: Material) -> void:
	# Soft drifts rather than a single sharp rectangular snow slab.
	_box(parent, Vector3(-0.08, 1.92, 0.0), Vector3(1.45, 0.045, 1.24), material)
	_sphere(parent, Vector3(0.18, 1.94, -0.28), Vector3(0.78, 0.055, 0.52), material)
	_sphere(parent, Vector3(-0.42, 1.94, 0.22), Vector3(0.66, 0.05, 0.46), material)
	_box(parent, Vector3(1.67, 1.12, 0.0), Vector3(0.55, 0.06, 1.36), material)


func _add_triangle(tool: SurfaceTool, a: Vector3, b: Vector3, c: Vector3) -> void:
	tool.set_uv(Vector2(a.x * 0.25, a.y * 0.5))
	tool.add_vertex(a)
	tool.set_uv(Vector2(b.x * 0.25, b.y * 0.5))
	tool.add_vertex(b)
	tool.set_uv(Vector2(c.x * 0.25, c.y * 0.5))
	tool.add_vertex(c)


func _add_quad(tool: SurfaceTool, a: Vector3, b: Vector3, c: Vector3, d: Vector3) -> void:
	_add_triangle(tool, a, b, c)
	_add_triangle(tool, a, c, d)


func _box(parent: Node3D, position: Vector3, size: Vector3, material: Material) -> MeshInstance3D:
	var instance := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = size
	instance.mesh = mesh
	instance.position = position
	instance.material_override = material
	parent.add_child(instance)
	return instance


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


func _cylinder(parent: Node3D, position: Vector3, radius: float, height: float, material: Material, segments: int = 16) -> MeshInstance3D:
	var instance := MeshInstance3D.new()
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = height
	mesh.radial_segments = segments
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


func _material(color: Color, roughness: float = 0.92, metallic: float = 0.0) -> StandardMaterial3D:
	var result := StandardMaterial3D.new()
	result.albedo_color = color
	result.roughness = roughness
	result.metallic = metallic
	return result


func _car_paint(color: Color) -> StandardMaterial3D:
	var result := _material(color, 0.32, 0.58)
	result.clearcoat_enabled = true
	result.clearcoat = 0.64
	result.clearcoat_roughness = 0.18
	result.cull_mode = BaseMaterial3D.CULL_DISABLED
	return result
