extends Node

func createProjectile(pos,velocity,projconfig,origin,team,auth):
	var newproj = preload("res://Projectile.tscn").instantiate()
	newproj.initialize(
		pos,
		velocity,
		Registry.ProjFact.getProjectile(projconfig),
		origin,
		team,
		auth
	)
	add_child(newproj)

func createParticles(p,):
	var particles = p.duplicate()
	particles.set_script(preload("res://PlayParticle.gd"))
	particles.global_transform = p.global_transform
	add_child(particles)
	
func createSound(s,s2,obj=null):
	var sound = s.duplicate()
	sound.set_script(preload("res://PlaySound.gd"))
	sound.stream = s2
	if obj:
		sound.transform = Transform3D()
		obj.add_child(sound)
	else:
		sound.global_transform = s.global_transform
		add_child(sound)

@rpc("any_peer","call_local")
func networkDamage(e,d):
	if EntityManager.getEntity(e):
		EntityManager.getEntity(e).takeDamage.rpc(d)
	

func dealDamage(eID,damage):
	networkDamage.rpc_id(1,eID,damage)
