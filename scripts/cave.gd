@tool
extends StaticBody3D
class_name Cave

@export var height: float:
	set(new):
		height = new
		if Engine.is_editor_hint():
			generate_mesh()

@export var width: float:
	set(new):
		width = new
		if Engine.is_editor_hint():
			generate_mesh()

@export var cell_size: float:
	set(new):
		cell_size = new
		if Engine.is_editor_hint():
			generate_mesh()

@export var wall_height: float:
	set(new):
		wall_height = new
		if Engine.is_editor_hint():
			generate_mesh()

var grid = []

func _ready() -> void:
	if not Engine.is_editor_hint():
		generate_mesh()

func set_grid(new_grid: Array):
	grid = new_grid
	generate_mesh()

func generate_mesh() -> void:
	# Reset children (if any) to avoid overlapping
	for child in get_children():
		child.queue_free()

	var surface_tool = SurfaceTool.new()
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	var wall_material = StandardMaterial3D.new()
	wall_material.albedo_color = Color(0.5, 0.5, 0.5)  # Gray color for walls
	
	var floor_material = StandardMaterial3D.new()
	floor_material.albedo_color = Color(0, 0, 1)  # Blue color for the floor
	
	for x in range(grid.size()):
		for y in range(grid[x].size()):
			var cell_position = Vector3(x * cell_size, 0, y * cell_size)
			if grid[x][y]:
				# Add wall vertices
				add_wall_vertices(surface_tool, cell_position, wall_material)
			else:
				# Add floor vertices
				add_floor_vertices(surface_tool, cell_position, floor_material)
	
	var mesh = surface_tool.commit()
	
	# Apply mesh to MeshInstance3D
	var mesh_instance = MeshInstance3D.new()
	mesh_instance.mesh = mesh
	$MeshInstance3D.mesh = mesh
	add_child(mesh_instance)

	# Create collision
	var collision_shape = CollisionShape3D.new()
	collision_shape.shape = mesh.create_trimesh_shape()
	$CollisionShape3D.shape = collision_shape.shape
	add_child(collision_shape)
	

func add_wall_vertices(surface_tool: SurfaceTool, position: Vector3, material: Material):
	var height = wall_height
	var base_vertices = [
		position,
		position + Vector3(cell_size, 0, 0),
		position + Vector3(cell_size, 0, cell_size),
		position + Vector3(0, 0, cell_size)
	]
	
	var top_vertices = [
		base_vertices[0] + Vector3(0, height, 0),
		base_vertices[1] + Vector3(0, height, 0),
		base_vertices[2] + Vector3(0, height, 0),
		base_vertices[3] + Vector3(0, height, 0)
	]
	
	# Create wall faces
	add_quad(surface_tool, base_vertices[0], base_vertices[1], top_vertices[1], top_vertices[0])  # Front
	add_quad(surface_tool, base_vertices[1], base_vertices[2], top_vertices[2], top_vertices[1])  # Right
	add_quad(surface_tool, base_vertices[2], base_vertices[3], top_vertices[3], top_vertices[2])  # Back
	add_quad(surface_tool, base_vertices[3], base_vertices[0], top_vertices[0], top_vertices[3])  # Left
	add_quad(surface_tool, top_vertices[0], top_vertices[1], top_vertices[2], top_vertices[3])    # Top

	surface_tool.set_material(material)

func add_floor_vertices(surface_tool: SurfaceTool, position: Vector3, material: Material):
	var vertices = [
		position,
		position + Vector3(cell_size, 0, 0),
		position + Vector3(cell_size, 0, cell_size),
		position + Vector3(0, 0, cell_size)
	]
	add_quad(surface_tool, vertices[0], vertices[1], vertices[2], vertices[3])  # Floor
	surface_tool.set_material(material)

func add_quad(surface_tool: SurfaceTool, v1: Vector3, v2: Vector3, v3: Vector3, v4: Vector3):
	surface_tool.add_vertex(v1)
	surface_tool.add_vertex(v2)
	surface_tool.add_vertex(v3)
	surface_tool.add_vertex(v1)
	surface_tool.add_vertex(v3)
	surface_tool.add_vertex(v4)
	#$MeshInstance3D.mesh = mesh
	#$CollisionShape3D.shape = array_mesh.create_trimesh_shape()
