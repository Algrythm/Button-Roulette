extends CanvasLayer

@onready var playSingleplayer = $Button
@onready var playMutiplayer = $Button3
@onready var quit = $Button4
@onready var button1Anim = $Button/AnimationPlayer
@onready var button2Anim = $Button3/AnimationPlayer
@onready var button3Anim = $Button4/AnimationPlayer
@onready var logoAnim = $Logo/AnimationPlayer
@onready var xpLabelA = $xpLabel/AnimationPlayer
@onready var xpLabel = $xpLabel
@onready var xpTotal = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if FileAccess.file_exists("res://save.dat"):
		var saveFileRead = FileAccess.open("res://save.dat",FileAccess.READ)
		xpTotal = saveFileRead.get_var(xpTotal)
		saveFileRead.close()
		xpLabel.text = "XP: " + str(xpTotal)
	await get_tree().create_timer(3).timeout
	button1Anim.play("fadeInButton")
	button2Anim.play("fadeInButton")
	button3Anim.play("fadeInButton")
	xpLabelA.play("fadeInButton")
	playSingleplayer.pressed.connect(singlePlayer)
	quit.pressed.connect(quitFunc)
	
	

func singlePlayer():
	button1Anim.play("fadeOutButton")
	button2Anim.play("fadeOutButton")
	button3Anim.play("fadeOutButton")
	logoAnim.play("fadeOutLogo")
	xpLabelA.play("fadeOutButton")
	await get_tree().create_timer(1).timeout
	get_tree().change_scene_to_file("res://scenes/gameScene.tscn")

func quitFunc():
	get_tree().quit()
