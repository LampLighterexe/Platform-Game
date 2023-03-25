extends ProjectileConfig

@onready var RigidBody = $RigidBody3D

var Owner = null
var ProjLifetime = 0
var velocity = null

# Called when the node enters the scene tree for the first time.
func _ready():
	RigidBody.set_linear_velocity(velocity)
	RigidBody.gravity_scale = Gravity
	pass # Replace with function body.

func _afterlerp():
	pass

func initialize(pos,vel,projconfig):
	Damage = projconfig.Damage
	AttachToOwner = projconfig.AttachToOwner
	HitboxShape = projconfig.HitboxShape
	$RigidBody3D/Smoothing/maxwell/RootNode/dingus.mesh = projconfig.Model
	PierceCount = projconfig.PierceCount
	DieOnHit = projconfig.DieOnHit
	DieOnTerrain = projconfig.DieOnTerrain
	ProjMaxLifetime = projconfig.ProjMaxLifetime
	Gravity = projconfig.Gravity

	transform = pos
	velocity = vel
	$RigidBody3D/Smoothing.teleport()
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	ProjLifetime += delta
	if ProjLifetime > ProjMaxLifetime:
		queue_free()
	pass

func _physics_process(delta):
	if DieOnTerrain == true and RigidBody.get_contact_count() > 1:
		queue_free()
	pass
