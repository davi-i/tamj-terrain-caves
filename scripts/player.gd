extends CharacterBody3D
class_name Player


const BASE_SPEED = 5.0
const JUMP_VELOCITY = 4.5
const RUNNING_SPEED = BASE_SPEED * 5

var speed = BASE_SPEED

signal toggle_inventory()

@export var inventory_data: InventoryData
var inventory_is_open: bool = false

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "foward", "backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()
	
	$CanvasLayer/Label.text = str(global_position)

var mouse_sens = 0.3

func _input(event):
	if event is InputEventMouseMotion and not inventory_is_open:
		rotate_y(deg_to_rad(-event.relative.x * mouse_sens))
		$Camera3D.rotate_x(deg_to_rad(-event.relative.y * mouse_sens))
		if $Camera3D.rotation.x < -PI / 4:
			$Camera3D.rotation.x = -PI / 4
		if $Camera3D.rotation.x > PI / 4:
			$Camera3D.rotation.x = PI / 4


	elif event is InputEvent:
		if event.is_action_pressed("run"):
			speed = RUNNING_SPEED
		if event.is_action_pressed("inventory"):
			inventory_is_open = !inventory_is_open
			toggle_inventory.emit()
		elif event.is_action_released("run"):
			speed = BASE_SPEED
