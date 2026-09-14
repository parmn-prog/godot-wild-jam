class_name ShipPhysicsBody
extends RigidBody3D

@export_group("Virtual Joystick (Mouse)")

@export var stick_return_speed: float = 1.0

@export_group("Rotation")
@export var max_pitch_torque: float = 3000.0
@export var max_yaw_torque: float = 3000.0
@export var max_roll_torque: float = 2000.0
@export_group("Thrust")
@export var max_thrust: float = 1500.0
@export var throttle_rate: float = 0.8

var stick: Vector2 = Vector2.ZERO
var yaw_input: float = 0.0
var throttle: float = 0.0
var thrust_input: float
func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	linear_damp = 0.0
	angular_damp = 0.0


func _physics_process(delta: float) -> void:
	_apply_rotation_torque()
	_apply_stick_return(delta)
	_apply_throttle(delta)
	_apply_thrust()

func _apply_rotation_torque() -> void:
	var pitch_torque: Vector3 = global_transform.basis.x * -stick.y * max_pitch_torque
	var roll_torque: Vector3 = -global_transform.basis.z * stick.x * max_roll_torque
	var yaw_torque: Vector3 = global_transform.basis.y * yaw_input * max_yaw_torque
	
	apply_torque(pitch_torque + yaw_torque + roll_torque)

func _apply_stick_return(delta: float) -> void:
	if stick_return_speed > 0.0:
		stick = stick.move_toward(Vector2.ZERO, stick_return_speed * delta)

func _apply_thrust() -> void:

	var force: Vector3 = Vector3.ZERO
	force += -global_transform.basis.z * throttle * max_thrust
	apply_central_force(force)
	

func _apply_throttle(delta: float) -> void:
	throttle = clamp(throttle + throttle_rate * delta * thrust_input, -1.0, 1.0)
