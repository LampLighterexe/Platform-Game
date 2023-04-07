extends Node

class_name Weapon

var Name = ""
var AnimationSet = ""
var FireAnim = "w_none"
var Model = null
var Projectile = "none"
var Clip = -1
var ClipMax = -1
var MaxAmmo = -1
var Automatic = false
var ProjXSpeed = 1
var ProjYSpeed = 0
var FireSpeed = 1
var ReloadSpeed = 1
var EquipSpeed = 1
var ReloadSound = null
var FireSound = null
var HideArms = "none"

func _init(dict={}):
	for entry in dict:
		self[entry] = dict[entry]
	ClipMax = Clip

func RefillClip():
	if not self.MaxAmmo == -1:
		self.MaxAmmo -= self.ClipMax-self.Clip
		self.Clip = self.ClipMax
		if MaxAmmo < 0:
			self.Clip += self.MaxAmmo
			self.MaxAmmo = 0
		return
	self.Clip = self.ClipMax
	
	
func CanFire():
	if self.Clip == -1:
		return true
	return self.Clip > 0

func CanReload():
	return self.Clip < self.ClipMax and (self.MaxAmmo > 0 or self.MaxAmmo == -1)

func RemoveClip(ammo):
	if self.Clip == -1:
		return
	self.Clip -= ammo
	if self.Clip < 0:
		self.Clip = 0
