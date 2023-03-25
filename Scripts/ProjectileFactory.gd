extends Node

class_name ProjectileFactory

var ProjectileDict = {}

func _init():
	register("maxwell",ProjectileConfig.new({
		"Damage":1,
		"Model":"res://models/exported/maxwell.res",
		"Gravity":0.5
	}
	))
	
	pass

func register(projname, projconfig):
	ProjectileDict[projname] = projconfig
	
func getProjectile(projname):
	return ProjectileDict[projname]
