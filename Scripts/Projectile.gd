extends ProjectileConfig

@onready var RigidBody = $RigidBody3D
@onready var CollisionShape = $RigidBody3D/CollisionShape3D
@onready var AreaShape = $RigidBody3D/Area3D/CollisionShape3D

var Owner = null
var ProjLifetime = 0
var velocity = null
# Called when the node enters the scene tree for the first time.
func _ready():
	RigidBody.set_linear_velocity(velocity)
	RigidBody.gravity_scale = Gravity
	#print(Size)
	$RigidBody3D/Smoothing/model.scale *= Size
	$RigidBody3D/Smoothing/debug.scale *= Size
	if HitboxShape == "Sphere":
		CollisionShape.shape = SphereShape3D.new()
		AreaShape.shape = SphereShape3D.new()
		CollisionShape.scale *= Size
		AreaShape.scale *= Size
		$RigidBody3D/Smoothing/debug.mesh = SphereMesh.new()
	if HitboxShape == "Cube":
		CollisionShape.shape = BoxShape3D.new()
		AreaShape.shape = BoxShape3D.new()
		CollisionShape.scale *= Size
		AreaShape.scale *= Size
		$RigidBody3D/Smoothing/debug.mesh = BoxMesh.new()
	#if HitboxShape == "Ray":
	#	CollisionShape.shape = SphereShape3D.new()
	#	AreaShape.shape = SphereShape3D.new()
	#	AreaShape.shape.radius = AreaShape.shape.radius*1.25
	if not PhysicsEnabled:
		RigidBody.freeze = true
		RigidBody.set_collision_mask_value(1, false)
	elif Size is Vector3:
		push_warning("!WARNING! Asymectrical scale is not supported on rigidbodies")
	if DieOnTerrain:
		RigidBody.contact_monitor = true
		RigidBody.max_contacts_reported = 1
	$RigidBody3D/Smoothing.teleport()

func _afterlerp():
	pass

func initialize(pos,vel,projconfig,body):
	Owner = body
	Damage = projconfig.Damage
	AttachToOwner = projconfig.AttachToOwner
	HitboxShape = projconfig.HitboxShape
	$RigidBody3D/Smoothing/model.mesh = projconfig.Model
	PierceCount = projconfig.PierceCount
	DieOnHit = projconfig.DieOnHit
	DieOnTerrain = projconfig.DieOnTerrain
	ProjMaxLifetime = projconfig.ProjMaxLifetime
	Gravity = projconfig.Gravity
	PhysicsEnabled = projconfig.PhysicsEnabled
	AttachOffset = projconfig.AttachOffset
	Size = projconfig.Size
	ForceDir = projconfig.ForceDir
	transform = pos.translated(Owner.get_global_transform().basis*-AttachOffset)
	velocity = vel
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _physics_process(delta):
	if ForceDir:
		$RigidBody3D/Smoothing/model.look_at(self.position+RigidBody.get_linear_velocity())
	if AttachToOwner:
		transform = Owner.global_transform.translated(Owner.get_global_transform().basis*-AttachOffset)
		
	ProjLifetime += delta
	if ProjLifetime > ProjMaxLifetime:
		queue_free()
	

func _on_rigid_body_3d_body_entered(_body):
	if DieOnTerrain == true:
		queue_free()


func _on_area_3d_body_entered(body):
	if body.has_method("takeDamage"):
		if PierceCount > 0:
			body.takeDamage(Damage)
			print(self," found entity ", body)
			PierceCount -= 1
	if DieOnHit and PierceCount < 1:
		queue_free()
	
	
	pass # Replace with function body.
