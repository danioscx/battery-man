extends Spatial

onready var player = $player/player
onready var parent = get_node("chain/RigidBody")

func _physics_process(delta: float) -> void:
	if Input.is_key_pressed(KEY_P):
		self.remove_child(player)
		parent.add_child(player)
		player.set_owner(parent)
		pass
	$node/Label.text = str(Performance.get_monitor(Performance.TIME_FPS))
	
func _on_player_ready_fly(status) -> void:
	pass
	
