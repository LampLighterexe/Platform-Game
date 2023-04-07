extends Node

var ProjectileObject = preload("res://Scenes/Projectile.tscn")

func createProjectile(pos,velocity,projconfig,origin,team,auth,showdmg=false):
	var newproj = ProjectileObject.instantiate()
	newproj.initialize(
		pos,
		velocity,
		Registry.ProjFact.getProjectile(projconfig),
		origin,
		team,
		auth,
		showdmg
	)
	add_child(newproj)

func createParticles(p,obj=null):
	var particles = p.duplicate()
	particles.set_script(preload("res://Scripts/PlayParticle.gd"))
	if obj:
		particles.transform = Transform3D()
		obj.add_child(particles)
	else:
		particles.global_transform = p.global_transform
		add_child(particles)
	
func createSound(s,s2,obj=null):
	var sound = s.duplicate()
	sound.set_script(preload("res://Scripts/PlaySound.gd"))
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

@rpc("any_peer","call_local")
func networkKnockback(e,kb,kbpos):
	if EntityManager.getEntity(e):
		EntityManager.getEntity(e).takeKnockback.rpc(kb,kbpos)

func dealKnockback(eID,kb,kbpos):
	networkKnockback.rpc_id(1,eID,kb,kbpos)
