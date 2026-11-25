extends RefCounted

func build(root: Node3D) -> void:
	_build_sandbox(root)
	_build_seesaw(root)
	_build_climbing_frame(root)
	_build_snow_accents(root)


func _build_sandbox(root: Node3D) -> void:
	var pit := Node3D.new()
	pit.position = Vector3(-2.7, 0.0, -14.25)
	root.add_child(pit)
	var weathered_wood := _material(Color(0.28, 0.23, 0.20), 0.92)
	var faded_blue := _material(Color(0.16, 0.27, 0.36), 0.70)
	var snow := _material(Color(0.66, 0.73, 0.82), 0.96)
	var sand := _material(Color(0.27, 0.30, 0.34), 0.97)
	_box(pit, Vector3(0.0, 0.14, 0.0), Vector3(4.9, 0.18, 2.8), sand)
	_box(pit, Vector3(0.0, 0.27, -1.35), Vector3(5.2, 0.40, 0.18), weathered_wood)
	_box(pit, Vector3(0.0, 0.27, 1.35), Vector3(5.2, 0.40, 0.18), weathered_wood)
	_box(pit, Vector3(-2.50, 0.27, 0.0), Vector3(0.18, 0.40, 2.8), weathered_wood)
	_box(pit, Vector3(2.50, 0.27, 0.0), Vector3(0.18, 0.40, 2.8), weathered_wood)
	_box(pit, Vector3(0.0, 0.49, -1.35), Vector3(5.1, 0.07, 0.16), snow)
	_box(pit, Vector3(0.0, 0.49, 1.35), Vector3(5.1, 0.07, 0.16), snow)
	_box(pit, Vector3(-2.50, 0.49, 0.0), Vector3(0.16, 0.07, 2.65), snow)
	_box(pit, Vector3(2.50, 0.49, 0.0), Vector3(0.16, 0.07, 2.65), snow)
	for post_x in [-2.42, 2.42]:
		for post_z in [-1.25, 1.25]:
			_box(pit, Vector3(post_x, 0.49, post_z), Vector3(0.20, 0.12, 0.20), faded_blue)
	# Snow has drifted into the middle of the old sandbox.
	_sphere(pit, Vector3(-0.7, 0.30, -0.28), Vector3(1.5, 0.16, 0.80), snow)
	_sphere(pit, Vector3(1.1, 0.29, 0.42), Vector3(1.0, 0.13, 0.65), snow)


func _build_seesaw(root: Node3D) -> void:
	var pivot := Node3D.new()
	pivot.position = Vector3(3.2, 0.0, -14.55)
	pivot.rotation.z = -0.10
	root.add_child(pivot)
	var metal := _material(Color(0.17, 0.22, 0.28), 0.68)
	var red := _material(Color(0.47, 0.18, 0.16), 0.64)
	var yellow := _material(Color(0.68, 0.49, 0.22), 0.70)
	var snow := _material(Color(0.65, 0.72, 0.81), 0.95)
	_rod(pivot, Vector3(0.0, 0.08, 0.0), Vector3(-0.68, 0.95, 0.0), 0.085, metal)
	_rod(pivot, Vector3(0.0, 0.08, 0.0), Vector3(0.68, 0.95, 0.0), 0.085, metal)
	_rod(pivot, Vector3(-0.68, 0.95, 0.0), Vector3(0.68, 0.95, 0.0), 0.075, metal)
	_box(pivot, Vector3(0.0, 1.04, 0.0), Vector3(3.8, 0.16, 0.26), red)
	_box(pivot, Vector3(0.0, 1.14, 0.0), Vector3(3.5, 0.055, 0.24), snow)
	for side in [-1.0, 1.0]:
		_box(pivot, Vector3(side * 1.58, 1.23, 0.0), Vector3(0.78, 0.13, 0.62), yellow)
		_rod(pivot, Vector3(side * 1.72, 1.22, 0.0), Vector3(side * 1.72, 1.72, 0.0), 0.045, metal)
		_rod(pivot, Vector3(side * 1.47, 1.22, 0.0), Vector3(side * 1.47, 1.72, 0.0), 0.045, metal)
		_rod(pivot, Vector3(side * 1.47, 1.72, 0.0), Vector3(side * 1.72, 1.72, 0.0), 0.045, metal)


func _build_climbing_frame(root: Node3D) -> void:
	var frame := Node3D.new()
	frame.position = Vector3(-6.7, 0.0, -12.7)
	root.add_child(frame)
	var metal := _material(Color(0.16, 0.22, 0.28), 0.65)
	var worn_red := _material(Color(0.44, 0.19, 0.17), 0.72)
	var snow := _material(Color(0.66, 0.73, 0.82), 0.95)
	for side in [-1.0, 1.0]:
		_rod(frame, Vector3(side * 1.15, 0.08, -0.8), Vector3(side * 0.62, 2.75, 0.0), 0.065, metal)
		_rod(frame, Vector3(side * 1.15, 0.08, 0.8), Vector3(side * 0.62, 2.75, 0.0), 0.065, metal)
		_rod(frame, Vector3(side * 0.62, 2.75, -0.8), Vector3(side * 0.62, 2.75, 0.8), 0.06, worn_red)
	for rung in range(6):
		var y := 0.52 + float(rung) * 0.40
		var x := -0.88 + float(rung) * 0.10
		_rod(frame, Vector3(-x, y, -0.64), Vector3(x, y, -0.64), 0.035, worn_red)
		_rod(frame, Vector3(-x, y, 0.64), Vector3(x, y, 0.64), 0.035, worn_red)
	_box(frame, Vector3(0.0, 2.82, 0.0), Vector3(1.45, 0.07, 1.72), snow)


func _build_snow_accents(root: Node3D) -> void:
	var snow := _material(Color(0.70, 0.77, 0.86), 0.96)
	# Narrow snow caps on the upper swing beam, slide platform and carousel hub.
	_box(root, Vector3(-3.05, 4.06, -7.0), Vector3(4.15, 0.055, 0.20), snow)
	_box(root, Vector3(3.3, 1.99, -8.2), Vector3(1.9, 0.05, 1.95), snow)
	_cylinder(root, Vector3(7.1, 1.30, -12.7), 0.46, 0.07, snow)


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


func _cylinder(parent: Node3D, position: Vector3, radius: float, height: float, material: Material) -> MeshInstance3D:
	var instance := MeshInstance3D.new()
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = height
	mesh.radial_segments = 16
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


func _material(color: Color, roughness: float = 0.92, emission: Color = Color.BLACK) -> StandardMaterial3D:
	var result := StandardMaterial3D.new()
	result.albedo_color = color
	result.roughness = roughness
	if emission != Color.BLACK:
		result.emission_enabled = true
		result.emission = emission
		result.emission_energy_multiplier = 1.25
	return result
