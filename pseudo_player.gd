extends CharacterBody3D


const SPEED = 5.0
const FLY_VELOCITY = 4.5  # Velocidade de voo (subir/descer)

var is_flying = false  # Indica se o jogador está no modo de voo
var mouse_sens = 0.3  # Sensibilidade do mouse

func _physics_process(delta: float) -> void:
	# Controle de voo (subir com espaço e descer com X)
	if Input.is_action_just_pressed("ui_"):  # Espaço
		is_flying = true  # Ativa o voo (subir)
	elif Input.is_action_just_pressed("ui_cancel"):  # X
		is_flying = false  # Desativa o voo (descer)

	# Controle de altura se estiver voando
	if is_flying:
		if Input.is_action_pressed("ui_accept"):  # Subir
			velocity.y = FLY_VELOCITY
		elif Input.is_action_pressed("ui_cancel"):  # Descer
			velocity.y = -FLY_VELOCITY
		else:
			velocity.y = 0  # Fica parado no eixo Y quando não pressionado

	# Movimentação com as teclas WASD (ou setas)
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	# Não afetar pela gravidade
	velocity.y = 0

	move_and_slide()

func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * mouse_sens))
		$Camera3D.rotate_x(deg_to_rad(-event.relative.y * mouse_sens))
		if $Camera3D.rotation.x < -PI / 4:
			$Camera3D.rotation.x = -PI / 4
		if $Camera3D.rotation.x > PI / 4:
			$Camera3D.rotation.x = PI / 4
	elif event is InputEvent:
		if event.is_action_pressed("exit"):
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		elif event.is_action_pressed("enter"):
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
