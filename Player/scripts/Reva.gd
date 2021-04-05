extends KinematicBody

signal ready_fly(status)


const CAMERA_ROTATION_SPEED = 10
const MOTION_INTERPOLATE_SPEED = 10
const CAMERA_MOUSE_ROTATION_SPEED = 0.001
const JUMP_SPEED = 5.2
const MIN_CAMERA_ROT = -40
const MAX_CAMERA_ROT = 30
const MIN_AIRBORNE_TIME = 0.1

var root_motion: Transform = Transform()
var orientation: Transform = Transform()
var motion: Vector2 = Vector2.ZERO 
var velocity: Vector3
var gravity = -9.8
var camera_x_rot = 0.0

var airborne_time = 100


onready var player_model = get_node("reva")
onready var camera_root = get_node("camera")
onready var camera_base = get_node("camera/camera_base")
onready var camera_view = get_node("camera/camera_base/SpringArm/Camera")
onready var animation_tree = get_node("animation_tree")
onready var land = get_node("audio/land")
#onready var state_machine = $AnimationTree.get("parameters/playback")


func _ready() -> void:
	orientation = player_model.global_transform
	orientation.origin = Vector3()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
#func _process(delta: float) -> void:
#	velocity.y += gravity * delta
#	velocity = move_and_slide(velocity, Vector3.UP)
#	pass

func _physics_process(delta: float) -> void:
	var motion_target = Vector2(
		Input.get_action_strength("left") - Input.get_action_strength("right"),
		Input.get_action_strength("front") - Input.get_action_strength("back")
	)
	motion = motion.linear_interpolate(motion_target, MOTION_INTERPOLATE_SPEED * delta)
	var camera_basis: Basis = camera_view.global_transform.basis
	var camera_x = camera_basis.x 
	var camera_z = camera_basis.z
	
	camera_x.y = 0
	camera_x = camera_x.normalized()
	
	camera_z.y = 0
	camera_z = camera_z.normalized()
	
	#throw logic
	if Input.is_action_just_pressed("throw"):
		animation_tree['parameters/start_throw/blend_amount'] = 1
	elif Input.is_action_just_released("throw"):
		animation_tree['parameters/throwing/active'] = true
		animation_tree['parameters/start_throw/blend_amount'] = 0

	
	#jump logic
	airborne_time += delta
	if is_on_floor():
		if airborne_time > 0.5:
			land.play()
		airborne_time = 0
	if airborne_time > 1.2:
		print("fly")
	
	var on_air = airborne_time > MIN_AIRBORNE_TIME
	if not on_air and Input.is_action_just_pressed("jump"):
		velocity.y = JUMP_SPEED
		on_air = true
		airborne_time = MIN_AIRBORNE_TIME
		if motion.length() > 0.0001:
			animation_tree['parameters/transition/current'] = 1
		else:
			animation_tree['parameters/transition/current'] = 3
		
	if on_air:
		if (velocity.y > 0):
			if motion.length() > 0.0001:
				animation_tree['parameters/transition/current'] = 1
			else:
				animation_tree['parameters/transition/current'] = 3
		else:
			if motion.length() > 0.0001:
				animation_tree['parameters/transition/current'] = 2
			else:
				animation_tree['parameters/transition/current'] = 4
	
	
	if not on_air:
		var target = camera_x * motion.x + camera_z * motion.y
		if target.length() > 0.001:
			var q_from = orientation.basis.get_rotation_quat()
			var q_to = Transform().looking_at(target, Vector3.UP).basis.get_rotation_quat()
			orientation.basis = Basis(q_from.slerp(q_to, delta * MOTION_INTERPOLATE_SPEED))
		animation_tree['parameters/transition/current'] = 0
		animation_tree['parameters/walk/blend_position'] = motion
		root_motion = animation_tree.get_root_motion_transform()
	
	orientation *= root_motion
	var h_velocity = orientation.origin / delta
	velocity.x = h_velocity.x
	velocity.z = h_velocity.z
	velocity.y += gravity * delta
	velocity = move_and_slide(velocity, Vector3.UP)

	orientation.origin = Vector3() # Clear accumulated root motion displacement (was applied to speed).
	orientation = orientation.orthonormalized() # Orthonormalize orientation.

	player_model.global_transform.basis = orientation.basis
	if velocity.y < -1:
		emit_signal("ready_fly", velocity.y)
	
		
	
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		_camera_move(event.relative * CAMERA_MOUSE_ROTATION_SPEED)
		
	if event.is_action_pressed("ui_cancel"):
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
func _camera_move(move: Vector2) -> void:
	camera_root.rotate_y(-move.x)
	camera_root.orthonormalize()
	camera_x_rot += move.y
	camera_x_rot = clamp(camera_x_rot, deg2rad(-30), deg2rad(30))
	camera_base.rotation.x = camera_x_rot
	
	

