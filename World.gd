extends Node
@onready var player = $Player

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("debugkey1"):
		var newobj = load("res://Enemy.tscn").instantiate()
		newobj.position = Vector3(0,2,0)
		add_child(newobj)

func _physics_process(delta):
	if player.global_transform.origin.y < -25:
		player.global_transform.origin.y += 50
		player.velocity.y = 0
	get_tree().call_group("enemies","update_target_location", player.global_transform.origin)
