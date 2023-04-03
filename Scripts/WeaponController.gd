extends Node



func _unhandled_input(event: InputEvent) -> void:
	if not is_multiplayer_authority(): return
	if event is InputEventMouseButton and event.is_pressed():
		if event.button_index == 1:
			if CurrentState == "idle":
				if CurrentWeapon.CanFire():
					setCurrentState("fire")
				elif CurrentWeapon.CanReload():
					setCurrentState("reload")
		if event.button_index == 4:
			ChangeWeaponSlot(-1)
		if event.button_index == 5:
			ChangeWeaponSlot(1)
	if Input.is_action_just_pressed("reload") and CurrentState == "idle" and CurrentWeapon.CanReload():
		setCurrentState("reload")

@onready var ViewModelAnim := $"../Smoothing/Neck/Camera3D/view_arms/AnimationPlayer"
#@onready var ViewModelWeapon := $"../Smoothing/BoneAttachment3D/WeaponModel"
@onready var ViewModelWeapon := $"../Smoothing/Neck/Camera3D/view_arms/Armature/Skeleton3D/BoneAttachment3D/WeaponModel"
@onready var WeaponFire := $"../WeaponFire"
@onready var Aim := $"../Aim"
@onready var Player := $".."
@onready var SoundHolder := $"../Smoothing/Neck/Camera3D/SoundHolder"

var WeaponSlot = 0
var LastWeaponSlot = 0
var CurrentState = "equip"
var LastState = ""
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
	Helpers.createSound($"../PlayerSound",CurrentWeapon.FireSound,SoundHolder)
	CurrentWeapon.RemoveClip(1)
	
	if not is_multiplayer_authority(): return
	networkCreateProjectile.rpc(
		Aim.global_transform,
		(Player.velocity*0.5)+Aim.get_global_transform().basis.z*-CurrentWeapon.ProjXSpeed+Vector3(0,CurrentWeapon.ProjYSpeed,0),
		CurrentWeapon.Projectile,
		get_multiplayer_authority()
	)

func ResetWeaponState():
	WeaponFire.stop()
	ViewModelAnim.stop()
	LastState = ""
	ViewModelWeapon.visible = false
	setCurrentState("equip")
	for n in SoundHolder.get_children():
		if n is AudioStreamPlayer3D:
			SoundHolder.remove_child(n)
			n.queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	CurrentWeapon = Weapons[WeaponSlot]
	if not CurrentWeapon:
		return

	if LastWeaponSlot!= WeaponSlot:
		ResetWeaponState()
	LastWeaponSlot = WeaponSlot

	if is_multiplayer_authority() and CurrentState == "idle":
		if Input.is_action_pressed("autofire") and CurrentWeapon.Automatic:
			if CurrentWeapon.CanFire():
				setCurrentState("fire")
			elif CurrentWeapon.CanReload():
				setCurrentState("reload")
		if Input.is_action_pressed("reload") and CurrentWeapon.CanReload():
			setCurrentState("reload")

	if ViewModelAnim:
		match CurrentState:
			"idle":
				if not ViewModelAnim.is_playing() and ViewModelAnim.current_animation != getAnim(CurrentWeapon,CurrentState):
					ViewModelAnim.play(getAnim(CurrentWeapon,CurrentState))
				
			"fire":
				if LastState != "fire":
					ViewModelAnim.stop()
					WeaponFire.play(CurrentWeapon.FireAnim,0.0,CurrentWeapon.FireSpeed)
					ViewModelAnim.play(getAnim(CurrentWeapon,CurrentState),0.1,CurrentWeapon.FireSpeed)
				if not ViewModelAnim.is_playing():
					setCurrentState("idle")

			"reload":
				if LastState != "reload":
					#ViewModelAnim.stop()
					ViewModelAnim.play(getAnim(CurrentWeapon,CurrentState),0.1,CurrentWeapon.ReloadSpeed)
					Helpers.createSound($"../PlayerSound",CurrentWeapon.ReloadSound,SoundHolder)
				if not ViewModelAnim.is_playing():
					CurrentWeapon.RefillClip()
					setCurrentState("idle")
			"equip":
				if LastState != "equip":
					ViewModelAnim.play(getAnim(CurrentWeapon,CurrentState),0.0,CurrentWeapon.EquipSpeed)
				else:
					if Weapons[WeaponSlot].Model:
						ViewModelWeapon.mesh = Weapons[WeaponSlot].Model
						ViewModelWeapon.visible = true
					else:
						ViewModelWeapon.visible = false
				if not ViewModelAnim.is_playing():
					setCurrentState("idle")

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
func networkCreateProjectile(pos,velocity,projconfig,auth):
	Helpers.createProjectile(
		pos,
		velocity,
		projconfig,
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
