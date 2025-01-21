extends Node3D
class_name CaveEntrance

var starting = false
var cave_res = preload("res://scenes/cave_generator.tscn")
var coletados = []

func _on_body_entered(body: Node3D) -> void:
	if body is not Player or starting:
		return
	print("entered", body)
	var main = get_tree().root.get_node("Main")
	var terrain = main.get_node("TerrainGenerator")
	terrain.set_deferred("process_mode", Node.PROCESS_MODE_DISABLED)
	terrain.visible = false
	var cave = cave_res.instantiate()
	cave.seed = hash(global_position)
	cave.entrance = self
	cave.rng.seed = cave.seed
	cave.initialize_grid()
	cave.generate_cave()
	cave.choose_start_position()
	cave.save_pick_up_positions()
	cave.coletados = coletados
	main.add_child(cave)
	cave.connect("collected", Callable(self, "coletadosadd"))
	#cave.add_child(player)
	#get_tree().change_scene_to_packed(cave)
	#root.add_child(cave)
	#cave.global_position = Vector3(global_position.x, global_position.y - 500, global_position.z)

func coletadosadd(position: Vector2):
	print("Coletou de dentro da caverna")
	coletados.append(position)

func _on_body_exited(body: Node3D) -> void:
	if body is Player:
		print("exited", body)
		starting = false
