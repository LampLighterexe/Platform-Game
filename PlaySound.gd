extends AudioStreamPlayer3D

func _ready():
	play()

func _process(delta):
	if not playing:
		queue_free()

