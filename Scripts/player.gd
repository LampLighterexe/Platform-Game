extends CharacterBody3D

const AIRSPEED = 0.2
const SPEED = 1.0
const JUMP_VELOCITY = 6
const AIRDECEL = 0.30
const GROUNDDECEL = 0.0001

var CameraSens = 0.0025
var movement1_charge = true

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var neck := $Smoothing/Neck
@onready var camera := $Smoothing/Neck/Camera3D

@onready var Aim := $Aim

@onready var ViewModelCamera := $CanvasLayer/SubViewportContainer/SubViewport/ViewModelCamera

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	elif event.is_action_pressed("inventory") or event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			neck.rotate_y(-event.relative.x * CameraSens)
			camera.rotate_x(-event.relative.y * CameraSens)
			
			camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-90), deg_to_rad(90))


func _ready():
	var MainEnv = camera.get_environment()
	ViewModelCamera.set_environment(MainEnv)
	
func _afterlerp():
	ViewModelCamera.global_transform = camera.global_transform
	Aim.global_transform = camera.global_transform

func _physics_process(delta):
	# Add the gravity.
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
