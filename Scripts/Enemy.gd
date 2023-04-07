extends CharacterBody3D

var SPEED = 8
var Accel = 0.08
var AirAccel = 0.02
var healthMax = 20
var health = healthMax
var velocityimmidiate = Vector3.ZERO
var AIstate = "idle"

var Team = "enemy"

var points_given = 100

signal GivePoints

@onready var nav_agent = $NavigationAgent3D
@onready var model_rot = $Smoothing/spider
@onready var Aim = $Aim

func _process(delta):
	if not isAlive():
		GivePoints.emit(points_given)
		queue_free()

func _physics_process(delta):
	if position.y < -25:
		health = 0
	if not $AnimationPlayer.is_playing():
		var current_location = global_transform.origin
		var next_location = nav_agent.get_next_path_position()
		var new_velocity = (next_location-current_location).normalized() * SPEED
		if is_multiplayer_authority():
			model_rot.look_at(Vector3(nav_agent.target_position.x,current_location.y,nav_agent.target_position.z))
			nav_agent.set_velocity(new_velocity)
			velocity.y += -9.8*delta
	else:
		nav_agent.set_velocity(Vector3.ZERO)
		velocityimmidiate += -velocity*0.2
	if is_multiplayer_authority():
		move_and_slide()

func sort_ascending(a, b):
	if a[1] < b[1]:
		return true
	return false


func update_target_location(target_location):
	nav_agent.set_target_position(target_location)

func update_target_list(targets):
	
	var list = []
	for i in targets:
		if i.Team == "player" and i.isAlive():
			list.append([i,i.global_position.distance_to(global_position)])
		
	list.sort_custom(sort_ascending)
	if list.size() > 0:
		update_target_location(list[0][0].global_transform.origin)
	else:
		update_target_location(self.global_transform.origin)

func _on_navigation_agent_3d_target_reached():
	$AnimationPlayer.play("attack")

func _on_navigation_agent_3d_velocity_computed(safe_velocity):
	var y_vel = velocity.y
	velocity = velocity.move_toward(safe_velocity*Vector3(1,0,1),SPEED*(Accel if is_on_floor() else AirAccel))
	velocity.y = y_vel
	velocity += velocityimmidiate
	velocityimmidiate = Vector3.ZERO
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

@rpc("any_peer", "call_local")
func takeKnockback(kb,kbpos):
	velocityimmidiate += ((global_position-kbpos)*Vector3(1,0,1)).normalized()*kb
	velocity.y += sqrt(1+kb*2)

func isAlive():
	return health > 0
