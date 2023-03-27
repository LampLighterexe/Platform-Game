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
@onready var ViewModelWeapon := $"../Smoothing/Neck/Camera3D/view_arms/Armature/Skeleton3D/BoneAttachment3D/WeaponModel"
@onready var WeaponFire := $"../WeaponFire"
@onready var Aim := $"../Aim"
@onready var Player := $".."

var WeaponSlot = 0
var LastWeaponSlot = 0
var CurrentState = "idle"
var LastState = "idle"
var CurrentWeapon = null
var Weapons = []
func _ready():
	Weapons = [Registry.WeapFact.getWeaponInstance("Hands"),
			Registry.WeapFact.getWeaponInstance("dingus"),
			Registry.WeapFact.getWeaponInstance("Freeze Ray"),
			Registry.WeapFact.getWeaponInstance("debug")
	]

func FireCurrentWeapon():
	#print("fired weapon! " + CurrentWeapon.weaponname)
	if not CurrentState == "fire":
		return
	Helpers.CreateProjectile(
		Aim.global_transform,
		(Player.velocity*0.5)+Aim.get_global_transform().basis.z*-CurrentWeapon.ProjXSpeed+Vector3(0,CurrentWeapon.ProjYSpeed,0),
		CurrentWeapon.Projectile,
		Aim,
		Player.Team
	)
	
func ChangeWeaponSlot(dir):
	WeaponSlot += dir
	if WeaponSlot < 0:
		WeaponSlot = len(Weapons)-1
	if WeaponSlot > len(Weapons)-1:
		WeaponSlot = 0
		#print(dir,WeaponSlot,len(Weapons))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	CurrentWeapon = Weapons[WeaponSlot]
	if not CurrentWeapon:
		return
	
	if LastWeaponSlot!= WeaponSlot:
		WeaponFire.stop()
		ViewModelAnim.stop()
		CurrentState = "idle"
	LastWeaponSlot = WeaponSlot
	
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
				WeaponFire.play(CurrentWeapon.FireAnim,0.0,CurrentWeapon.FireSpeed)
				ViewModelAnim.play(getAnim(CurrentWeapon,CurrentState),0.1,CurrentWeapon.FireSpeed)
			if not ViewModelAnim.is_playing():
				CurrentState = "idle"

		if Weapons[WeaponSlot].Model:
			ViewModelWeapon.mesh = Weapons[WeaponSlot].Model
			ViewModelWeapon.visible = true
		else:
			ViewModelWeapon.visible = false
	LastState = CurrentState


func getAnim(w,s):
	return w.AnimationSet+"_"+s
