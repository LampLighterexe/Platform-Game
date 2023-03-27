extends Node

class_name WeaponRegistry

var WeaponDict = {}

func _init():
	register("Hands",Weapon.new({
			"Name":"Hands",
			"AnimationSet":"hand",
			"FireAnim":"w_hand",
			"Model":null,
			"FireSpeed":1.0,
			"Projectile":"fist",
	}))
	register("dingus",Weapon.new({
			"Name":"dingus",
			"AnimationSet":"maxwell",
			"FireAnim":"w_maxwell",
			"Model":"res://models/exported/maxwell.res",
			"Projectile":"maxwell",
			"ProjXSpeed":8,
			"ProjYSpeed":2
	}))
	register("Freeze Ray",Weapon.new({
			"Name":"Freeze Ray",
			"AnimationSet":"pistol",
			"FireAnim":"w_freeze_ray",
			"Model":"res://models/exported/Freeze_Ray.res",
			"Projectile":"freeze_ray",
			"ProjXSpeed":16,
			"ProjYSpeed":0,
			"Automatic":true
	}))
		
	register("debug",Weapon.new({
			"Name":"debug",
			"AnimationSet":"pistol",
			"FireAnim":"w_freeze_ray",
			"Model":null,
			"Projectile":"sniper",
			"ProjXSpeed":0,
			"ProjYSpeed":0,
			"FireSpeed":0.25,
			"Automatic":true
	}))

func register(wepname, weapon):
	WeaponDict[wepname] = weapon
	
func getWeapon(wepname):
	return WeaponDict[wepname]
	
func getWeaponInstance(wepname):
	var source = WeaponDict[wepname]
	var clone = WeaponDict[wepname].duplicate()

	for property in source.get_property_list():
		var property_name = property["name"]
		clone.set(property_name, source.get(property_name))
	return clone
