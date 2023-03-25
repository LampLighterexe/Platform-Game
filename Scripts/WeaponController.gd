extends Node



func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		if event.button_index == 1:
			if Weapons[WeaponSlot].CanFire() and CurrentState == "idle":
				CurrentState = "fire"
		if event.button_index == 4:
			ChangeWeaponSlot(-1)
			
		if event.button_index == 5:
			ChangeWeaponSlot(1)


@onready var ViewModelAnim := $"../Smoothing/Neck/Camera3D/view_arms/AnimationPlayer"
@onready var ViewModelWeapon := $"../Smoothing/Neck/Camera3D/view_arms/RootNode/Armature/Skeleton3D/BoneAttachment3D/WeaponModel/RootNode/dingus"
@onready var WeaponFire := $"../WeaponFire"
@onready var Camera := $"../Smoothing/Neck/Camera3D"
var Hands = Weapon.new("hand","w_hand","maxwell",null,-1,-1,false)
var Maxwell = Weapon.new("maxwell","w_maxwell","maxwell","res://models/exported/maxwell.res",1,1,false)
var Pistol = Weapon.new("pistol","w_freeze_ray","maxwell","res://models/exported/Freeze_Ray.res",1,1,true)
var Debug = Weapon.new("pistol","w_debug","maxwell","res://models/exported/maxwell.res",1,1,true)

var WeaponSlot = 0
var LastWeaponSlot = 0
var CurrentState = "idle"
var LastState = "idle"
var Weapons = [Hands,Maxwell,Pistol,Debug]
var CurrentWeapon = null
var ProjFact = ProjectileFactory.new()
func FireCurrentWeapon():
	#print("fired weapon! " + CurrentWeapon.weaponname)
	var newproj = preload("res://Projectile.tscn").instantiate()
	var projconfig = ProjFact.getProjectile(CurrentWeapon.projectile)
	newproj.initialize(
		Camera.global_transform,
		Camera.get_global_transform().basis.z*-8+Vector3(0,2,0),
		projconfig
	)
	add_child(newproj)

	pass

func ChangeWeaponSlot(dir):
	WeaponSlot += dir
	if WeaponSlot < 0:
		WeaponSlot = len(Weapons)-1
	if WeaponSlot > len(Weapons)-1:
		WeaponSlot = 0
		#print(dir,WeaponSlot,len(Weapons))

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if LastWeaponSlot!= WeaponSlot:
		WeaponFire.stop()
		ViewModelAnim.stop()
		CurrentState = "idle"
	LastWeaponSlot = WeaponSlot
	CurrentWeapon = Weapons[WeaponSlot]
	if CurrentState == "idle" and CurrentWeapon.automatic and CurrentWeapon.CanFire() and Input.is_action_pressed("autofire"):
		CurrentState = "fire"
	if ViewModelAnim:
		#print(ViewModelAnim.current_animation)
		if CurrentState == "idle":
			if not ViewModelAnim.is_playing() and ViewModelAnim.current_animation != getAnim(CurrentWeapon,CurrentState):
				ViewModelAnim.play(getAnim(CurrentWeapon,CurrentState))
				
		if CurrentState == "fire":
			if LastState != "fire":
				ViewModelAnim.stop()
				WeaponFire.play(CurrentWeapon.weaponname)
				ViewModelAnim.play(getAnim(CurrentWeapon,CurrentState))
			if not ViewModelAnim.is_playing():
				CurrentState = "idle"

		if Weapons[WeaponSlot].model:
			ViewModelWeapon.mesh = Weapons[WeaponSlot].model
			ViewModelWeapon.visible = true
		else:
			ViewModelWeapon.visible = false
	LastState = CurrentState


func getAnim(w,s):
	return "Armature|"+w.animtype+"_"+s
