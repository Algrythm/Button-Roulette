extends CanvasLayer


@onready var gameStatusA = $gameStatus/AnimationPlayer
@onready var gameEndStatusA = $gameEndStatus/AnimationPlayer
@onready var xpEarnedA = $xpEarned/AnimationPlayer
@onready var gameStatus = $gameStatus
@onready var gameEndStatus = $gameEndStatus
@onready var xpEarned = $xpEarned
@onready var winStatus = false
@onready var deadSound = $deadsound
@onready var exitButton = $Button
@onready var exitButtonA = $Button/AnimationPlayer
@onready var winType = false
@onready var xp = 0
@onready var xpTotal = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	saveData()
	deadSound.play()
	exitButton.pressed.connect(_skipCutscene)
	await get_tree().create_timer(3).timeout
	gameEndStatusA.play("fadeInButton")
	xpEarnedA.play("fadeInButton")
	exitButtonA.play("fadeInButton")
	await get_tree().create_timer(14).timeout
	exit()

func _skipCutscene():
	exit()

func saveData():
	var file = FileAccess.open("res://tempSave.dat",FileAccess.READ)
	winStatus = file.get_var(winStatus)
	winType = file.get_var(winType)
	xp = file.get_var(xp)
	file.close()
	if winStatus == true:
		gameStatus.text = "You Win"
		if winType == true:
			gameEndStatus.text = "You pulled out the button. You killed your opponent."
		else:
			gameEndStatus.text = "Your opponent chose the wrong button. They died."
	else:
		if winType == true:
			gameStatus.text = "You Lose"
			gameEndStatus.text = "Your opponent pulled out the right button."
		else:
			gameStatus.text = "You Lose"
			gameEndStatus.text = "Your opponent outlasted you."
	xpEarned.text = "You earned " + str(xp) + " XP."
	if FileAccess.file_exists("res://save.dat"):
		var saveFileRead = FileAccess.open("res://save.dat",FileAccess.READ)
		xpTotal = saveFileRead.get_var(xpTotal)
		saveFileRead.close()
		xpTotal = xpTotal + xp
		var saveFileWrite = FileAccess.open("res://save.dat",FileAccess.WRITE)
		saveFileWrite.store_var(xpTotal)
		saveFileWrite.close()
	else:
		xpTotal = xp
		var saveFileWrite = FileAccess.open("res://save.dat",FileAccess.WRITE)
		saveFileWrite.store_var(xpTotal)
		saveFileWrite.close()

func exit():
	gameStatusA.play("fadeOutLogo")
	gameEndStatusA.play("fadeOutButton")
	xpEarnedA.play("fadeOutButton")
	exitButtonA.play("fadeOutButton")
	await get_tree().create_timer(1).timeout
	get_tree().change_scene_to_file("res://scenes/mainMenu.tscn")
