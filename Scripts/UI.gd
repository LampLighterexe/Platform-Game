extends SubViewportContainer
var viewport_initial_size
func _ready():
	viewport_initial_size = self.size
	#size.y = viewport_initial_size.y
	#size.x = viewport_initial_size.x
func _on_sub_viewport_size_changed():
	if viewport_initial_size:
		self.size = viewport_initial_size
		#print(self.scale)
		self.scale.y = get_viewport().size.y / viewport_initial_size.y
		self.scale.x = get_viewport().size.x / viewport_initial_size.x
