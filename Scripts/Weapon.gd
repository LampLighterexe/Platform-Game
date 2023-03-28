extends Node

class_name Weapon

var Name = ""
var AnimationSet = ""
var FireAnim = "w_none"
var Model = null
var Projectile = "none"
var Clip = -1
var MaxAmmo = -1
var Automatic = false
var ProjXSpeed = 1
var ProjYSpeed = 0
var FireSpeed = 1
var ReloadSound = null
var FireSound = null

func _init(dict={}):
	for entry in dict:
		self[entry] = dict[entry]
	
	if "Model" in dict and dict["Model"]:
		self.Model = load(dict["Model"])


func RefillClip():
	self.Clip = self.MaxAmmo
	
func CanFire():
	if self.Clip == -1:
		return true
	return self.Clip > 0

func CanReload():
	return self.Clip < self.MaxAmmo

func RemoveClip(ammo):
	if self.Clip == -1:
		return
	self.Clip -= ammo
	if self.Clip < 0:
		self.Clip = 0
