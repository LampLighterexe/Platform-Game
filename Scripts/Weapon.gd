extends Node

class_name Weapon

var animtype = ""
var weaponname = "w_none"
var model = "none"
var projectile = "none"
var clip = -1
var maxammo = -1
var automatic = false

func _init(animtype,weaponname,projectile,model,clip,maxammo,automatic):
	self.animtype = animtype
	self.weaponname = weaponname
	self.projectile = projectile
	if model:
		self.model = load(model)
	else:
		self.model = model
	self.clip = clip
	self.maxammo = maxammo
	self.automatic = automatic

func RefillClip():
	self.clip = self.maxammo
	
func CanFire():
	if self.clip == -1:
		return true
	return self.clip > 0
