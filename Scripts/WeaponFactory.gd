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
			"HideArms":"right"
	}))
	register("dingus",Weapon.new({
			"Name":"dingus",
			"AnimationSet":"maxwell",
			"FireAnim":"w_maxwell",
			"Model":preload("res://models/exported/maxwell.res"),
			"Projectile":"maxwell",
			"Clip":6,
			"MaxAmmo":12,
			"ReloadSound":preload("res://Sounds/maxwell_reload.mp3"),
			"ProjXSpeed":8,
			"ProjYSpeed":2,
			"HideArms":"both"
	}))
	register("Freeze Ray",Weapon.new({
			"Name":"Freeze Ray",
			"AnimationSet":"pistol",
			"FireAnim":"w_freeze_ray",
			"Model":preload("res://models/exported/Freeze_Ray.res"),
			"Projectile":"freeze_ray",
			"Clip":10,
			"MaxAmmo":-1,
			"ProjXSpeed":16,
			"ProjYSpeed":0,
			"Automatic":true,
			"HideArms":"both"
	}))
	register("Rocket Launcher",Weapon.new({
			"Name":"Rocket Launcher",
			"AnimationSet":"pistol",
			"FireAnim":"w_freeze_ray",
			"Model":preload("res://models/exported/rocketlauncher.res"),
			"Projectile":"rocket",
			"Clip":4,
			"MaxAmmo":60,
			"FireSpeed":0.22,
			"ReloadSpeed":0.60,
			"ProjXSpeed":24,
			"ProjYSpeed":0,
			"FireSound":preload("res://Sounds/rocket_shoot.wav"),
			"Automatic":true,
			"HideArms":"both"
	}))
	register("debug",Weapon.new({
			"Name":"debug",
			"AnimationSet":"pistol",
			"FireAnim":"w_freeze_ray",
			"Model":null,
			"Projectile":"sniper",
			"ProjXSpeed":0,
			"ProjYSpeed":0,
			"Clip":4,
			"MaxAmmo":20,
			"FireSpeed":0.25,
			"ReloadSpeed":0.5,
			"Automatic":true,
			"HideArms":"both"
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
