@tool
extends StaticBody3D
class_name Terrain

var tree_res = preload("res://scenes/tree.tscn")
var cave_res = preload("res://scenes/cave_entrance.tscn")

@export var size: float : 
	set(new):
		size = new
		if Engine.is_editor_hint():
			generate_mesh()
@export var subdivide: float: 
	set(new):
		subdivide = new
		if Engine.is_editor_hint():
			generate_mesh()
@export var lacunarity: float: 
	set(new):
		lacunarity = new
		if Engine.is_editor_hint():
			generate_mesh()
@export var persistence: float: 
	set(new):
		persistence = new
		if Engine.is_editor_hint():
			generate_mesh()
@export var octaves: float: 
	set(new):
		octaves = new
		if Engine.is_editor_hint():
			generate_mesh()
@export var offset: Vector2: 
	set(new):
		offset = new
		if Engine.is_editor_hint():
			generate_mesh()
@export var terrain_noise: FastNoiseLite: 
	set(new):
		terrain_noise = new
		if Engine.is_editor_hint():
			generate_mesh()
@export var cave_noise: FastNoiseLite: 
	set(new):
		cave_noise = new
		if Engine.is_editor_hint():
			generate_mesh()
@export var cave_dispersion_noise: FastNoiseLite: 
	set(new):
		cave_dispersion_noise = new
		if Engine.is_editor_hint():
			generate_mesh()
@export var tree_noise: FastNoiseLite: 
	set(new):
		tree_noise = new
		if Engine.is_editor_hint():
			generate_mesh()
@export var tree_dispersion_noise: FastNoiseLite: 
	set(new):
		tree_dispersion_noise = new
		if Engine.is_editor_hint():
			generate_mesh()
@export var color: Color: 
	set(new):
		color = new
		if Engine.is_editor_hint():
			generate_mesh()
@export var total_amplitude: float: 
	set(new):
		total_amplitude = new
		if Engine.is_editor_hint():
			generate_mesh()
var rng = RandomNumberGenerator.new()

func _ready() -> void:
	generate_mesh()

var terrain_shader = preload("res://materials/terrain.gdshader")

# Called when the node enters the scene tree for the first time.
func generate_mesh() -> void:
	var plane_mesh = PlaneMesh.new()
	plane_mesh.size = Vector2(size,size)
	plane_mesh.subdivide_depth = subdivide
	plane_mesh.subdivide_width = subdivide
	
	var surface_tool = SurfaceTool.new()
	surface_tool.create_from(plane_mesh,0)
	var data = surface_tool.commit_to_arrays()
	var vertices = data[ArrayMesh.ARRAY_VERTEX]

	var noise_map = {}
	var max = -1
	var min = 1
	var noises_values = []
	var max_possible_value = 0
	for i in range(octaves):
		max_possible_value += pow(persistence, i)
	for i in vertices.size():
		var vertex = vertices[i]
		var height = 0
		var amplitude = 1
		var frequency = 1
		for j in range(octaves):
			var sample_x = (vertex.x + offset.x) * frequency
			var sample_y = (vertex.z + offset.y) * frequency
			var noise_value = terrain_noise.get_noise_2d(sample_x, sample_y) + 1
			height += noise_value * amplitude
			amplitude *= persistence
			frequency *= lacunarity
		if height > max:
			max = height
		elif height < min:
			min = height
		noises_values.push_back(height)
	for i in noises_values.size():
		var normal_noise = (noises_values[i] - 1) / (max_possible_value / 1.75) 
		var y = normal_noise * total_amplitude
		vertices[i].y = y
	
	data[ArrayMesh.ARRAY_VERTEX] = vertices
		
	var array_mesh = ArrayMesh.new()
	array_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES,data)
	
	surface_tool.create_from(array_mesh,0)
	surface_tool.generate_normals()

	var find_in_vertices = func(x: float, z: float):
		var closest_y = null
		var min_distance = INF

		for vertex in vertices:
			var distance = abs(Vector2(vertex.x, vertex.z).distance_to(Vector2(x, z)))
			if distance < min_distance:
				min_distance = distance
				closest_y = vertex.y
		return closest_y
	var tree_step = 8.0
	for x in range(-size / 2, size / 2, tree_step):
		for z in range(-size / 2, size / 2, tree_step):
			var tree_noise_value = tree_noise.get_noise_2d(x, z)
			#var rounded_x = roundi((vertex.x + offset.x) * 10000)
			#var rounded_y = roundi((vertex.z + offset.y) * 10000)
			if tree_noise_value >= 0.2:
				var tree: TreeObj = tree_res.instantiate()
				var dispersion = tree_dispersion_noise.get_noise_2d(x, z)
				tree.position.x = x + dispersion * (tree_step / 2.0)
				tree.position.y = find_in_vertices.call(x, z)
				tree.position.z = z + dispersion * (tree_step / 2.0)
				rng.seed = hash(Vector2(x, z) + offset)
				tree.rotation.y = rng.randf_range(0, 2 * PI)
				add_child(tree)
	var cave_step = 64
	var caves_positions = []
	for x in range(-size / 2, size / 2, cave_step):
		for z in range(-size / 2, size / 2, cave_step):
			var cave_noise_value = cave_noise.get_noise_2d(x, z)
			if cave_noise_value >= 0.2:
				var cave = cave_res.instantiate()
				var dispersion = cave_dispersion_noise.get_noise_2d(x, z)
				cave.position.x = x + dispersion * (cave_step / 2.0)
				cave.position.y = find_in_vertices.call(x, z)
				cave.position.z = z + dispersion * (cave_step / 2.0)
				caves_positions.append(cave.position)
				add_child(cave)
				print(cave.global_position)
	
	var mesh = surface_tool.commit()
	var shader_material = ShaderMaterial.new()
	shader_material.shader = terrain_shader
	shader_material.set_shader_parameter("color", Vector3(color.r, color.g, color.b))
	shader_material.set_shader_parameter("cylinder_positions", caves_positions)
	shader_material.set_shader_parameter("cylinder_count", len(caves_positions))
	mesh.surface_set_material(0, shader_material)
	
	
	$MeshInstance3D.mesh = mesh
	
	$CollisionShape3D.shape = array_mesh.create_trimesh_shape()
