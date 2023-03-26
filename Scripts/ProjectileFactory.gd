extends Node

class_name ProjectileFactory

var ProjectileDict = {}

func _init():
	register("maxwell",ProjectileConfig.new({
		"Damage":15,
		"Model":"res://models/exported/maxwell.res",
		"Gravity":0.5,
		"Size":Vector3(2,2,2),
		"PierceCount":5,
		"DieOnTerrain":false,
	}))
	register("freeze_ray",ProjectileConfig.new({
		"Damage":1,
		"Model":"res://models/exported/ice_ball.res",
		"Gravity":0,
		"AttachOffset":Vector3(-0.3,0,0.5),
		"Size":0.5,
		"ForceDir":true,
		"ProjMaxLifetime":1
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

func register(projname, projconfig):
	ProjectileDict[projname] = projconfig
	
func getProjectile(projname):
	return ProjectileDict[projname]
