extends Node3D

class_name ProjectileConfig

var Damage = 0
var AttachToOwner = false
var HitboxShape = "Sphere"
var Model = null
var Gravity = 0
var PierceCount = 1
var DieOnHit = true
var DieOnTerrain = true
var ProjMaxLifetime = 10
var PhysicsEnabled = true
var AttachOffset = Vector3(0,0,0)
var Size = 1.0
var ForceDir = false

func _init(dict={}):
	self.Damage = setVar(self.Damage,"Damage",dict)
	self.AttachToOwner = setVar(self.AttachToOwner,"AttachToOwner",dict)
	self.HitboxShape = setVar(self.HitboxShape,"HitboxShape",dict)
	self.Gravity = setVar(self.Gravity,"Gravity",dict)
	self.PierceCount = setVar(self.PierceCount,"PierceCount",dict)
	self.DieOnHit = setVar(self.DieOnHit,"DieOnHit",dict)
	self.DieOnTerrain = setVar(self.DieOnTerrain,"DieOnTerrain",dict)
	self.ProjMaxLifetime = setVar(self.ProjMaxLifetime,"ProjMaxLifetime",dict)
	self.PhysicsEnabled = setVar(self.PhysicsEnabled,"PhysicsEnabled",dict)
	self.AttachOffset = setVar(self.AttachOffset,"AttachOffset",dict)
	self.Size = setVar(self.Size,"Size",dict)
	self.ForceDir = setVar(self.ForceDir,"ForceDir",dict)
	if "Model" in dict and dict["Model"]:
		self.Model = load(dict["Model"])

func setVar(val,index,dict):
	if index in dict:
		return dict[index]
	return val
