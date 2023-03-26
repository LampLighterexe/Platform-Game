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
var	Hands=Weapon.new({
		"AnimationSet":"hand",
		"FireAnim":"w_hand",
		"Model":null,
		"Projectile":"maxwell",
	})
var	Maxwell=Weapon.new({
		"AnimationSet":"maxwell",
		"FireAnim":"w_maxwell",
		"Model":"res://models/exported/maxwell.res",
		"Projectile":"maxwell",
		"ProjXSpeed":8,
		"ProjYSpeed":2
	})
var	Pistol=Weapon.new({
		"AnimationSet":"pistol",
		"FireAnim":"w_freeze_ray",
		"Model":"res://models/exported/Freeze_Ray.res",
		"Projectile":"freeze_ray",
		"ProjXSpeed":10,
		"ProjYSpeed":0,
		"Automatic":true
	})
#var Hands = Weapon.new("hand","w_hand","maxwell",null,-1,-1,false)
#var Maxwell = Weapon.new("maxwell","w_maxwell","maxwell","res://models/exported/maxwell.res",1,1,false)
#var Pistol = Weapon.new("pistol","w_freeze_ray","freeze_ray","res://models/exported/Freeze_Ray.res",1,1,true)
#var Debug = Weapon.new("pistol","w_debug","maxwell","res://models/exported/maxwell.res",1,1,true)

var WeaponSlot = 0
var LastWeaponSlot = 0
var CurrentState = "idle"
var LastState = "idle"
var Weapons = [Hands,Maxwell,Pistol]
var CurrentWeapon = null
var ProjFact = ProjectileFactory.new()
func FireCurrentWeapon():
	#print("fired weapon! " + CurrentWeapon.weaponname)
	if not CurrentState == "fire":
		return
	var newproj = preload("res://Projectile.tscn").instantiate()
	var projconfig = ProjFact.getProjectile(CurrentWeapon.Projectile)
	newproj.initialize(
		Camera.global_transform,
		Camera.get_global_transform().basis.z*-CurrentWeapon.ProjXSpeed+Vector3(0,CurrentWeapon.ProjYSpeed,0),
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
	if CurrentState == "idle" and CurrentWeapon.Automatic and CurrentWeapon.CanFire() and Input.is_action_pressed("autofire"):
		CurrentState = "fire"
	if ViewModelAnim:
		#print(ViewModelAnim.current_animation)
		if CurrentState == "idle":
			if not ViewModelAnim.is_playing() and ViewModelAnim.current_animation != getAnim(CurrentWeapon,CurrentState):
				ViewModelAnim.play(getAnim(CurrentWeapon,CurrentState))
				
		if CurrentState == "fire":
			if LastState != "fire":
				ViewModelAnim.stop()
				WeaponFire.play(CurrentWeapon.FireAnim)
				ViewModelAnim.play(getAnim(CurrentWeapon,CurrentState))
			if not ViewModelAnim.is_playing():
				CurrentState = "idle"

		if Weapons[WeaponSlot].Model:
			ViewModelWeapon.mesh = Weapons[WeaponSlot].Model
			ViewModelWeapon.visible = true
		else:
			ViewModelWeapon.visible = false
	LastState = CurrentState


func getAnim(w,s):
	return "Armature|"+w.AnimationSet+"_"+s
