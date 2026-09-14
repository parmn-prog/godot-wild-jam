class_name PlayerInputComponent extends Node

@export var ship_body: ShipPhysicsBody

@export var mouse_sensitivity: float = 0.002
@export var invert_control: bool = false
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		ship_body.stick.x = clamp(ship_body.stick.x + event.relative.x * mouse_sensitivity, -1.0, 1.0)
		ship_body.stick.y = clamp(ship_body.stick.y + event.relative.y * mouse_sensitivity * -1 if invert_control else 1, -1.0, 1.0)
	
	

func _physics_process(delta: float) -> void:
	ship_body.yaw_input = 0.0
	if Input.is_action_pressed("yaw_right"):
		ship_body.yaw_input -= 1
	if Input.is_action_pressed("yaw_left"):
		ship_body.yaw_input += 1
	ship_body.thrust_input = Input.get_axis("thrust_backward", "thrust_forward")
