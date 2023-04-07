extends Node3D

@onready var AnimTree = $AnimationTree
@onready var AnimPlayer = $AnimationPlayer
@onready var WeaponHolder = $WeaponHolder
@onready var WeaponModel = $WeaponHolder/justdont
@onready var WeaponStateMachine = AnimTree["parameters/Weapon/playback"]

var lastweapon = null
var laststate = ""
var character = "" 
var RequiresReset = false
var lookblend = 0.5
var Skeleton = null
var Sync = true

var weapon : Weapon:
	get:
		return weapon
	set(v):
		weapon = v

		#if lastweapon and not (weapon.Name == lastweapon.Name):
		
var weaponstate := "":
	get:
		return weaponstate
	set(v):
		weaponstate = v

var motion := 0.0:
	get:
		return motion
	set(v):
		motion = v
		if Sync and is_multiplayer_authority():
			syncMotion.rpc(motion)

@rpc
func syncMotion(m):
	motion = m

@rpc
func syncWeapon(m):
	weapon = Registry.WeapFact.getWeapon(m)

@rpc
func syncWeaponState(m):
	weaponstate = m

	
func checkVaild(s):
	return not (AnimPlayer.get_animation(s) == null)

func setWeaponAnim(anim,key):
	if checkVaild(anim):
		return anim
	else:
		return "PlayerLibrary/w_placeholder_"+key
func resetWeaponAnims():
	if weapon:
		AnimTree.tree_root.get_node("WeaponAnimIdle").animation = setWeaponAnim(getAnim(weapon,"idle"),"idle")

func _ready():
	if Skeleton:
		WeaponHolder.set_external_skeleton(Skeleton)
		WeaponHolder.bone_name = "Weapon.R"
		Skeleton.find_bone("Root")
	pass
	
func _process(delta):
	
	AnimTree["parameters/updown_look/blend_amount"] = lookblend
	AnimTree["parameters/armupdown_look/blend_amount"] = lookblend
	AnimTree["parameters/add_motion/add_amount"] = motion
	if motion == 0:
		AnimTree["parameters/RestartWalk/seek_request"] = 0
	if weapon:
		if weapon != lastweapon:
			resetWeaponAnims()
			AnimTree["parameters/OneShot/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_ABORT
			laststate = ""
			WeaponModel.mesh = weapon.Model
			WeaponHolder.bone_name = "Weapon.R"
			if is_multiplayer_authority() and Sync == true:
				match weapon.HideArms:
					"both":
						Skeleton.set_bone_pose_scale(Skeleton.find_bone("RightUpperArm"),Vector3(0.0,0.0,0.0))
						Skeleton.set_bone_pose_scale(Skeleton.find_bone("LeftUpperArm"),Vector3(0.0,0.0,0.0))
					"right":
						Skeleton.set_bone_pose_scale(Skeleton.find_bone("RightUpperArm"),Vector3(0.0,0.0,0.0))
						Skeleton.set_bone_pose_scale(Skeleton.find_bone("LeftUpperArm"),Vector3(1.0,1.0,1.0))
					"left":
						Skeleton.set_bone_pose_scale(Skeleton.find_bone("RightUpperArm"),Vector3(1.0,1.0,1.0))
						Skeleton.set_bone_pose_scale(Skeleton.find_bone("LeftUpperArm"),Vector3(0.0,0.0,0.0))
					"none":
						Skeleton.set_bone_pose_scale(Skeleton.find_bone("RightUpperArm"),Vector3(1.0,1.0,1.0))
						Skeleton.set_bone_pose_scale(Skeleton.find_bone("LeftUpperArm"),Vector3(1.0,1.0,1.0))
	if weapon and laststate != weaponstate:
		AnimTree.tree_root.get_node("WeaponAnim").animation = getAnim(weapon,weaponstate)
		var animspeed = 1
		match weaponstate:
			"fire":
				animspeed = weapon.FireSpeed
			"equip":
				animspeed = weapon.EquipSpeed
			"reload":
				animspeed = weapon.ReloadSpeed
		AnimTree["parameters/OneShot/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
		AnimTree["parameters/WeaponSpeed/scale"] = animspeed
	if lastweapon != weapon or RequiresReset:
		if Sync and is_multiplayer_authority():
			if RequiresReset:
				print("test")
			syncWeapon.rpc(weapon.Name)
			RequiresReset = false
	lastweapon = weapon
	laststate = weaponstate
func getAnim(w,s):
	return "PlayerLibrary/w_"+w.AnimationSet+"_"+s

	#if not laststate == weaponstate and not weaponstate == "":
	#	WeaponStateMachine.travel(weaponstate)
		
	
	#print(AnimTree.tree_root.get_node("weapon_anim_idle").animation)
	
	#AnimTree.tree_root.get_node("weapon_anim_idle").animation = "PlayerLibrary/w_hand"
	#if is_multiplayer_authority():
		#Skeleton.set_bone_pose_position(Skeleton.find_bone("Root"),Vector3(0.0,0.0,0.0))
		#Skeleton.motion_scale = 0
