extends Node3D
class_name CaveEntrance

var starting = false
var cave_res = preload("res://scenes/cave_generator.tscn")

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
	main.add_child(cave)
	#cave.add_child(player)
	#get_tree().change_scene_to_packed(cave)
	#root.add_child(cave)
	#cave.global_position = Vector3(global_position.x, global_position.y - 500, global_position.z)


func _on_body_exited(body: Node3D) -> void:
	if body is Player:
		print("exited", body)
		starting = false
