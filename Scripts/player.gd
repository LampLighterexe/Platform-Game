#extends CharacterBody3D
extends PlayerConfig



signal HealthChanged
signal AmmoChanged

var Team = "player"
var CameraSens = 0.0025
var movement1_charge = true
var lastDamageTime = 5.0

var lastcharacter = null
var character = null
var PlayerSkeleton = null
var PlayerWorldModel = null
var MasterAnimator = null
var WorldMasterAnimator = null
@onready var WeaponController := $WeaponController
@onready var neck := $Smoothing/Neck
@onready var camera := $Smoothing/Neck/Camera3D
@onready var PlayerModelContainer := $Smoothing/Neck/PlayerModel
@onready var Aim := $Aim
@onready var ViewModelCamera := $CanvasLayer/SubViewportContainer/SubViewport/ViewModelCamera
@onready var ViewModelWeapon := $Smoothing/Neck/Camera3D/view_arms/Armature/Skeleton3D/BoneAttachment3D/WeaponModel
@onready var ViewModel := $Smoothing/Neck/Camera3D/view_arms/Armature/Skeleton3D/Cube



var Health: float:
	get:
		return Health
	set(v):
		if v < 0.0:
			v = 0.0
		if v > MaxHealth:
			v = MaxHealth
			
		Health = v
		
		if not is_multiplayer_authority(): return
		syncHealth.rpc(Health)
		HealthChanged.emit(Health,MaxHealth)

@rpc("any_peer")
func syncHealth(h):
	Health = h

@rpc("call_local")
func changeTeam(team):
	Team = team

@rpc("any_peer","call_local")
func takeDamage(damage):
	if damage > 0:
		Health -= damage
		lastDamageTime = 0.0
		Helpers.createSound($PlayerSound,preload("res://Sounds/hit1.wav"),self)

@rpc("any_peer", "call_local")
func takeKnockback(kb,kbpos,type,vel):
	if not is_multiplayer_authority(): return
	velocity += vel*KbMul

func isAlive():
	return Health > 0.0
	
func _unhandled_input(event: InputEvent) -> void:
	if not is_multiplayer_authority(): return
	

	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			neck.rotate_y(-event.relative.x * CameraSens)
			camera.rotate_x(-event.relative.y * CameraSens)
			
			camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-90), deg_to_rad(90))
	if Input.is_action_just_pressed("debugkey2"):
		if Team == "player":
			changeTeam.rpc("enemy")
		else:
			changeTeam.rpc("player")
	if Input.is_action_just_pressed("debugkey3"):
		camera.set_cull_mask_value(10,not camera.get_cull_mask_value(10))

func _enter_tree():
	set_multiplayer_authority(str(name).to_int())

@rpc("call_local")
func setChar(c):
	if not lastcharacter == c:
		character = c

func setChildrenMask(node,dict={}):
	for i in get_all_children(node):
		if i is MeshInstance3D:
			for mask in dict:
				i.set_layer_mask_value(mask,dict[mask])

func get_all_children(in_node,arr:=[]):
	arr.push_back(in_node)
	for child in in_node.get_children():
		arr = get_all_children(child,arr)
	return arr

func setCharacterDefaults(c):
	Registry.PlayerFact.setPlayer(self,c)
	lastcharacter = c
	for i in PlayerModelContainer.get_children():
		PlayerModelContainer.remove_child(i)
		i.queue_free()
	if PlayerModel:
		if is_multiplayer_authority():
			PlayerWorldModel = PlayerModel.instantiate()
		PlayerModel = PlayerModel.instantiate()
		PlayerModelContainer.add_child(PlayerModel)
		MasterAnimator = PlayerModel.get_node("%master_animator")
		PlayerSkeleton = PlayerModel.get_node("%GeneralSkeleton")
		MasterAnimator.Skeleton = PlayerSkeleton
		MasterAnimator.set_multiplayer_authority(str(name).to_int())
		MasterAnimator.character = character
	if PlayerWorldModel:
		PlayerModelContainer.add_child(PlayerWorldModel)
		WorldMasterAnimator = PlayerWorldModel.get_node("%master_animator")
		WorldMasterAnimator.set_multiplayer_authority(str(name).to_int())
		WorldMasterAnimator.character = character

	scale = Vector3.ONE * Size
	if ViewHeight:
		neck.position.y = ViewHeight
		PlayerModelContainer.position.y = -ViewHeight
	if is_multiplayer_authority():
		if PlayerSkeleton:
			PlayerSkeleton.set_bone_pose_scale(PlayerSkeleton.find_bone("Head"),Vector3(0.0,0.0,0.0))
			setChildrenMask(PlayerModel,{1:false,7:true})
			setChildrenMask(PlayerWorldModel,{1:false,6:true})
			WorldMasterAnimator.Sync = false
			for i in get_all_children(PlayerModel):
				if i is MeshInstance3D:
					i.cast_shadow = false
			for i in get_all_children(PlayerWorldModel):
				if i is MeshInstance3D and not i.name == "justdont":
					var mesh = MeshInstance3D.new()
					PlayerWorldModel.get_node("%GeneralSkeleton").add_child(mesh)
					mesh.mesh = i.mesh
					mesh.skin = i.skin
					mesh.skeleton = i.skeleton
					mesh.cast_shadow = 3
					i.cast_shadow = false
		PlayerModelContainer.position.z = 0.2
	Health = MaxHealth
	pass

func _ready():
	#setCharacterDefaults(character)
	ViewModel.set_surface_override_material(0,StandardMaterial3D.new())
	if not is_multiplayer_authority():
		$CanvasLayer/SubViewportContainer.hide()
		ViewModelWeapon.set_layer_mask_value(2,false)
		ViewModel.set_layer_mask_value(2,false)
		return
	setChar.rpc(get_node("/root/World").CharacterSelect.get_item_text(get_node("/root/World").CharacterSelect.get_selected_id()))
	WeaponController.set_multiplayer_authority(str(name).to_int())
	ViewModelCamera.set_environment(camera.get_environment())
	camera.current = true

func _afterlerp():
	ViewModelCamera.global_transform = camera.global_transform
	Aim.global_transform = camera.global_transform

func _process(delta):
	lastDamageTime += delta
	
	#gross hack, remake when lobby system is added
	if get_node("/root/World").RequiresReset:
		setChar.rpc(character)
		if MasterAnimator:
			MasterAnimator.RequiresReset = true
		get_node("/root/World").RequiresReset = false
	if not character == lastcharacter:
		setCharacterDefaults(character)
	if MasterAnimator:
		MasterAnimator.lookblend = (camera.rotation.x+1.57)/3.14
		MasterAnimator.weaponstate = WeaponController.CurrentState
		if is_multiplayer_authority():
			if WorldMasterAnimator:
				WorldMasterAnimator.lookblend = MasterAnimator.lookblend
			if WeaponController.CurrentWeapon:
				MasterAnimator.weapon = WeaponController.CurrentWeapon
				WorldMasterAnimator.weapon = WeaponController.CurrentWeapon
				WorldMasterAnimator.weaponstate = WeaponController.CurrentState

	if lastDamageTime < 0.25:
		ViewModel.get_active_material(0).albedo_color = Color(1,0,0,1)
	else:
		ViewModel.get_active_material(0).albedo_color = Color(0.78,0.78,0.78,1)
	if not is_multiplayer_authority():return
	if lastDamageTime > 3.0 and Health < MaxHealth:
		Health+=(MaxHealth*0.1)*delta

func getTotalVel():
	return absf(velocity.x)+absf(velocity.z)

func _physics_process(delta):
	if not is_multiplayer_authority(): return
	if MasterAnimator:
		MasterAnimator.motion = (min(sqrt(getTotalVel()/3),1.0))
		if WorldMasterAnimator:
			WorldMasterAnimator.motion = MasterAnimator.motion

	if not isAlive():
		position = Vector3.ZERO
		Health = MaxHealth
	
	if position.y < -25:
		position.y += 50
		velocity.y = 0
	
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		movement1_charge = true

	var input_dir = Input.get_vector("left", "right", "up", "down")
	var direction = (neck.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	var wishdir = velocity+(direction*((speed*60 if is_on_floor() else airSpeed*60)*delta))
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jumpVelocity
	
	if Input.is_action_just_pressed("movement1") and movement1_charge:
		velocity.y = jumpVelocity*0.5
		if direction.x == 0 and direction.y == 0:
			direction = (neck.transform.basis * Vector3(0, 0, -1)).normalized()
		wishdir += (direction*(speed*10))
		movement1_charge = false
	
	if is_on_floor():
		wishdir.x *= groundDecel**delta
		wishdir.z *= groundDecel**delta
		if direction == Vector3.ZERO and absf(wishdir.x)+absf(wishdir.z) < 0.5:
			wishdir *= Vector3(0,1,0)
	else:
		wishdir.x *= airDecel**delta
		wishdir.z *= airDecel**delta
		
	velocity.x = wishdir.x
	velocity.z = wishdir.z
	var was_on_floor = is_on_floor()
	
	move_and_slide()
	if Input.is_action_just_pressed("jump") and is_on_wall() and not was_on_floor:
		velocity += (get_wall_normal()*(speed*8))
		velocity.y = jumpVelocity*0.9
