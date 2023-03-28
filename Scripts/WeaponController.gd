extends Node



func _unhandled_input(event: InputEvent) -> void:
	if not is_multiplayer_authority(): return
	if event is InputEventMouseButton and event.is_pressed():
		if event.button_index == 1:
			if CurrentWeapon.CanFire() and CurrentState == "idle":
				setCurrentState("fire")
			elif CurrentState == "idle":
				setCurrentState("reload")
		if event.button_index == 4:
			ChangeWeaponSlot(-1)
			
		if event.button_index == 5:
			ChangeWeaponSlot(1)
	if Input.is_action_just_pressed("reload") and CurrentState == "idle" and CurrentWeapon.CanReload():
		setCurrentState("reload")

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
	if not CurrentState == "fire":
		return
	Helpers.createSound($"../PlayerSound",CurrentWeapon.FireSound,Aim)
	CurrentWeapon.RemoveClip(1)
	
	if not is_multiplayer_authority(): return
	networkCreateProjectile.rpc(get_multiplayer_authority())
	
#	Helpers.createProjectile(
#		Aim.global_transform,
#		(Player.velocity*0.5)+Aim.get_global_transform().basis.z*-CurrentWeapon.ProjXSpeed+Vector3(0,CurrentWeapon.ProjYSpeed,0),
#		CurrentWeapon.Projectile,
#		Aim,
#		Player.Team,
#		auth
#	)



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	CurrentWeapon = Weapons[WeaponSlot]
	if not CurrentWeapon:
		return

	if LastWeaponSlot!= WeaponSlot:
		WeaponFire.stop()
		ViewModelAnim.stop()
		setCurrentState("idle")
		for n in Aim.get_children():
			if n is AudioStreamPlayer3D:
				Aim.remove_child(n)
				n.queue_free()
	LastWeaponSlot = WeaponSlot

	if is_multiplayer_authority() and Input.is_action_pressed("autofire") and CurrentState == "idle" and CurrentWeapon.Automatic and CurrentWeapon.CanFire():
		setCurrentState("fire")

	if ViewModelAnim:
		
		if CurrentState == "idle":
			if not ViewModelAnim.is_playing() and ViewModelAnim.current_animation != getAnim(CurrentWeapon,CurrentState):
				ViewModelAnim.play(getAnim(CurrentWeapon,CurrentState))
				
		if CurrentState == "fire":
			if LastState != "fire":
				ViewModelAnim.stop()
				WeaponFire.play(CurrentWeapon.FireAnim,0.0,CurrentWeapon.FireSpeed)
				ViewModelAnim.play(getAnim(CurrentWeapon,CurrentState),0.1,CurrentWeapon.FireSpeed)
			if not ViewModelAnim.is_playing():
				setCurrentState("idle")

		if CurrentState == "reload":
			if LastState != "reload":
				ViewModelAnim.stop()
				ViewModelAnim.play(getAnim(CurrentWeapon,CurrentState))
				Helpers.createSound($"../PlayerSound",CurrentWeapon.ReloadSound,Aim)
			if not ViewModelAnim.is_playing():
				CurrentWeapon.RefillClip()
				setCurrentState("idle")

		if Weapons[WeaponSlot].Model:
			ViewModelWeapon.mesh = Weapons[WeaponSlot].Model
			ViewModelWeapon.visible = true
		else:
			ViewModelWeapon.visible = false
	LastState = CurrentState


func ChangeWeaponSlot(dir):
	WeaponSlot += dir
	if WeaponSlot < 0:
		WeaponSlot = len(Weapons)-1
	if WeaponSlot > len(Weapons)-1:
		WeaponSlot = 0
	if not is_multiplayer_authority(): return
	networkWeaponSlot.rpc(WeaponSlot)

@rpc("call_local")
func networkWeaponSlot(weaponslot):
	WeaponSlot = weaponslot
	
@rpc("call_local")
func networkCurrentState(state):
	CurrentState = state
	
	
@rpc("call_local")
func networkCreateProjectile(auth):
	Helpers.createProjectile(
		Aim.global_transform,
		(Player.velocity*0.5)+Aim.get_global_transform().basis.z*-CurrentWeapon.ProjXSpeed+Vector3(0,CurrentWeapon.ProjYSpeed,0),
		CurrentWeapon.Projectile,
		Aim,
		Player.Team,
		auth
	)
	
func setCurrentState(state):
	CurrentState = state
	if not is_multiplayer_authority(): return
	networkCurrentState.rpc(CurrentState)
	
func getAnim(w,s):
	return w.AnimationSet+"_"+s
