extends CharacterBody3D

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
var HitboxSize = 1.0
var ForceDir = false
var DeathProjectile = null
var HitSound = null
var DeathSound = null
var SpawnSound = null
var Knockback = null
var SelfDamage = false
var RepeatDamage = false
var RepeatDamageInterval = 0.5
var KnockbackType = "setY"
var SetVars = {}

func _init(dict={}):
	for entry in dict:
		self[entry] = dict[entry]
	SetVars = dict
	#if "Model" in dict and dict["Model"]:
	#	self.Model = load(dict["Model"])
