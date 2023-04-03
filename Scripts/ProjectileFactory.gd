extends Node

class_name ProjectileFactory

var ProjectileDict = {}

func _init():
	register("default",ProjectileConfig.new({}))
	register("maxwell",ProjectileConfig.new({
		"Damage":15,
		"Model":preload("res://models/exported/maxwell.res"),
		"Gravity":0.5,
		"Size":2,
		"PierceCount":5,
		"DieOnTerrain":false,
		"HitSound":preload("res://Sounds/cat.mp3")
	}))
	register("freeze_ray",ProjectileConfig.new({
		"Damage":3,
		"Model":preload("res://models/exported/ice_ball.res"),
		"Gravity":0,
		"AttachOffset":Vector3(-0.3,0,0.5),
		"Size":0.5,
		"ForceDir":true,
		"ProjMaxLifetime":1,
		"DeathProjectile":"explosion"
	}))
	register("fist",ProjectileConfig.new({
		"Damage":10,
		"Model":null,
		"HitboxShape":"Cube",
		"Gravity":0,
		"AttachToOwner":true,
		"PhysicsEnabled":false,
		"AttachOffset":Vector3(0,0,1),
		"Size":Vector3(1.5,1,3),
		"ProjMaxLifetime":0.1
	}))
	register("sniper",ProjectileConfig.new({
		"Damage":10,
		"Model":null,
		"HitboxShape":"Cube",
		"Gravity":0,
		"AttachToOwner":true,
		"PhysicsEnabled":false,
		"AttachOffset":Vector3(0,0,15),
		"Size":Vector3(0.05,0.05,30),
		"PierceCount":5,
		"ProjMaxLifetime":0.033
	}))
	register("debug",ProjectileConfig.new({
		"Damage":10,
		"Model":null,
		"Gravity":0,
		"AttachToOwner":false,
		"DieOnTerrain":false,
		"PhysicsEnabled":false,
		"AttachOffset":Vector3(0,0,0.5),
		"Size":1
	}))
	register("explosion",ProjectileConfig.new({
		"Damage":5,
		"Model":null,
		"Gravity":0,
		"AttachToOwner":false,
		"DieOnTerrain":false,
		"PhysicsEnabled":false,
		"AttachOffset":Vector3(0,0,0),
		"Size":2,
		"PierceCount":10,
		"ProjMaxLifetime":0.033
	}))
	register("mobattack",ProjectileConfig.new({
		"Damage":20,
		"Model":null,
		"Gravity":0,
		"AttachToOwner":false,
		"DieOnTerrain":false,
		"PhysicsEnabled":false,
		"AttachOffset":Vector3(0,0,0),
		"Size":4,
		"PierceCount":9999,
		"ProjMaxLifetime":0.033
	}))

func register(projname, projconfig):
	ProjectileDict[projname] = projconfig
	
func getProjectile(projname):
	if projname in ProjectileDict:
		return ProjectileDict[projname]
	push_warning("Could not find ",projname," in registry!")
	return ProjectileDict["default"]
