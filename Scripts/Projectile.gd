extends ProjectileConfig

@onready var RigidBody = $RigidBody3D
@onready var CollisionShape = $RigidBody3D/CollisionShape3D
@onready var AreaShape = $RigidBody3D/Area3D/CollisionShape3D

var Owner = null
var ProjLifetime = 0
var velocity = null
var EnemyList = []
var HitEnemyDict = {}
var QueuedDeath = false
var Authority = 0
var Team = "none"
# Called when the node enters the scene tree for the first time.
func _ready():
	RigidBody.set_linear_velocity(velocity)
	RigidBody.gravity_scale = Gravity
	#print(Size)
	$RigidBody3D/Smoothing/model.scale *= Size
	$RigidBody3D/Smoothing/debug.scale *= Size
	
	match Team:
		"player":
			$RigidBody3D/Area3D.set_collision_mask_value(4, true)
		"enemy":
			$RigidBody3D/Area3D.set_collision_mask_value(5, true)
			
	match HitboxShape:
		"Sphere":
			CollisionShape.shape = SphereShape3D.new()
			AreaShape.shape = SphereShape3D.new()
			CollisionShape.scale *= Size
			AreaShape.scale *= Size
			$RigidBody3D/Smoothing/debug.mesh = SphereMesh.new()
		"Cube":
			CollisionShape.shape = BoxShape3D.new()
			AreaShape.shape = BoxShape3D.new()
			CollisionShape.scale *= Size
			AreaShape.scale *= Size
			$RigidBody3D/Smoothing/debug.mesh = BoxMesh.new()
			
	if not PhysicsEnabled:
		RigidBody.freeze = true
		RigidBody.set_collision_mask_value(1, false)
	elif Size is Vector3:
		push_warning("!WARNING! Asymectrical scale is not supported on rigidbodies")
	if DieOnTerrain:
		RigidBody.contact_monitor = true
		RigidBody.max_contacts_reported = 1
		
	if SpawnSound:
		Helpers.createSound($RigidBody3D/Audio,SpawnSound)
		
	$RigidBody3D/Smoothing.teleport()

func _afterlerp():
	pass


func initialize(pos,vel,projconfig,body,team, auth):
	for entry in projconfig.SetVars:
		self[entry] = projconfig[entry]
	Authority = auth
	set_multiplayer_authority(Authority)
	$RigidBody3D/Smoothing/model.mesh = Model

	Owner = body
	if Owner:
		transform = pos.translated(Owner.get_global_transform().basis*-AttachOffset)
	else:
		transform = pos
	
	velocity = vel
	Team = team

func sort_ascending(a, b):
	if a[1] < b[1]:
		return true
	return false

func DamageNumber(e,d):
	var Number = preload("res://DamageNumberREAL.tscn").instantiate()
	Number.text = str(d)
	$"..".add_child(Number)
	Number.global_position = e.global_position+((global_position-e.global_position)*Vector3(0,1,0))
	
func AttackEnemies(l):
	for i in l:
		if i[0].has_method("takeDamage"):
			#print(i[0],i[0].isAlive())
			if PierceCount > 0 and i[0].isAlive() and not i[0].name in HitEnemyDict:
				#print(get_multiplayer_authority()," ",Authority," ",is_multiplayer_authority())
				if is_multiplayer_authority():
					Helpers.dealDamage(i[0].name,Damage)
					DamageNumber(i[0],Damage)
				PierceCount -= 1
				HitEnemyDict[i[0].name] = ProjLifetime
				if HitSound:
					Helpers.createSound($RigidBody3D/Audio,HitSound)
			if DieOnHit and PierceCount < 1:
				Die()

func _physics_process(delta):
	if EnemyList.size() > 0:
		EnemyList.sort_custom(sort_ascending)
		AttackEnemies(EnemyList)

		EnemyList.clear()
	if AttachToOwner and Owner:
		transform = Owner.global_transform.translated(Owner.get_global_transform().basis*-AttachOffset)
	if ForceDir and not (RigidBody.get_linear_velocity().normalized().y == 1.0 or RigidBody.get_linear_velocity().normalized().y == -1.0):
		$RigidBody3D/Smoothing/model.look_at(self.position+RigidBody.get_linear_velocity())
	ProjLifetime += delta
	if ProjLifetime > ProjMaxLifetime:
		Die()

func Die():
	if not QueuedDeath:
		if DeathProjectile and not QueuedDeath:
			Helpers.createProjectile(
				RigidBody.global_transform,
				RigidBody.get_linear_velocity(),
				DeathProjectile,
				null,
				Team,
				Authority
			)
		if DeathSound:
			Helpers.createSound($RigidBody3D/Audio,DeathSound)
		QueuedDeath = true
		queue_free()

func _on_rigid_body_3d_body_entered(_body):
	if DieOnTerrain == true:
		Die()

func _on_area_3d_body_entered(body):
	if QueuedDeath: return
	var pos = RigidBody.global_position
	if AttachToOwner and Owner:
		pos = Owner.global_position

	EnemyList.append([body,body.global_position.distance_to(pos)])
