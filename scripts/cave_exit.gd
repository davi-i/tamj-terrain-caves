extends Node3D

var entrance: CaveEntrance
var starting = false
var cave_res = preload("res://scenes/cave_generator.tscn")

func _on_body_entered(body: Node3D) -> void:
	print("starting ", starting)
	if body is not Player or starting:
		return
	print("entered", body)
	var main = get_tree().root.get_node("Main")
	var terrain = main.get_node("TerrainGenerator")
	terrain.process_mode = Node.PROCESS_MODE_INHERIT
	terrain.visible = true
	
	entrance.starting = true
	main.get_node("Player").global_position = entrance.global_position
	
	get_parent().queue_free()
	#cave.add_child(player)
	#get_tree().change_scene_to_packed(cave)
	#root.add_child(cave)
	#cave.global_position = Vector3(global_position.x, global_position.y - 500, global_position.z)


func _on_body_exited(body: Node3D) -> void:
	if body is Player:
		print("exited", body)
		starting = false
