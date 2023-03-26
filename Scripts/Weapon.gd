extends Node

class_name Weapon

var AnimationSet = ""
var FireAnim = "w_none"
var Model = null
var Projectile = "none"
var Clip = -1
var MaxAmmo = -1
var Automatic = false
var ProjXSpeed = 1
var ProjYSpeed = 0

func _init(dict={}):
	self.AnimationSet = setVar(self.AnimationSet,"AnimationSet",dict)
	self.FireAnim = setVar(self.FireAnim,"FireAnim",dict)
	self.Projectile = setVar(self.Projectile,"Projectile",dict)
	self.Clip = setVar(self.Clip,"Clip",dict)
	self.MaxAmmo = setVar(self.MaxAmmo,"MaxAmmo",dict)
	self.Automatic = setVar(self.Automatic,"Automatic",dict)
	self.ProjXSpeed = setVar(self.ProjXSpeed,"ProjXSpeed",dict)
	self.ProjYSpeed = setVar(self.ProjYSpeed,"ProjYSpeed",dict)
	
	if "Model" in dict and dict["Model"]:
		self.Model = load(dict["Model"])

func setVar(val,index,dict):
	if index in dict:
		return dict[index]
	return val

func RefillClip():
	self.Clip = self.MaxAmmo
	
func CanFire():
	if self.Clip == -1:
		return true
	return self.Clip > 0
