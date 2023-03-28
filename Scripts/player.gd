extends CharacterBody3D


var Team = "player"
signal HealthChanged
var MaxHealth = 100.0
var lastDamageTime = 0.0
var Health: float:
	get:
		return Health
	set(v):
		if v < 0.0:
			v = 0.0
		if v > MaxHealth:
			v = MaxHealth
			
		Health = v
		
		#syncHealth.rpc(Health)
		HealthChanged.emit(Health,MaxHealth)

@rpc("any_peer")
func syncHealth(h):
	Health = h

@rpc("call_local")
func changeTeamtoEnemy():
	Team = "enemy"
	set_collision_layer_value(5,false)
	set_collision_layer_value(4,true)

@rpc("any_peer","call_local")
func takeDamage(damage):
	Health -= damage
	lastDamageTime = 0.0
	pass
	
func isAlive():
	return Health > 0.0

const AIRSPEED = 0.2
const SPEED = 1.0
const JUMP_VELOCITY = 6
const AIRDECEL = 0.30
const GROUNDDECEL = 0.0001

var CameraSens = 0.0025
var movement1_charge = true
var EnableCamera = false
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var neck := $Smoothing/Neck
@onready var camera := $Smoothing/Neck/Camera3D
@onready var Aim := $Aim
@onready var ViewModelCamera := $CanvasLayer/SubViewportContainer/SubViewport/ViewModelCamera

func _unhandled_input(event: InputEvent) -> void:
	if not is_multiplayer_authority(): return
	
	if event is InputEventMouseButton:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	elif event.is_action_pressed("inventory") or event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			neck.rotate_y(-event.relative.x * CameraSens)
			camera.rotate_x(-event.relative.y * CameraSens)
			
			camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-90), deg_to_rad(90))
	if Input.is_action_just_pressed("debugkey2"):
		changeTeamtoEnemy.rpc()

func _enter_tree():
	set_multiplayer_authority(str(name).to_int())

func _ready():
	if not is_multiplayer_authority():
		$CanvasLayer/SubViewportContainer.hide()
		$Smoothing/Neck/Camera3D/view_arms/Armature/Skeleton3D/BoneAttachment3D/WeaponModel.set_layer_mask_value(1,true)
		$Smoothing/Neck/Camera3D/view_arms/Armature/Skeleton3D/BoneAttachment3D/WeaponModel.set_layer_mask_value(2,false)
		$Smoothing/Neck/Camera3D/view_arms/Armature/Skeleton3D/Cube.set_layer_mask_value(1,true)
		$Smoothing/Neck/Camera3D/view_arms/Armature/Skeleton3D/Cube.set_layer_mask_value(2,false)
		Health = 100
		return 
	$WeaponController.set_multiplayer_authority(str(name).to_int())
	Health = MaxHealth
	var MainEnv = camera.get_environment()
	ViewModelCamera.set_environment(MainEnv)
	camera.current = true
	
func _afterlerp():
	ViewModelCamera.global_transform = camera.global_transform
	Aim.global_transform = camera.global_transform

func _process(delta):
	if not is_multiplayer_authority(): 
		Health = 100
		return
	lastDamageTime += delta
	if lastDamageTime > 3.0 and Health < MaxHealth:
		Health+=(MaxHealth*0.1)*delta

func _physics_process(delta):
	if not is_multiplayer_authority(): return
	
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		movement1_charge = true

	# Handle Jump.


	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("left", "right", "up", "down")
	var direction = (neck.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	var wishdir = velocity+(direction*((SPEED*60 if is_on_floor() else AIRSPEED*60)*delta))
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	if Input.is_action_just_pressed("movement1") and movement1_charge:
		velocity.y = JUMP_VELOCITY*0.5
		if direction.x == 0 and direction.y == 0:
			direction = (neck.transform.basis * Vector3(0, 0, -1)).normalized()
		wishdir += (direction*(SPEED*10))
		movement1_charge = false
	
	if is_on_floor():
		wishdir.x *= GROUNDDECEL**delta
		wishdir.z *= GROUNDDECEL**delta
	else:
		wishdir.x *= AIRDECEL**delta
		wishdir.z *= AIRDECEL**delta
		
	velocity.x = wishdir.x
	velocity.z = wishdir.z
	var was_on_floor = is_on_floor()
	move_and_slide()
	if Input.is_action_just_pressed("jump") and is_on_wall() and not was_on_floor:
		velocity += (get_wall_normal()*(SPEED*8))
		velocity.y = JUMP_VELOCITY*0.9
