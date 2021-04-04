extends RigidBody

const CAMERA_MOUSE_ROTATION_SPEED = 0.001

onready var camera_root = $camera
onready var camera_base = $camera/camera_base

var camera_x_rot = 0.0

func _physics_process(delta: float) -> void:
	
	if Input.is_action_pressed("front"):
		self.translation.z -= 2 * delta
	if Input.is_action_pressed("back"):
		self.translation.z += 2 * delta
	if Input.is_action_pressed("left"):
		self.translation.x -= 2 * delta
	if Input.is_action_pressed("right"):
		self.translation.x += 2 * delta

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		_camera_move(event.relative * CAMERA_MOUSE_ROTATION_SPEED)

func _camera_move(move: Vector2) -> void:
	camera_root.rotate_y(-move.x)
	camera_root.orthonormalize()
	camera_x_rot += move.y
	camera_x_rot = clamp(camera_x_rot, deg2rad(-30), deg2rad(30))
	camera_base.rotation.x = camera_x_rot
