extends MeshInstance3D

var speed = .1
var time_factor = 0.0

func _process(delta: float) -> void:
	time_factor += delta * speed
	time_factor = fmod(time_factor, 1.0)
	mesh.material.set_shader_parameter("time_factor", time_factor)
