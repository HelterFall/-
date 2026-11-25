extends RefCounted

func build(root: Node3D) -> void:
	_build_entrance(root, Vector3(-20.0, 0.0, -10.0), PI * 0.5, "14", 34.0, 8)
	_build_entrance(root, Vector3(20.0, 0.0, -10.0), -PI * 0.5, "16", 34.0, 8)
	_build_entrance(root, Vector3(0.0, 0.0, -34.0), 0.0, "12", 48.0, 9)
	_build_air_conditioners(root, Vector3(-20.0, 0.0, -10.0), PI * 0.5, 34.0, 8)
	_build_air_conditioners(root, Vector3(20.0, 0.0, -10.0), -PI * 0.5, 34.0, 8)
	_build_air_conditioners(root, Vector3(0.0, 0.0, -34.0), 0.0, 48.0, 9)
	_build_playground_fence(root)
	_build_trash_container(root, Vector3(-14.8, 0.0, 3.5), 0.10)
	_build_trash_container(root, Vector3(15.0, 0.0, -20.0), -0.18)
	_build_trash_container(root, Vector3(-13.7, 0.0, -20.0), 0.08)
	_build_street_details(root)


func _build_entrance(root: Node3D, origin: Vector3, yaw: float, building_number: String, width: float, floors: int) -> void:
	var entrance := Node3D.new()
	entrance.position = origin
	entrance.rotation.y = yaw
	root.add_child(entrance)

	var concrete := _material(Color(0.45, 0.48, 0.52), 0.93)
	var dark_metal := _weathered_metal(Color(0.13, 0.17, 0.22), 0.76, 0.32, 0.42)
	var door_paint := _material(Color(0.19, 0.24, 0.30), 0.56)
	var glass := _material(Color(0.11, 0.17, 0.23), 0.25)
	var steel := _weathered_metal(Color(0.42, 0.47, 0.52), 0.82, 0.12, 0.22)
	var snow := _material(Color(0.67, 0.74, 0.83), 0.94)
	var warm := _material(Color(1.0, 0.76, 0.50), 0.18, Color(1.0, 0.45, 0.13))
	warm.emission_energy_multiplier = 2.4

	# Heavy concrete portal and old metal entry door.
	_box(entrance, Vector3(0.0, 1.30, 3.035), Vector3(1.62, 2.62, 0.24), concrete)
	_box(entrance, Vector3(0.0, 1.28, 3.19), Vector3(1.30, 2.34, 0.12), door_paint)
	_box(entrance, Vector3(0.0, 1.69, 3.265), Vector3(0.60, 0.80, 0.035), glass)
	_box(entrance, Vector3(0.0, 1.69, 3.29), Vector3(0.045, 0.84, 0.035), dark_metal)
	_box(entrance, Vector3(-0.30, 1.69, 3.29), Vector3(0.035, 0.84, 0.035), dark_metal)
	_box(entrance, Vector3(0.30, 1.69, 3.29), Vector3(0.035, 0.84, 0.035), dark_metal)
	_box(entrance, Vector3(0.49, 1.16, 3.30), Vector3(0.045, 0.34, 0.055), steel)

	# Intercom, illuminated call key and stacked metal post boxes.
	_box(entrance, Vector3(0.88, 1.47, 3.24), Vector3(0.25, 0.42, 0.14), dark_metal)
	_box(entrance, Vector3(0.88, 1.58, 3.325), Vector3(0.16, 0.08, 0.035), warm)
	_box(entrance, Vector3(-1.02, 1.38, 3.20), Vector3(0.37, 0.92, 0.20), dark_metal)
	for row in range(5):
		_box(entrance, Vector3(-1.02, 1.72 - float(row) * 0.16, 3.315), Vector3(0.29, 0.105, 0.035), steel)

	# Canopy with a wind-blown snow cap, bracing and concrete steps.
	_box(entrance, Vector3(0.0, 2.69, 3.43), Vector3(2.80, 0.17, 1.26), concrete)
	_box(entrance, Vector3(0.0, 2.79, 3.96), Vector3(2.76, 0.05, 1.08), snow)
	for side in [-1.0, 1.0]:
		_rod(entrance, Vector3(side * 1.08, 2.61, 3.46), Vector3(side * 1.08, 2.02, 3.84), 0.045, dark_metal)
	_box(entrance, Vector3(0.0, 0.16, 3.72), Vector3(2.70, 0.22, 1.25), concrete)
	_box(entrance, Vector3(0.0, 0.075, 4.42), Vector3(2.42, 0.15, 0.62), concrete)
	_box(entrance, Vector3(0.0, 0.17, 4.42), Vector3(2.18, 0.045, 0.48), snow)

	# A simple enamel building number plaque above the intercom.
	var plaque := _box(entrance, Vector3(0.0, 2.99, 3.54), Vector3(0.58, 0.25, 0.06), dark_metal)
	var number := Label3D.new()
	number.text = building_number
	number.font_size = 64
	number.pixel_size = 0.004
	number.modulate = Color(0.96, 0.79, 0.54)
	number.outline_size = 5
	number.position = Vector3(0.0, 2.92, 3.585)
	number.rotation.y = PI
	entrance.add_child(number)

	_box(entrance, Vector3(0.0, 2.91, 3.54), Vector3(0.25, 0.07, 0.08), warm)
	var entry_light := OmniLight3D.new()
	entry_light.position = Vector3(0.0, 2.84, 3.78)
	entry_light.light_color = Color(1.0, 0.62, 0.34)
	entry_light.light_energy = 0.55
	entry_light.omni_range = 5.5
	entrance.add_child(entry_light)

	# Downpipes at facade edges make the long walls less featureless.
	var height := 2.55 * float(floors)
	for pipe_x in [-width * 0.5 + 0.55, width * 0.5 - 0.55]:
		_rod(entrance, Vector3(pipe_x, 0.25, 3.10), Vector3(pipe_x, height + 0.25, 3.10), 0.042, dark_metal)


func _build_air_conditioners(root: Node3D, origin: Vector3, yaw: float, width: float, floors: int) -> void:
	var facade := Node3D.new()
	facade.position = origin
	facade.rotation.y = yaw
	root.add_child(facade)
	var paint := _weathered_metal(Color(0.48, 0.52, 0.56), 0.38, 0.14, 0.32)
	var grille := _weathered_metal(Color(0.13, 0.17, 0.21), 0.72, 0.20, 0.44)
	var pipe := _material(Color(0.24, 0.29, 0.34), 0.72)
	var columns := int(width / 2.35)
	var bodies: Array[Transform3D] = []
	var vents: Array[Transform3D] = []
	for floor_index in range(floors):
		if floor_index < 2 or floor_index % 2 != 0:
			continue
		var y := 1.35 + float(floor_index) * 2.48
		for column in range(columns):
			if column % 5 != 2:
				continue
			var x := -width * 0.5 + 1.25 + float(column) * (width - 2.5) / maxf(1.0, float(columns - 1))
			bodies.append(Transform3D(Basis.IDENTITY, Vector3(x, y - 1.02, 3.42)))
			vents.append(Transform3D(Basis.IDENTITY, Vector3(x, y - 1.02, 3.70)))
			_rod(facade, Vector3(x + 0.37, y - 1.18, 3.42), Vector3(x + 0.58, y - 1.48, 3.08), 0.018, pipe)
	_multimesh_boxes(facade, Vector3(0.78, 0.34, 0.52), paint, bodies)
	_multimesh_boxes(facade, Vector3(0.56, 0.20, 0.045), grille, vents)


func _build_playground_fence(root: Node3D) -> void:
	var paint := _weathered_metal(Color(0.15, 0.20, 0.26), 0.74, 0.28, 0.48)
	var snow := _material(Color(0.63, 0.70, 0.79), 0.92)
	for x in [-8.0, 8.0]:
		for segment in range(6):
			var z := -10.4 - float(segment) * 1.42
			_rod(root, Vector3(x, 0.10, z), Vector3(x, 1.02, z), 0.052, paint)
		_rod(root, Vector3(x, 1.02, -10.4), Vector3(x, 1.02, -17.5), 0.052, paint)
		_rod(root, Vector3(x, 0.48, -10.4), Vector3(x, 0.48, -17.5), 0.034, paint)
	_rod(root, Vector3(-8.0, 1.02, -17.5), Vector3(8.0, 1.02, -17.5), 0.052, paint)
	_rod(root, Vector3(-8.0, 0.48, -17.5), Vector3(8.0, 0.48, -17.5), 0.034, paint)
	for x in range(-7, 8):
		_rod(root, Vector3(float(x), 0.10, -17.5), Vector3(float(x), 1.02, -17.5), 0.040, paint)
	_box(root, Vector3(0.0, 1.08, -17.5), Vector3(16.2, 0.075, 0.13), snow)


func _build_trash_container(root: Node3D, origin: Vector3, yaw: float) -> void:
	var container := Node3D.new()
	container.position = origin
	container.rotation.y = yaw
	root.add_child(container)
	var body := _weathered_metal(Color(0.19, 0.24, 0.30), 0.64, 0.28, 0.34)
	var rim := _weathered_metal(Color(0.35, 0.40, 0.45), 0.82, 0.22, 0.26)
	var dark := _material(Color(0.07, 0.09, 0.12), 0.94)
	var snow := _material(Color(0.66, 0.73, 0.82), 0.94)
	_box(container, Vector3(0.0, 0.68, 0.0), Vector3(1.25, 1.28, 0.88), body)
	_box(container, Vector3(0.0, 1.35, 0.0), Vector3(1.34, 0.13, 0.96), rim)
	_box(container, Vector3(0.0, 1.44, 0.0), Vector3(1.38, 0.08, 1.0), snow)
	_box(container, Vector3(0.0, 1.39, 0.49), Vector3(0.86, 0.16, 0.035), dark)
	_box(container, Vector3(0.0, 0.78, 0.46), Vector3(1.08, 0.34, 0.045), dark)
	for wheel_x in [-0.45, 0.45]:
		var wheel := _cylinder(container, Vector3(wheel_x, 0.12, -0.28), 0.13, 0.10, dark)
		wheel.rotation.x = PI * 0.5
	for side in [-1.0, 1.0]:
		_rod(container, Vector3(side * 0.62, 1.20, -0.34), Vector3(side * 0.62, 1.48, -0.34), 0.035, rim)


func _build_street_details(root: Node3D) -> void:
	var bollard := _weathered_metal(Color(0.14, 0.18, 0.23), 0.62, 0.34, 0.42)
	var snow := _material(Color(0.67, 0.74, 0.83), 0.94)
	var curb := _material(Color(0.34, 0.38, 0.44), 0.92)
	var ice := _wet_surface(Color(0.28, 0.39, 0.52), Color(0.14, 0.21, 0.32), 0.92)
	var slush := _wet_surface(Color(0.17, 0.22, 0.29), Color(0.10, 0.14, 0.19), 0.42)
	var track := _material(Color(0.15, 0.20, 0.27), 0.84)
	for x in [-5.4, 5.4]:
		for z in [3.6, 7.0, 10.4]:
			_cylinder(root, Vector3(x, 0.42, z), 0.12, 0.84, bollard)
			_cylinder(root, Vector3(x, 0.67, z), 0.125, 0.16, snow)
	for x in [-3.8, 3.8]:
		_box(root, Vector3(x, 0.09, -1.6), Vector3(0.24, 0.18, 27.0), curb)
		_box(root, Vector3(x, 0.19, -1.6), Vector3(0.28, 0.035, 27.0), snow)
	for puddle_pos in [
		Vector3(-2.2, 0.038, 7.0), Vector3(2.7, 0.039, 2.0),
		Vector3(-3.0, 0.038, -6.0), Vector3(1.9, 0.039, -13.0),
		Vector3(12.5, 0.038, 10.5)
	]:
		var puddle := _sphere(root, puddle_pos, Vector3(0.62, 0.012, 0.30), ice)
		puddle.rotation.y = randf_range(-0.5, 0.5)
	for dirty_pos in [Vector3(-3.4, 0.036, 5.0), Vector3(3.3, 0.036, -9.0), Vector3(11.0, 0.036, 12.0)]:
		var dirty_patch := _sphere(root, dirty_pos, Vector3(0.74, 0.012, 0.38), slush)
		dirty_patch.rotation.y = randf_range(-0.45, 0.45)
	_cylinder(root, Vector3(5.0, 0.045, 4.5), 0.42, 0.055, bollard)
	for slot_index in range(6):
		var angle := float(slot_index) * TAU / 6.0
		var slot := _box(root, Vector3(5.0 + cos(angle) * 0.22, 0.076, 4.5 + sin(angle) * 0.22), Vector3(0.22, 0.012, 0.035), curb)
		slot.rotation.y = angle
	for x in [10.0, 11.25]:
		for segment in range(5):
			_box(root, Vector3(x, 0.037, 14.2 - float(segment) * 0.82), Vector3(0.12, 0.018, 0.62), track)
	var cabinet_material := _material(Color(0.20, 0.25, 0.31), 0.78)
	for cabinet_pos in [Vector3(-16.9, 0.78, -2.5), Vector3(16.9, 0.78, -16.0)]:
		_box(root, cabinet_pos, Vector3(0.72, 1.48, 0.42), cabinet_material)
		_box(root, cabinet_pos + Vector3(0.0, 0.0, 0.23), Vector3(0.56, 1.27, 0.035), bollard)
		_box(root, cabinet_pos + Vector3(0.0, 0.25, 0.27), Vector3(0.46, 0.035, 0.035), snow)


func _multimesh_boxes(parent: Node3D, box_size: Vector3, material: Material, transforms: Array[Transform3D]) -> void:
	if transforms.is_empty():
		return
	var box_mesh := BoxMesh.new()
	box_mesh.size = box_size
	var multi := MultiMesh.new()
	multi.transform_format = MultiMesh.TRANSFORM_3D
	multi.mesh = box_mesh
	multi.instance_count = transforms.size()
	for index in range(transforms.size()):
		multi.set_instance_transform(index, transforms[index])
	var instance := MultiMeshInstance3D.new()
	instance.multimesh = multi
	instance.material_override = material
	parent.add_child(instance)


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


func _wet_surface(base: Color, fleck: Color, wetness: float) -> ShaderMaterial:
	var result := ShaderMaterial.new()
	result.shader = load("res://materials/wet_ice_slush.gdshader")
	result.set_shader_parameter("base_color", base)
	result.set_shader_parameter("fleck_color", fleck)
	result.set_shader_parameter("wetness", wetness)
	result.set_shader_parameter("grain_scale", 54.0)
	return result


func _weathered_metal(color: Color, metalness: float, rust_strength: float, wear_strength: float) -> ShaderMaterial:
	var result := ShaderMaterial.new()
	result.shader = load("res://materials/weathered_metal.gdshader")
	result.set_shader_parameter("base_color", color)
	result.set_shader_parameter("metalness", metalness)
	result.set_shader_parameter("rust_strength", rust_strength)
	result.set_shader_parameter("wear_strength", wear_strength)
	return result


func _material(color: Color, roughness: float = 0.92, emission: Color = Color.BLACK) -> StandardMaterial3D:
	var result := StandardMaterial3D.new()
	result.albedo_color = color
	result.roughness = roughness
	if emission != Color.BLACK:
		result.emission_enabled = true
		result.emission = emission
		result.emission_energy_multiplier = 1.25
	return result
