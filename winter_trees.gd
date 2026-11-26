extends RefCounted


func build(root: Node3D, positions: Array, random: RandomNumberGenerator) -> void:
	var trunk := _material(Color(0.63, 0.68, 0.73), 0.91)
	var trunk_light := _material(Color(0.79, 0.82, 0.86), 0.94)
	var bark_dark := _material(Color(0.105, 0.14, 0.19), 0.88)
	var bark_mid := _material(Color(0.28, 0.33, 0.39), 0.90)
	var branch := _material(Color(0.25, 0.30, 0.37), 0.92)
	var snow := _material(Color(0.72, 0.79, 0.88), 0.96)
	var root_snow := _material(Color(0.61, 0.69, 0.80), 0.98)

	for tree_index in range(positions.size()):
		var base: Vector3 = positions[tree_index]
		_build_birch(root, base, random, trunk, trunk_light, bark_dark, bark_mid, branch, snow, root_snow)


func _build_birch(
	root: Node3D,
	base: Vector3,
	random: RandomNumberGenerator,
	trunk: Material,
	trunk_light: Material,
	bark_dark: Material,
	bark_mid: Material,
	branch: Material,
	snow: Material,
	root_snow: Material
) -> void:
	var height: float = random.randf_range(5.0, 6.4)
	var lean := Vector3(random.randf_range(-0.20, 0.20), 0.0, random.randf_range(-0.16, 0.16))
	var top := base + lean + Vector3(0.0, height, 0.0)

	_tapered_rod(root, base + Vector3(0.0, 0.02, 0.0), top, 0.245, 0.065, trunk)
	_tapered_rod(root, top, top + Vector3(0.0, 0.55, 0.0), 0.066, 0.018, branch)

	# Корневые наплывы и снег у основания ствола.
	for root_index in range(4):
		var angle: float = float(root_index) * TAU / 4.0 + random.randf_range(-0.25, 0.25)
		var direction := Vector3(cos(angle), 0.0, sin(angle))
		_tapered_rod(
			root,
			base + Vector3(0.0, 0.10, 0.0),
			base + direction * random.randf_range(0.30, 0.48) + Vector3(0.0, 0.035, 0.0),
			0.105,
			0.026,
			trunk
		)
	_sphere(root, base + Vector3(0.0, 0.075, 0.0), Vector3(0.39, 0.12, 0.39), root_snow)

	# Белая берёзовая кора с неровными тёмными горизонтальными отметинами.
	for mark_index in range(17):
		var ratio: float = random.randf_range(0.12, 0.91)
		var y: float = height * ratio
		var angle: float = random.randf_range(0.0, TAU)
		var radius: float = lerpf(0.218, 0.072, ratio) + 0.012
		var normal := Vector3(cos(angle), 0.0, sin(angle))
		var center: Vector3 = base + lean * ratio + Vector3(0.0, y, 0.0) + normal * radius
		var mark := _box(
			root,
			center,
			Vector3(random.randf_range(0.055, 0.19), random.randf_range(0.018, 0.043), 0.012),
			bark_dark if mark_index % 3 != 0 else bark_mid
		)
		mark.rotation.y = angle + random.randf_range(-0.18, 0.18)

	# Несколько длинных светлых участков коры дают стволу объём в боковом свете.
	for strip_index in range(5):
		var ratio: float = random.randf_range(0.20, 0.78)
		var y: float = height * ratio
		var angle: float = float(strip_index) * TAU / 5.0 + random.randf_range(-0.2, 0.2)
		var radius: float = lerpf(0.222, 0.075, ratio) + 0.008
		var normal := Vector3(cos(angle), 0.0, sin(angle))
		var strip := _box(
			root,
			base + lean * ratio + Vector3(0.0, y, 0.0) + normal * radius,
			Vector3(0.018, random.randf_range(0.24, 0.62), 0.01),
			trunk_light
		)
		strip.rotation.y = angle

	# Ветви идут вокруг ствола на разных высотах, а не лежат в одной плоскости.
	for branch_index in range(11):
		var ratio: float = float(branch_index) / 10.0
		var y: float = clampf(height * lerpf(0.30, 0.86, ratio) + random.randf_range(-0.18, 0.18), 1.5, height - 0.45)
		var trunk_ratio: float = y / height
		var start: Vector3 = base + lean * trunk_ratio + Vector3(0.0, y, 0.0)
		var angle: float = float(branch_index) * 2.399 + random.randf_range(-0.26, 0.26)
		var direction := Vector3(cos(angle), 0.0, sin(angle))
		var length: float = lerpf(2.20, 0.82, ratio) + random.randf_range(-0.24, 0.28)
		var finish: Vector3 = start + direction * length + Vector3(0.0, random.randf_range(0.42, 0.92), 0.0)

		_tapered_rod(root, start, finish, 0.078, 0.016, branch)
		_tapered_rod(
			root,
			start + Vector3(0.0, 0.065, 0.0),
			finish + Vector3(0.0, 0.065, 0.0),
			0.043,
			0.008,
			snow
		)

		# Развилки и тонкие кончики создают узнаваемый силуэт голых зимних ветвей.
		if branch_index % 2 == 0:
			var split: Vector3 = start.lerp(finish, 0.56)
			var twig_direction: Vector3 = direction.rotated(Vector3.UP, random.randf_range(-0.75, 0.75))
			var twig_finish: Vector3 = split + twig_direction * length * 0.43 + Vector3(0.0, 0.48, 0.0)
			_tapered_rod(root, split, twig_finish, 0.036, 0.007, branch)
			_tapered_rod(
				root,
				split + Vector3(0.0, 0.035, 0.0),
				twig_finish + Vector3(0.0, 0.035, 0.0),
				0.021,
				0.004,
				snow
			)

			var tip_start: Vector3 = finish - direction * 0.22
			var tip_finish: Vector3 = finish + direction * 0.34 + Vector3(0.0, 0.16, 0.0)
			_tapered_rod(root, tip_start, tip_finish, 0.018, 0.003, branch)


func _tapered_rod(
	parent: Node3D,
	start: Vector3,
	finish: Vector3,
	bottom_radius: float,
	top_radius: float,
	material: Material
) -> MeshInstance3D:
	var difference: Vector3 = finish - start
	var mesh := CylinderMesh.new()
	mesh.top_radius = top_radius
	mesh.bottom_radius = bottom_radius
	mesh.height = difference.length()
	mesh.radial_segments = 9
	var instance := MeshInstance3D.new()
	instance.mesh = mesh
	instance.transform = Transform3D(
		Basis(Quaternion(Vector3.UP, difference.normalized())),
		(start + finish) * 0.5
	)
	instance.material_override = material
	parent.add_child(instance)
	return instance


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


func _material(color: Color, roughness: float = 0.92) -> StandardMaterial3D:
	var result := StandardMaterial3D.new()
	result.albedo_color = color
	result.roughness = roughness
	return result
