extends Node3D

var speed = .1

var time_factor = 0.0

var cave_res = preload("res://scenes/cave.tscn")

func _process(delta: float) -> void:
	time_factor += delta * speed
	time_factor = fmod(time_factor, 1.0)
	$MeshInstance3D2.mesh.material.set_shader_parameter("time_factor", time_factor)

var entered = false

func _on_body_entered(body: Node3D) -> void:
	if body is not Player:
		return
	print("entered", body)
	var root = get_tree().root
	var player = root.find_child("Player", true, false)
	player.get_parent().remove_child(player)
	var cave = cave_res.instantiate()
	root.add_child(cave)
	cave.add_child(player)
	cave.global_position = Vector3(global_position.x, global_position.y - 500, global_position.z)
