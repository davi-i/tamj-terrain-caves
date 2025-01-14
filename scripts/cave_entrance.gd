extends Node3D

var speed = .1

var time_factor = 0.0

var cave_res = preload("res://scenes/cave_generator.tscn")

func _process(delta: float) -> void:
	time_factor += delta * speed
	time_factor = fmod(time_factor, 1.0)
	$MeshInstance3D2.mesh.material.set_shader_parameter("time_factor", time_factor)

var entered = false

func _on_body_entered(body: Node3D) -> void:
	if body is not Player:
		return
	print("entered", body)
	var main = get_tree().root.get_node("Main")
	var terrain = main.get_node("TerrainGenerator")
	terrain.process_mode = Node.PROCESS_MODE_DISABLED
	terrain.visible = false
	var cave = cave_res.instantiate()
	cave.seed = hash(global_position)
	main.add_child(cave)
	#cave.add_child(player)
	#get_tree().change_scene_to_packed(cave)
	#root.add_child(cave)
	#cave.global_position = Vector3(global_position.x, global_position.y - 500, global_position.z)
