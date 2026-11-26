extends RefCounted

const STAIR_COUNT: int = 36
const STAIR_RISE: float = 0.235
const STAIR_DEPTH: float = 0.62
const STAIR_WIDTH: float = 5.8
const STAIR_START_Z: float = -38.0
const STAIR_WALL_CENTER_Z: float = -49.85
const STAIR_WALL_LENGTH: float = 25.7
const STAIR_WALL_HEIGHT: float = 8.9
const STAIR_WALL_CENTER_Y: float = -4.2

const ROOM_FLOOR_Y: float = -8.225
const ROOM_CEILING_Y: float = -0.42
const ROOM_HEIGHT: float = ROOM_CEILING_Y - ROOM_FLOOR_Y
const ROOM_WIDTH: float = 44.0
const ROOM_DEPTH: float = 34.0
const ROOM_CENTER_Z: float = -79.7
const ROOM_FRONT_Z: float = -62.7
const ROOM_BACK_Z: float = -96.7
const WALL_THICKNESS: float = 0.55


func build(root: Node3D) -> void:
	var tile_shader: Shader = load("res://materials/old_ceramic_tiles.gdshader") as Shader
	_build_stairwell(root, tile_shader)
	_build_chamber(root, tile_shader)
	_build_lighting(root)


func _build_stairwell(root: Node3D, tile_shader: Shader) -> void:
	var concrete := _material(Color(0.29, 0.31, 0.32), 0.94)
	var edge_concrete := _material(Color(0.39, 0.40, 0.38), 0.91)
	var step_count := STAIR_COUNT
	var side_size := Vector3(0.5, STAIR_WALL_HEIGHT, STAIR_WALL_LENGTH)

	# The two tiled sides form a deep rectangular shaft behind the rear apartment block.
	for side in [-1.0, 1.0]:
		var wall_center := Vector3(float(side) * 3.15, STAIR_WALL_CENTER_Y, STAIR_WALL_CENTER_Z)
		_solid_box(root, wall_center, side_size, concrete)
		var inner_x: float = float(side) * 2.90
		var yaw: float = PI * 0.5 if float(side) < 0.0 else -PI * 0.5
		var wall_basis := Basis(Vector3.UP, yaw) * Basis(Vector3.RIGHT, PI * 0.5)
		var wall_material := _tile_material(tile_shader, 22.0, 8.0, 0.58, 0.62)
		_tile_plane(
			root,
			Vector3(inner_x, STAIR_WALL_CENTER_Y, STAIR_WALL_CENTER_Z),
			wall_basis,
			Vector2(STAIR_WALL_LENGTH, STAIR_WALL_HEIGHT),
			wall_material
		)
		_solid_box(
			root,
			Vector3(float(side) * 3.15, 0.18, -37.55),
			Vector3(0.5, 0.42, 1.0),
			edge_concrete
		)

	# A hidden smooth collision ramp keeps the staircase traversable for the simple mobile controller.
	var ramp_top_z: float = STAIR_START_Z + STAIR_DEPTH * 0.5
	var ramp_bottom_z: float = STAIR_START_Z - float(STAIR_COUNT - 1) * STAIR_DEPTH - STAIR_DEPTH * 0.5
	var ramp_length: float = ramp_top_z - ramp_bottom_z
	var ramp_angle: float = -atan2(absf(ROOM_FLOOR_Y), ramp_length)
	var ramp_center_z: float = (ramp_top_z + ramp_bottom_z) * 0.5
	var ramp_center_y: float = ROOM_FLOOR_Y * 0.5 - 0.07 * cos(ramp_angle)
	var ramp_body := StaticBody3D.new()
	ramp_body.position = Vector3(0.0, ramp_center_y, ramp_center_z)
	ramp_body.rotation.x = ramp_angle
	var ramp_collision := CollisionShape3D.new()
	var ramp_shape := BoxShape3D.new()
	ramp_shape.size = Vector3(STAIR_WIDTH - 0.12, 0.14, ramp_length)
	ramp_collision.shape = ramp_shape
	ramp_body.add_child(ramp_collision)
	root.add_child(ramp_body)

	var tread_material := _tile_material(tile_shader, 5.0, 1.0, 0.52, 0.48)
	var riser_material := _tile_material(tile_shader, 5.0, 1.0, 0.60, 0.66)
	var step_block := _material(Color(0.30, 0.32, 0.33), 0.95)
	for step_index in range(step_count):
		var level_y: float = -float(step_index) * STAIR_RISE
		var z: float = STAIR_START_Z - float(step_index) * STAIR_DEPTH
		_visual_box(
			root,
			Vector3(0.0, level_y - 0.18, z),
			Vector3(STAIR_WIDTH, 0.36, STAIR_DEPTH),
			step_block
		)
		_tile_plane(
			root,
			Vector3(0.0, level_y + 0.006, z),
			Basis.IDENTITY,
			Vector2(STAIR_WIDTH - 0.06, STAIR_DEPTH - 0.04),
			tread_material
		)
		if step_index > 0:
			var riser_z: float = z + STAIR_DEPTH * 0.5
			var riser_basis := Basis(Vector3.RIGHT, PI * 0.5)
			_tile_plane(
				root,
				Vector3(0.0, level_y + STAIR_RISE * 0.5, riser_z),
				riser_basis,
				Vector2(STAIR_WIDTH - 0.06, STAIR_RISE + 0.015),
				riser_material
			)
		if step_index > 1 and step_index % 7 == 0:
			var lamp_side: float = -1.0 if int(step_index / 7) % 2 == 0 else 1.0
			var sconce_material := _material(Color(0.64, 0.68, 0.68), 0.42)
			sconce_material.emission_enabled = true
			sconce_material.emission = Color(0.50, 0.67, 0.82)
			sconce_material.emission_energy_multiplier = 0.9
			var sconce := MeshInstance3D.new()
			var sconce_mesh := BoxMesh.new()
			sconce_mesh.size = Vector3(0.16, 0.38, 0.48)
			sconce.mesh = sconce_mesh
			sconce.position = Vector3(lamp_side * 2.76, level_y + 2.45, z)
			sconce.material_override = sconce_material
			root.add_child(sconce)
			var stair_light := OmniLight3D.new()
			stair_light.position = sconce.position + Vector3(-lamp_side * 0.22, -0.18, 0.0)
			stair_light.light_color = Color(0.58, 0.73, 0.88)
			stair_light.light_energy = 0.72
			stair_light.omni_range = 5.0
			root.add_child(stair_light)

	# A tiled bottom landing joins the last tread to the opening in the chamber wall.
	var landing_material := _tile_material(tile_shader, 5.0, 3.0, 0.54, 0.56)
	_solid_box(
		root,
		Vector3(0.0, ROOM_FLOOR_Y - 0.18, -61.35),
		Vector3(STAIR_WIDTH, 0.36, 2.7),
		step_block
	)
	_tile_plane(
		root,
		Vector3(0.0, ROOM_FLOOR_Y + 0.006, -61.35),
		Basis.IDENTITY,
		Vector2(STAIR_WIDTH - 0.06, 2.66),
		landing_material
	)

	# Worn concrete caps and a dim warning lamp mark the entrance at ground level.
	_solid_box(root, Vector3(0.0, 2.80, -37.10), Vector3(6.6, 0.42, 0.42), edge_concrete)
	_solid_box(root, Vector3(-3.15, 1.40, -37.60), Vector3(0.5, 2.8, 0.42), edge_concrete)
	_solid_box(root, Vector3(3.15, 1.40, -37.60), Vector3(0.5, 2.8, 0.42), edge_concrete)


func _build_chamber(root: Node3D, tile_shader: Shader) -> void:
	var backing := _material(Color(0.23, 0.25, 0.27), 0.96)
	var room_center_y: float = (ROOM_FLOOR_Y + ROOM_CEILING_Y) * 0.5
	var half_width: float = ROOM_WIDTH * 0.5
		var wall_center_x: float = half_width - WALL_THICKNESS * 0.5
	var wall_center_z: float = ROOM_CENTER_Z

	# A single large, walkable chamber with a continuous tiled floor and ceiling.
	_solid_box(
		root,
		Vector3(0.0, ROOM_FLOOR_Y - 0.30, ROOM_CENTER_Z),
		Vector3(ROOM_WIDTH, 0.60, ROOM_DEPTH),
		backing
	)
	_tile_plane(
		root,
		Vector3(0.0, ROOM_FLOOR_Y + 0.006, ROOM_CENTER_Z),
		Basis.IDENTITY,
		Vector2(ROOM_WIDTH - 0.04, ROOM_DEPTH - 0.04),
		_tile_material(tile_shader, 35.0, 27.0, 0.66, 0.68)
	)

	_solid_box(
		root,
		Vector3(0.0, ROOM_CEILING_Y + 0.25, ROOM_CENTER_Z),
		Vector3(ROOM_WIDTH, 0.50, ROOM_DEPTH),
		backing
	)
	var ceiling_basis := Basis(Vector3.RIGHT, PI)
	_tile_plane(
		root,
		Vector3(0.0, ROOM_CEILING_Y - 0.006, ROOM_CENTER_Z),
		ceiling_basis,
		Vector2(ROOM_WIDTH - 0.04, ROOM_DEPTH - 0.04),
		_tile_material(tile_shader, 35.0, 27.0, 0.52, 0.54)
	)

	# Long side walls.
	var side_wall_size := Vector3(WALL_THICKNESS, ROOM_HEIGHT, ROOM_DEPTH)
	for side in [-1.0, 1.0]:
		_solid_box(
			root,
			Vector3(float(side) * wall_center_x, room_center_y, wall_center_z),
			side_wall_size,
			backing
		)
		var inner_x: float = float(side) * (half_width - WALL_THICKNESS)
		var yaw: float = PI * 0.5 if float(side) < 0.0 else -PI * 0.5
		var side_basis := Basis(Vector3.UP, yaw) * Basis(Vector3.RIGHT, PI * 0.5)
		_tile_plane(
			root,
			Vector3(inner_x, room_center_y, wall_center_z),
			side_basis,
			Vector2(ROOM_DEPTH - 0.04, ROOM_HEIGHT),
			_tile_material(tile_shader, 27.0, 7.0, 0.66, 0.64)
		)

	# Rear wall closes the far end.
	_solid_box(
		root,
		Vector3(0.0, room_center_y, ROOM_BACK_Z - WALL_THICKNESS * 0.5),
		Vector3(ROOM_WIDTH, ROOM_HEIGHT, WALL_THICKNESS),
		backing
	)
	_tile_plane(
		root,
		Vector3(0.0, room_center_y, ROOM_BACK_Z),
		Basis(Vector3.UP, PI) * Basis(Vector3.RIGHT, PI * 0.5),
		Vector2(ROOM_WIDTH, ROOM_HEIGHT),
		_tile_material(tile_shader, 35.0, 7.0, 0.70, 0.66)
	)

	# The entrance wall is split around a wide open doorway to the staircase.
	var doorway_width: float = STAIR_WIDTH
	var side_segment_width: float = (ROOM_WIDTH - doorway_width) * 0.5
	var side_segment_x: float = doorway_width * 0.5 + side_segment_width * 0.5
	var front_wall_center_z: float = ROOM_FRONT_Z + WALL_THICKNESS * 0.5
	for side in [-1.0, 1.0]:
		var wall_center := Vector3(float(side) * side_segment_x, room_center_y, front_wall_center_z)
		var wall_size := Vector3(side_segment_width, ROOM_HEIGHT, WALL_THICKNESS)
		_solid_box(root, wall_center, wall_size, backing)
		_tile_plane(
			root,
			Vector3(float(side) * side_segment_x, room_center_y, ROOM_FRONT_Z),
			Basis(Vector3.RIGHT, PI * 0.5),
			Vector2(side_segment_width, ROOM_HEIGHT),
			_tile_material(tile_shader, 15.0, 7.0, 0.66, 0.62)
		)

	var lintel_bottom: float = ROOM_FLOOR_Y + 4.4
	var lintel_height: float = ROOM_CEILING_Y - lintel_bottom
	var lintel_center_y: float = lintel_bottom + lintel_height * 0.5
	_solid_box(
		root,
		Vector3(0.0, lintel_center_y, front_wall_center_z),
		Vector3(doorway_width, lintel_height, WALL_THICKNESS),
		backing
	)
	_tile_plane(
		root,
		Vector3(0.0, lintel_center_y, ROOM_FRONT_Z),
		Basis(Vector3.RIGHT, PI * 0.5),
		Vector2(doorway_width, lintel_height),
		_tile_material(tile_shader, 5.0, 3.0, 0.60, 0.64)
	)

	# Four blunt tiled piers break the scale of the room without blocking its open center.
	for x in [-11.0, 11.0]:
		for z in [-72.5, -87.0]:
			var pier_x: float = float(x)
			var pier_z: float = float(z)
			var pier_height: float = ROOM_HEIGHT - 0.12
			var pier_size := Vector3(0.82, pier_height, 0.82)
			_solid_box(root, Vector3(pier_x, room_center_y, pier_z), pier_size, backing)
			var pier_y: float = room_center_y
			var pier_material := _tile_material(tile_shader, 1.0, 7.0, 0.64, 0.60)
			# Front face of each pier catches the cold ceiling light.
			_tile_plane(
				root,
				Vector3(pier_x, pier_y, pier_z + 0.416),
				Basis(Vector3.RIGHT, PI * 0.5),
				Vector2(0.82, pier_height),
				pier_material
			)


func _build_lighting(root: Node3D) -> void:
	var fixture_material := _material(Color(0.72, 0.78, 0.80), 0.32)
	fixture_material.emission_enabled = true
	fixture_material.emission = Color(0.66, 0.78, 0.88)
	fixture_material.emission_energy_multiplier = 1.6
	for lamp_index in range(5):
		var z: float = -68.5 - float(lamp_index) * 6.6
		var fixture := MeshInstance3D.new()
		var fixture_mesh := BoxMesh.new()
		fixture_mesh.size = Vector3(2.4, 0.10, 0.42)
		fixture.mesh = fixture_mesh
		fixture.position = Vector3(0.0, ROOM_CEILING_Y + 0.12, z)
		fixture.material_override = fixture_material
		root.add_child(fixture)

		var light := OmniLight3D.new()
		light.position = Vector3(0.0, ROOM_CEILING_Y + 1.5, z)
		light.light_color = Color(0.69, 0.79, 0.91)
		light.light_energy = 1.75
		light.omni_range = 13.0
		light.shadow_enabled = lamp_index == 1
		root.add_child(light)

	# A pair of warmer lamps make the stair opening legible from the top.
	for side in [-1.0, 1.0]:
		var amber := _material(Color(0.70, 0.46, 0.22), 0.34)
		amber.emission_enabled = true
		amber.emission = Color(1.0, 0.39, 0.12)
		amber.emission_energy_multiplier = 1.8
		var lamp := MeshInstance3D.new()
		var lamp_mesh := BoxMesh.new()
		lamp_mesh.size = Vector3(0.20, 0.18, 0.42)
		lamp.mesh = lamp_mesh
		lamp.position = Vector3(float(side) * 2.88, -0.10, -38.4)
		lamp.material_override = amber
		root.add_child(lamp)
		var glow := OmniLight3D.new()
		glow.position = lamp.position + Vector3(0.0, -0.15, 0.0)
		glow.light_color = Color(1.0, 0.48, 0.22)
		glow.light_energy = 0.8
		glow.omni_range = 5.5
		root.add_child(glow)


func _visual_box(parent: Node3D, center: Vector3, size: Vector3, material: Material) -> MeshInstance3D:
	var mesh_instance := MeshInstance3D.new()
	var box_mesh := BoxMesh.new()
	box_mesh.size = size
	mesh_instance.mesh = box_mesh
	mesh_instance.position = center
	mesh_instance.material_override = material
	parent.add_child(mesh_instance)
	return mesh_instance


func _solid_box(parent: Node3D, center: Vector3, size: Vector3, material: Material) -> StaticBody3D:
	var body := StaticBody3D.new()
	body.position = center
	var mesh_instance := MeshInstance3D.new()
	var box_mesh := BoxMesh.new()
	box_mesh.size = size
	mesh_instance.mesh = box_mesh
	mesh_instance.material_override = material
	body.add_child(mesh_instance)

	var collision := CollisionShape3D.new()
	var box_shape := BoxShape3D.new()
	box_shape.size = size
	collision.shape = box_shape
	body.add_child(collision)
	parent.add_child(body)
	return body


func _tile_plane(
	parent: Node3D,
	center: Vector3,
	plane_basis: Basis,
	size: Vector2,
	material: Material
) -> MeshInstance3D:
	var plane := PlaneMesh.new()
	plane.size = size
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.mesh = plane
	mesh_instance.position = center
	mesh_instance.basis = plane_basis
	mesh_instance.material_override = material
	parent.add_child(mesh_instance)
	return mesh_instance


func _tile_material(
	shader: Shader,
	tiles_x: float,
	tiles_y: float,
	grime: float,
	damage: float
) -> ShaderMaterial:
	var material := ShaderMaterial.new()
	material.shader = shader
	material.set_shader_parameter("tile_scale", Vector2(tiles_x, tiles_y))
	material.set_shader_parameter("grime_strength", grime)
	material.set_shader_parameter("damage_strength", damage)
	return material


func _material(color: Color, roughness: float = 0.92) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = roughness
	return material
