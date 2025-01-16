extends Node3D

const PickUp = preload("res://item/pick_ups/pick_up.tscn")

@onready var player: CharacterBody3D = $Player
@onready var inventory_interface: Control = $UI/inventoryinterface
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player.toggle_inventory.connect(toggle_inventory_interface)
	inventory_interface.set_player_inventory_data(player.inventory_data)

func toggle_inventory_interface() -> void:
	inventory_interface.visible = not inventory_interface.visible
	
	if inventory_interface.visible:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _on_inventoryinterface_drop_slot_data(slot_data: SlotData) -> void:
	print(slot_data)
	var pick_up = PickUp.instantiate()
	pick_up.slot_data = slot_data
	print(pick_up.slot_data)
	pick_up.position = Vector3.UP
	add_child(pick_up)
