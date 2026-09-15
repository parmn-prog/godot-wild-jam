class_name Player extends Node3D
@onready var player_input_component: PlayerInputComponent = $PlayerInputComponent
const SPACE_SHIP_DIRECT = preload("uid://bndmg63f4v6k8")
const SPACE_SHIP = preload("uid://cr7stkbrtvp5t")


func _ready() -> void:
	match GameManager.ship_type:
		GameManager.Ship.Direct:
			var ship: SpaceShipDirect = SPACE_SHIP_DIRECT.instantiate()
			add_child(ship)
			var camera: Camera3D = Camera3D.new()
			ship.add_child(camera)
			camera.position.z = -5
			camera.current = true
			player_input_component.ship_body = ship
			
		GameManager.Ship.Physics:
			var ship: ShipPhysicsBody = SPACE_SHIP.instantiate()
			add_child(ship)
			var camera: Camera3D = Camera3D.new()
			ship.add_child(camera)
			camera.position.z = -5
			camera.current = true
			player_input_component.ship_body = ship
	DebugShi.generate_ui_for_node([player_input_component, player_input_component.ship_body])
