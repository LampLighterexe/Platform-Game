extends Node3D

class_name ProjectileConfig

var Damage = 0
var AttachToOwner = false
var HitboxShape = "Sphere"
var Model = null
var Gravity = 0
var PierceCount = 0
var DieOnHit = true
var DieOnTerrain = true
var ProjMaxLifetime = 10


func _init(dict={}):
	self.Damage = setVar(self.Damage,"Damage",dict)
	self.AttachToOwner = setVar(self.AttachToOwner,"AttachToOwner",dict)
	self.HitboxShape = setVar(self.HitboxShape,"HitboxShape",dict)
	self.Gravity = setVar(self.Gravity,"Gravity",dict)
	self.PierceCount = setVar(self.PierceCount,"PierceCount",dict)
	self.DieOnHit = setVar(self.DieOnHit,"DieOnHit",dict)
	self.DieOnTerrain = setVar(self.DieOnTerrain,"DieOnTerrain",dict)
	self.ProjMaxLifetime = setVar(self.ProjMaxLifetime,"ProjMaxLifetime",dict)
	
	if "Model" in dict:
		self.Model = load(dict["Model"])

func setVar(val,index,dict):
	if index in dict:
		return dict[index]
	return val
