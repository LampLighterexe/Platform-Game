extends Sprite2D

@onready var Text = $Label
@onready var Bar = $HealthBar
@onready var Points = $Points
@onready var Ammo = $Ammo

var MaxHealth = 100.0
var Health = MaxHealth
var lastHealth = 0.0
var points = 0

var Clip = 0
var ClipMax = 0
var MaxAmmo = 0

func _process(delta):
	Bar.region_rect.size.x = ceil((lastHealth/MaxHealth)*1200)
	lastHealth = move_toward(lastHealth, Health, MaxHealth/100)
	Text.text = str(ceil(Health))
	Points.text = "Score: "+str(points)
	if Clip > -1:
		if MaxAmmo > -1:
			Ammo.text = str(Clip)+"/"+str(MaxAmmo)
		else:
			Ammo.text = str(Clip)+"/"+str(ClipMax)
	else:
		Ammo.text =""

func update_health_bar(h,mh):
	Health = h
	MaxHealth = mh
	
func update_ammo(c,cm,ma):
	Clip = c
	ClipMax = cm
	MaxAmmo = ma
	
func add_points(p):
	points += p
