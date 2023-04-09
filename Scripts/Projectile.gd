extends ProjectileConfig

@onready var CollisionShape = $CollisionShape3D
@onready var AreaShape = $Area3D/CollisionShape3D
@onready var Area = $Area3D

var Owner = null
var ProjLifetime = 0
var EnemyList = []
var HitEnemyDict = {}
var QueuedDeath = false
var Authority = 0
var Team = "none"
var DisplayDamage = false
var PlayerRef = null
# Called when the node enters the scene tree for the first time.
func _ready():
	
	#RigidBody.gravity_scale = Gravity
	#print(Size)
	$Smoothing/model.scale *= Size
	$Smoothing/debug.scale *= Size
	match HitboxShape:
		"Sphere":
			CollisionShape.shape = SphereShape3D.new()
			AreaShape.shape = SphereShape3D.new()
			CollisionShape.scale *= Size
			AreaShape.scale *= Size
			
			AreaShape.scale *= HitboxSize
			$Smoothing/debug.mesh = SphereMesh.new()
		"Cube":
			CollisionShape.shape = BoxShape3D.new()
			AreaShape.shape = BoxShape3D.new()
			CollisionShape.scale *= Size
			AreaShape.scale *= Size
			AreaShape.scale *= HitboxSize
			$Smoothing/debug.mesh = BoxMesh.new()
			
	if not PhysicsEnabled:
		set_collision_mask_value(1, false)
	#elif Size is Vector3:
	#	push_warning("!WARNING! Asymectrical scale is not supported on rigidbodies")

	if SpawnSound:
		Helpers.createSound($Audio,SpawnSound)
		
	$Smoothing.teleport()

func _afterlerp():
	pass


func initialize(pos,vel,projconfig,body,team,auth,ref,showdmg):
	for entry in projconfig.SetVars:
		self[entry] = projconfig[entry]
	Authority = auth
	DisplayDamage = showdmg
	set_multiplayer_authority(Authority)
	$Smoothing/model.mesh = Model
	PlayerRef = ref
	Owner = body
	if Owner and Owner != null:
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
	var Number = preload("res://Scenes/DamageNumberREAL.tscn").instantiate()
	Number.text = str(d)
	$"..".add_child(Number)
	Number.global_position = e.global_position+((global_position-e.global_position)*Vector3(0,1,0))
	
func AttackEnemies(l):
	for i in l:
		if i[0].has_method("takeDamage"):
			if PierceCount > 0 and i[0].isAlive() and (not i[0].name in HitEnemyDict or ProjLifetime-HitEnemyDict[i[0].name] > RepeatDamageInterval):
				#clientside
				if is_multiplayer_authority():
					Helpers.dealDamage(i[0].name,Damage)
					if Knockback:
						var kbpos = global_position
						if AttachToOwner and Owner and Owner != null:
							kbpos = Owner.global_position
						Helpers.dealKnockback(i[0].name,Knockback,kbpos,KnockbackType)
					if DisplayDamage and Damage > 0:
						DamageNumber(i[0],Damage)
				
				PierceCount -= 1
				HitEnemyDict[i[0].name] = ProjLifetime
				if HitSound:
					Helpers.createSound($Audio,HitSound)
			if DieOnHit and PierceCount < 1:
				Die()

func _physics_process(delta):
	if RepeatDamage and Area.has_overlapping_bodies():
		for body in Area.get_overlapping_bodies():
			addEnemytoList(body)
	if EnemyList.size() > 0:
		EnemyList.sort_custom(sort_ascending)
		AttackEnemies(EnemyList)
	
		EnemyList.clear()

	if AttachToOwner and Owner and Owner != null:
		transform = Owner.global_transform.translated(Owner.get_global_transform().basis*-AttachOffset)
	if ForceDir and not (velocity.normalized().y == 1.0 or velocity.normalized().y == -1.0):
		$Smoothing/model.look_at(global_position+velocity)
	ProjLifetime += delta
	if ProjLifetime > ProjMaxLifetime:
		Die()
	if PhysicsEnabled:
		velocity.y -= (9.8*Gravity)*delta
		move_and_slide()
		if DieOnTerrain and (is_on_wall() or is_on_ceiling() or is_on_floor()):
			Die()
	#get_slide_collision()

func Die():
	if not QueuedDeath:
		if DeathProjectile and not QueuedDeath:
			Helpers.createProjectile(
				global_transform,
				velocity,
				DeathProjectile,
				null,
				Team,
				Authority,
				PlayerRef,
				DisplayDamage
			)
		if DeathSound:
			Helpers.createSound($Audio,DeathSound)
		QueuedDeath = true
		queue_free()

func _on_rigid_body_3d_body_entered(_body):
	if DieOnTerrain == true:
		Die()

func addEnemytoList(b):
	if QueuedDeath: return
	var pos = global_position
	if AttachToOwner and Owner and Owner != null:
		pos = Owner.global_position
	if b.Team != Team or SelfDamage and b == PlayerRef:
		EnemyList.append([b,b.global_position.distance_to(pos)])
	
func _on_area_3d_body_entered(body):
	addEnemytoList(body)
