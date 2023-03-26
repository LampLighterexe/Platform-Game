extends CPUParticles3D

var timer = 0

func _ready():
	emitting = true

func _physics_process(delta):
	timer += delta
	if timer > lifetime:
		queue_free()

