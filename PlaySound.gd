extends AudioStreamPlayer3D

func _ready():
	play()

func _process(_delta):
	if not playing:
		queue_free()

