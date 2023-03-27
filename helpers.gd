extends Node

func CreateProjectile(pos,velocity,projconfig,origin,team):
	var newproj = preload("res://Projectile.tscn").instantiate()
	newproj.initialize(
		pos,
		velocity,
		Registry.ProjFact.getProjectile(projconfig),
		origin,
		team
	)
	add_child(newproj)

func createParticles(p):
	var particles = p.duplicate()
	particles.set_script(preload("res://PlayParticle.gd"))
	particles.global_transform = p.global_transform
	add_child(particles)
