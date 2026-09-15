extends Node3D
class_name SpaceShipDirect

@export_group("Virtual Joystick (Mouse)")

@export var stick_return_speed: float = 1.0

@export_group("Rotation")
@export var max_angular_speed: float = 2.0
@export var angular_acceleration: float = 6.0
@export var angular_friction: float = 4.0
@export_group("Translation")
@export var max_linear_speed: float = 4000.0
@export var linear_acceleration: float = 1000.0
@export var linear_friction: float = 500.0



var stick: Vector2 = Vector2.ZERO
var yaw_input: float = 0.0
var throttle: float = 0.0
var thrust_input: float

var angular_velocity: Vector3 = Vector3.ZERO
var linear_velocity: Vector3 = Vector3.ZERO

func _apply_stick_return(delta: float) -> void:
	if stick_return_speed > 0.0:
		stick = stick.move_toward(Vector2.ZERO, stick_return_speed * delta)

func _physics_process(delta: float) -> void:
	_apply_stick_return(delta)
	_apply_angular_velocity(delta)
	_update_linear_velocity(delta)
	_integrate(delta)

func _apply_angular_velocity(delta: float) -> void:
	var target: Vector3 = Vector3(-stick.y, yaw_input, stick.x) * max_angular_speed
	angular_velocity = _move_toward_vec3(angular_velocity, target, angular_acceleration, angular_friction, delta)	
	
func _move_toward_vec3(current: Vector3, target: Vector3, accel: float, friction: float, delta: float) -> Vector3:
	var rate: float = accel if target.length() > 0.01 else friction
	return current.move_toward(target, rate * delta)

func _update_linear_velocity(delta: float) -> void:
	var target: Vector3 = global_transform.basis * Vector3(0, 0, -1) * max_linear_speed * thrust_input
	linear_velocity = _move_toward_vec3(linear_velocity, target, linear_acceleration, linear_friction, delta)
	
func _integrate(delta: float) -> void:
	rotate_object_local(Vector3.RIGHT, angular_velocity.x * delta)
	rotate_object_local(Vector3.UP, angular_velocity.y * delta)
	rotate_object_local(Vector3.FORWARD, angular_velocity.z * delta)
	global_position += linear_velocity * delta
