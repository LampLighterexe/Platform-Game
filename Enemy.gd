extends CharacterBody3D

var SPEED = 3
var healthMax = 20
var health = healthMax

@onready var nav_agent = $NavigationAgent3D

func _process(delta):
	if health < 1:
		queue_free()

func _physics_process(delta):
	var current_location = global_transform.origin
	var next_location = nav_agent.get_next_path_position()
	var new_velocity = (next_location-current_location).normalized() * SPEED
	
	nav_agent.set_velocity(new_velocity)
	

	
func update_target_location(target_location):
	nav_agent.set_target_position(target_location)


func _on_navigation_agent_3d_target_reached():
	pass # Replace with function body.

func _on_navigation_agent_3d_velocity_computed(safe_velocity):
	velocity = velocity.move_toward(safe_velocity,0.25)
	move_and_slide()

func takeDamage(damage):
	health -= damage
	createHitParticles($CPUParticles3D)
	pass
	
func createHitParticles(p):
	var root = get_tree().root
	var main_scene = root.get_child(root.get_child_count() - 1)
	var particles = p.duplicate()
	particles.set_script(preload("res://PlayParticle.gd"))
	particles.global_transform = p.global_transform
	main_scene.add_child(particles)
	
