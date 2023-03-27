extends Sprite2D

@onready var Text =$Label
@onready var Bar =$HealthBar

var Health = MaxHealth
var MaxHealth = 100
var lastHealth = 0

func _process(delta):
	Bar.region_rect.size.x = int((lastHealth/MaxHealth)*1200)
	lastHealth = move_toward(lastHealth, Health, 1)
	Text.text = str(Health)

func _on_player_health_changed(h,mh):
	Health = h
	MaxHealth = mh
	pass # Replace with function body.
