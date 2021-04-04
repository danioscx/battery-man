extends Spatial

onready var box = $box
onready var key = $Key
onready var rigid = $RigidBody

func _ready() -> void:
	key.set_node_a("../box")
	print(key.get_node_b())
	print(rigid.translation.y)

func _physics_process(delta: float) -> void:
	if rigid.translation.y < -1.5:
		key.set_node_b("../RigidBody")
