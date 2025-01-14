extends Node

const WIDTH = 40
const HEIGHT = 30
const CELL_SIZE = 5
const WALL_HEIGHT = 5
const NUM_LIGHTS = 10

var grid = []
var start_position = Vector2.ZERO
var player : Node3D

@export var seed = 0

var rng = RandomNumberGenerator.new()

func _ready():
	rng.seed = seed
	initialize_grid()
	generate_cave()
	choose_start_position()
	
	draw_2d_cave()
	draw_3d_cave()
	move_player_to_start()
	add_random_lights()

func initialize_grid():
	for x in range(WIDTH):
		grid.append([])
		for y in range(HEIGHT):
			if x == 0 or y == 0 or x == WIDTH - 1 or y == HEIGHT - 1:
				# Definir as bordas como paredes
				grid[x].append(true)
			else:
				# Células internas são geradas aleatoriamente
				grid[x].append(rng.randf() < 0.45)

func generate_cave():
	for i in range(4):
		var new_grid = grid.duplicate(true)
		for x in range(WIDTH):
			for y in range(HEIGHT):
				var wall_count = count_neighboring_walls(x, y)
				if grid[x][y]:
					new_grid[x][y] = wall_count > 3
				else:
					new_grid[x][y] = wall_count > 4
		grid = new_grid

func count_neighboring_walls(x, y):
	var count = 0
	for i in range(-1, 2):
		for j in range(-1, 2):
			if i == 0 and j == 0:
				continue
			var nx = x + i
			var ny = y + j
			if nx < 0 or nx >= WIDTH or ny < 0 or ny >= HEIGHT:
				count += 1
			elif grid[nx][ny]:
				count += 1
	return count

func choose_start_position():
	var valid_positions = []
	for x in range(WIDTH):
		for y in range(HEIGHT):
			if not grid[x][y]:  
				valid_positions.append(Vector2(x, y))
	
	if valid_positions.size() > 0:
		start_position = valid_positions[rng.randi() % valid_positions.size()]

func move_player_to_start():
	var player_node = get_tree().root.find_child("Player", true, false)
	if player_node:
		var player_pos_x = start_position.x * CELL_SIZE
		var player_pos_z = start_position.y * CELL_SIZE
		var player_pos_y = WALL_HEIGHT + 10 # Coloca o jogador no topo da parede
		
		player_node.position = Vector3(player_pos_x, player_pos_y, player_pos_z)

func draw_2d_cave():
	for x in range(WIDTH):
		for y in range(HEIGHT):
			var cell = ColorRect.new()
			cell.size = Vector2(CELL_SIZE, CELL_SIZE)
			cell.position = Vector2(x * CELL_SIZE, y * CELL_SIZE)
			
			if grid[x][y]:
				cell.color = Color.BLACK
			else:
				cell.color = Color.WHITE

			if Vector2(x, y) == start_position:
				cell.color = Color(0, 1, 0)

			add_child(cell)

func draw_3d_cave():
	var array_mesh = ArrayMesh.new()
	var surface_tool = SurfaceTool.new()
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	var wall_material = StandardMaterial3D.new()
	wall_material.albedo_color = Color.DIM_GRAY  # Cor cinza para paredes
	
	var floor_material = StandardMaterial3D.new()
	floor_material.albedo_color = Color.RED  # Cor azul para o chão
	
	for x in range(WIDTH):
		for y in range(HEIGHT):
			var cell_position = Vector3(x * CELL_SIZE, 0, y * CELL_SIZE)
			if grid[x][y]:
				# Criar os vértices das paredes
				add_wall_vertices(surface_tool, cell_position, wall_material)
			else:
				# Criar os vértices do chão
				add_floor_vertices(surface_tool, cell_position, floor_material)
	
	surface_tool.commit(array_mesh)
	
	var mesh_instance = MeshInstance3D.new()
	mesh_instance.mesh = array_mesh
	add_child(mesh_instance)

	var collision_shape = CollisionShape3D.new()
	collision_shape.shape = array_mesh.create_trimesh_shape()
	add_child(collision_shape)

func add_wall_vertices(surface_tool: SurfaceTool, position: Vector3, material: Material):
	var height = WALL_HEIGHT
	var base_vertices = [
		position,
		position + Vector3(CELL_SIZE, 0, 0),
		position + Vector3(CELL_SIZE, 0, CELL_SIZE),
		position + Vector3(0, 0, CELL_SIZE)
	]
	
	var top_vertices = [
		base_vertices[0] + Vector3(0, height, 0),
		base_vertices[1] + Vector3(0, height, 0),
		base_vertices[2] + Vector3(0, height, 0),
		base_vertices[3] + Vector3(0, height, 0)
	]
	
	# Criar as faces das paredes
	add_quad(surface_tool, base_vertices[0], base_vertices[1], top_vertices[1], top_vertices[0])  # Frente
	add_quad(surface_tool, base_vertices[1], base_vertices[2], top_vertices[2], top_vertices[1])  # Direita
	add_quad(surface_tool, base_vertices[2], base_vertices[3], top_vertices[3], top_vertices[2])  # Trás
	add_quad(surface_tool, base_vertices[3], base_vertices[0], top_vertices[0], top_vertices[3])  # Esquerda
	add_quad(surface_tool, top_vertices[0], top_vertices[1], top_vertices[2], top_vertices[3])    # Topo
	
	surface_tool.set_material(material)

func add_floor_vertices(surface_tool: SurfaceTool, position: Vector3, material: Material):
	var height = 0.5  # Altura do chão
	var vertices = [
		position,
		position + Vector3(CELL_SIZE, 0, 0),
		position + Vector3(CELL_SIZE, 0, CELL_SIZE),
		position + Vector3(0, 0, CELL_SIZE)
	]
	
	add_quad(surface_tool, vertices[0], vertices[1], vertices[2], vertices[3])  # Chão
	surface_tool.set_material(material)

func add_quad(surface_tool: SurfaceTool, v1: Vector3, v2: Vector3, v3: Vector3, v4: Vector3):
	surface_tool.add_vertex(v1)
	surface_tool.add_vertex(v2)
	surface_tool.add_vertex(v3)
	surface_tool.add_vertex(v1)
	surface_tool.add_vertex(v3)
	surface_tool.add_vertex(v4)

	
func add_random_lights():
	for i in range(NUM_LIGHTS):
		# Gera uma posição aleatória no grid, excluindo as bordas
		var rand_x = rng.randi_range(1, WIDTH - 2)
		var rand_y = rng.randi_range(1, HEIGHT - 2)
		
		if not grid[rand_x][rand_y]:  # Verifica se a célula é uma parede
			var light = OmniLight3D.new()
			light.position = Vector3(rand_x * CELL_SIZE, WALL_HEIGHT, rand_y * CELL_SIZE)
			light.light_energy = 50  # Intensidade da luz
			light.omni_range = 50
			light.light_color = Color.YELLOW
			add_child(light)
