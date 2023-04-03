extends Sprite2D

@onready var Text =$Label
@onready var Bar =$HealthBar

var MaxHealth = 100.0
var Health = MaxHealth
var lastHealth = 0.0

func _process(delta):
	Bar.region_rect.size.x = int((lastHealth/MaxHealth)*1200)
	lastHealth = move_toward(lastHealth, Health, MaxHealth/100)
	Text.text = str(int(Health))

func update_health_bar(h,mh):
	Health = h
	MaxHealth = mh
