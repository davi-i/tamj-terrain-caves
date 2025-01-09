extends Node

const WIDTH = 80
const HEIGHT = 60
const CELL_SIZE = 10
const WALL_HEIGHT = 5

var grid = []
var start_position = Vector2.ZERO
var player : Node3D

func _ready():
	randomize()
	initialize_grid()
	generate_cave()
	choose_start_position()
	#draw_2d_cave()
	draw_3d_cave()
	move_player_to_start()

func initialize_grid():
	for x in range(WIDTH):
		grid.append([])
		for y in range(HEIGHT):
			grid[x].append(randf() < 0.45)

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
			if grid[x][y]:  # A célula é uma parede (preta)
				valid_positions.append(Vector2(x, y))
	
	if valid_positions.size() > 0:
		start_position = valid_positions[randi() % valid_positions.size()]

func move_player_to_start():
	var player_node = get_node("PseudoPlayer")
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
	for x in range(WIDTH):
		for y in range(HEIGHT):
			if grid[x][y]:
				var wall = MeshInstance3D.new()
				wall.mesh = BoxMesh.new()
				wall.scale = Vector3(CELL_SIZE, WALL_HEIGHT, CELL_SIZE)
				wall.position = Vector3(x * CELL_SIZE, WALL_HEIGHT / 2, y * CELL_SIZE)
				add_child(wall)
				
				var wall_collision = CollisionShape3D.new()  # Forma de colisão da parede
				var wall_shape = BoxShape3D.new()
				wall_collision.shape = wall_shape
				wall.add_child(wall_collision)
				add_child(wall)

				var floor = MeshInstance3D.new()
				floor.mesh = BoxMesh.new()
				floor.scale = Vector3(CELL_SIZE, 1, CELL_SIZE)
				floor.position = Vector3(x * CELL_SIZE, 0, y * CELL_SIZE)
				add_child(floor)

				var floor_collision = CollisionShape3D.new()  # Forma de colisão do chão
				var floor_shape = BoxShape3D.new()
				floor_collision.shape = floor_shape
				floor.add_child(floor_collision)

				var ceiling = MeshInstance3D.new()
				ceiling.mesh = BoxMesh.new()
				ceiling.scale = Vector3(CELL_SIZE, 1, CELL_SIZE)
				ceiling.position = Vector3(x * CELL_SIZE, WALL_HEIGHT, y * CELL_SIZE)
				add_child(ceiling)

				var ceiling_collision = CollisionShape3D.new()  # Forma de colisão do teto
				var ceiling_shape = BoxShape3D.new()
				ceiling_collision.shape = ceiling_shape
				ceiling.add_child(ceiling_collision)
