extends Node3D

@export var chunk_size: float
@export var chunk_subdivide: float
@export var lacunarity: float
@export var persistence: float
@export var octaves: float
@export var total_amplitude: float
@export var cave_noise: FastNoiseLite
@export var cave_dispersion_noise: FastNoiseLite
@export var tree_noise: FastNoiseLite
@export var tree_dispersion_noise: FastNoiseLite
@export var terrain_noise: FastNoiseLite
@export var player: Player

var terrain_res = preload("res://scenes/terrain.tscn")

func rand_color():
	return Color(randf_range(0, 1), randf_range(0, 1), randf_range(0, 1))

var last_pos: Vector2
var terrains = {}

func generate_terrain(pos: Vector2) -> void:
	if terrains.has(pos):
		print('already created')
		return
	var terrain: Terrain = terrain_res.instantiate()
	terrain.size = chunk_size
	terrain.lacunarity = lacunarity
	terrain.persistence = persistence
	terrain.octaves = octaves
	terrain.subdivide = chunk_subdivide
	terrain.total_amplitude = total_amplitude
	terrain.color = rand_color()
	terrain.offset = pos * chunk_size
	terrain.terrain_noise = terrain_noise
	terrain.tree_noise = tree_noise
	terrain.tree_noise.offset.x = pos.x * chunk_size
	terrain.tree_noise.offset.y =  pos.y * chunk_size
	terrain.tree_dispersion_noise = tree_dispersion_noise
	terrain.tree_dispersion_noise.offset.x =  pos.x * chunk_size
	terrain.tree_dispersion_noise.offset.y =  pos.y * chunk_size
	terrain.cave_noise = cave_noise
	terrain.cave_noise.offset.x = pos.x * chunk_size
	terrain.cave_noise.offset.y =  pos.y * chunk_size
	terrain.cave_dispersion_noise = cave_dispersion_noise
	terrain.cave_dispersion_noise.offset.x =  pos.x * chunk_size
	terrain.cave_dispersion_noise.offset.y =  pos.y * chunk_size
	terrain.position.x = pos.x * chunk_size
	terrain.position.z = pos.y * chunk_size
	add_child(terrain)
	terrains[pos] = terrain

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_world_3d().environment.fog_depth_end = chunk_size
	
	var x = roundi(player.position.x / chunk_size)
	var y = roundi(player.position.z / chunk_size)
	
	last_pos = Vector2(x, y)
	
	
	for i in range(y - 1, y + 2):
		for j in range(x - 1, x + 2):
			generate_terrain(Vector2(j, i))

func delete_terrain(pos: Vector2):
	if !terrains.has(pos):
		print('didnt exist')
		return
	terrains[pos].queue_free()
	terrains.erase(pos)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var x = roundi(player.position.x / chunk_size)
	var y = roundi(player.position.z / chunk_size)
	
	var pos = Vector2(x, y)
	
	if pos != last_pos:
		var diff = pos - last_pos
		var dir = sign(diff)
		var abs_diff = abs(diff)
		
		var high_bound = abs_diff.x - 1
		for j in range(-1, min(high_bound, 2)):
			for i in range(-1, 2):
				var offset = Vector2(j * dir.x, i)
				delete_terrain(last_pos + offset)
				generate_terrain(pos - offset)
				
		for j in range(high_bound, 2):
			for i in range(-1, min(abs_diff.y - 1, 2)):
				var j_dir = 1 if dir.x > 0 else -1
				var offset = Vector2(j * j_dir, i * dir.y)
				delete_terrain(last_pos + offset)
				generate_terrain(pos - offset)

		last_pos = pos
