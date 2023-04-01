extends Node3D

var timer = 0

@onready var Particles = $DamageNumber
@onready var Text = $SubViewport/Control/Label
@onready var TextViewport = $SubViewport
var text = "amogus"
func _ready():
	Particles.emitting = true
	Text.text = text
	Particles.mesh.material.albedo_texture = TextViewport.get_texture()
func _physics_process(delta):
	timer += delta
	
	#for some reason the texture is not fully initalized on _ready
	Particles.show()
	
	if timer >= Particles.lifetime*0.95:
		queue_free()
