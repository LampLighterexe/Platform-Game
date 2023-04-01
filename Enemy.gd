extends CharacterBody3D

var SPEED = 3
var healthMax = 20
var health = healthMax

var AIstate = "idle"

var Team = "enemy"

@onready var nav_agent = $NavigationAgent3D
@onready var Aim = $Aim

func _process(delta):
	if not isAlive():
		queue_free()

func _physics_process(delta):
	if not $AnimationPlayer.is_playing():
		var current_location = global_transform.origin
		var next_location = nav_agent.get_next_path_position()
		var new_velocity = (next_location-current_location).normalized() * SPEED
		
		nav_agent.set_velocity(new_velocity)
	

func sort_ascending(a, b):
	if a[1] < b[1]:
		return true
	return false


func update_target_location(target_location):
	nav_agent.set_target_position(target_location)

func update_target_list(targets):
	
	var list = []
	for i in targets:
		list.append([i,i.global_position.distance_to(global_position)])
		
	list.sort_custom(sort_ascending)
	update_target_location(list[0][0].global_transform.origin)

func _on_navigation_agent_3d_target_reached():
	$AnimationPlayer.play("attack")
	pass # Replace with function body.

func _on_navigation_agent_3d_velocity_computed(safe_velocity):
	velocity = velocity.move_toward(safe_velocity,0.25)
	move_and_slide()

func attack():
	Helpers.createProjectile(
		global_transform,
		Vector3(0,0,0),
		"mobattack",
		Aim,
		self.Team,
		get_multiplayer_authority()
	)

@rpc("any_peer", "call_local")
func takeDamage(damage):
	health -= damage
	Helpers.createParticles($CPUParticles3D)
	pass
	
func isAlive():
	return health > 0
