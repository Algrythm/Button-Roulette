extends Sprite2D

@onready var debounce = false

func flicker():
	if debounce == false:
		debounce = true
		self.visible = true
		await get_tree().create_timer(randi_range(1,5)).timeout
		self.visible = false
		await get_tree().create_timer(0.05).timeout
		self.visible = true
		await get_tree().create_timer(0.05).timeout
		self.visible = false
		await get_tree().create_timer(0.7).timeout
		debounce = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	flicker()
