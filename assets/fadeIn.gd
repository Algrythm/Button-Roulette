extends ColorRect

@onready var animationPlayer = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animationPlayer.play("fade")
	await get_tree().create_timer(1.0).timeout
	$".".queue_free()
