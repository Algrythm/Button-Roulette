extends Node2D

# this script contains all of the game systems
# this was just made for fun so if the code is shit thats why

# variables
@onready var playerCycle = true
@onready var canPress = true
@onready var lightBottom = $Tablelightbottom
@onready var table = $Tablegun
@onready var lightTop = $Tablelighttop
@onready var timer = $Timer
@onready var buttonSound = $Button
@onready var deadScreen = $DeadScreen
@onready var deadSound = $Dead
@onready var gunshotSound = $Gunshot
@onready var defibSound = $Defib
@onready var pressedButtons = 0
@onready var playerTurnLabel = $playerTurn
@onready var aiTurnLabel = $aiTurn
@onready var pressedButtonsAI = 0
@onready var card1 = $Card
@onready var card2 = $Card2
@onready var card3 = $Card3
@onready var card4 = $Card4
@onready var card5 = $Card5
@onready var card6 = $Card6
@onready var lightSound = $Light
@onready var useCardSound = $UseCardSound
@onready var ambience = $Ambience
@onready var cardSound = $CardSound
@onready var xpEarned = $xpEarnedLabel
@onready var tableShoot = $Tableshoot
@onready var tableBlood = $Tableblood
@onready var blackBar = $Blackbar
@onready var cardOpenButton = $CardButton
@onready var cardMenu1 = $Blackbar/Card1
@onready var cardMenu2 = $Blackbar/Card2
@onready var cardMenu3 = $Blackbar/Card3
@onready var cardMenu1L = $Blackbar/Card1/Label
@onready var cardMenu2L = $Blackbar/Card2/Label
@onready var cardMenu3L = $Blackbar/Card3/Label
@onready var defibActivePlr = false
@onready var defibActiveAI = false
@onready var cardButton1 = $Blackbar/Card1/TextureButton
@onready var cardButton2 = $Blackbar/Card2/TextureButton
@onready var cardButton3 = $Blackbar/Card3/TextureButton
@onready var xp = 0
const cardType1Tex = preload("res://assets/1.png")
const cardType2Tex = preload("res://assets/2.png")
const cardType3Tex = preload("res://assets/3.png")
const cardType4Tex = preload("res://assets/4.png")

@onready var cardTypes = {
	"1": "When used, the death button moves randomly within your opponent's set of remaining buttons.",
	"2": "When used, you are guaranteed survival during the next button press. If the button you press is the death button, the death button will move to a new spot. *Does not apply to button pulls."
}

@onready var aiCards = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# sets one button to be the death button for both players
	$Player1.get_children()[randi_range(1,len($Player1.get_children())-1)].name = "Death"
	$Player2.get_children()[randi_range(1,len($Player2.get_children())-1)].name = "Death"
	
	# adds button pressed function for every button
	for butt in $Player1.get_children():
		butt.gui_input.connect(_on_Button_gui_input.bind(butt))
	for butt in $Player2.get_children():
		butt.gui_input.connect(_on_Button_gui_input.bind(butt))
	
	cardOpenButton.pressed.connect(_cardButtonPressed)
	cardButton1.pressed.connect(_triggerCardPlr.bind(cardMenu1,card1))
	cardButton2.pressed.connect(_triggerCardPlr.bind(cardMenu2,card2))
	cardButton3.pressed.connect(_triggerCardPlr.bind(cardMenu3,card3))

func _on_Button_gui_input(event: InputEvent,button: TextureButton):
	# prevention of early press
	if canPress:
		# if actual player presses
		if playerCycle and event is InputEventMouseButton and event.pressed:
			match event.button_index: # if you need a comment to understand this it may be over for you
				MOUSE_BUTTON_LEFT:
					_lmbPlayerPress(button)
				MOUSE_BUTTON_RIGHT:
					_rmbPlayerPress(button)
				
		

# lmb press for player logic
func _lmbPlayerPress(button):
	if button.get_parent().name == "Player1" and not "Pressed" in button.name:
		canPress = false
		table.visible = false
		lightBottom.visible = true
		lightTop.visible = false
		timer.play()
		buttonSound.play()
		button.position = button.position + Vector2(0,8)
		xp = xp + randi_range(50,85)
		await get_tree().create_timer(6.0).timeout
		if button.name == "Death":
			if defibActivePlr:
				button.name = "Pressed"
				pressedButtons = pressedButtons + 1
				table.visible = true
				lightBottom.visible = false
				lightTop.visible = false
				lightSound.play()
				defibActivePlr = false
				var unpressedButtons = []
				for buttonPlr in $Player1.get_children():
					if not "Pressed" in buttonPlr.name:
						unpressedButtons.append(buttonPlr)
				unpressedButtons.pick_random().name = "Death"
				defibSound.play()
				playerCycle = not playerCycle
				canPress = true
			else:
				ambience.stop()
				deadScreen.visible = true
				gunshotSound.play()
				await get_tree().create_timer(2.5).timeout
				playerEnd(false,null)
				get_tree().change_scene_to_file("res://scenes/gameComplete.tscn")
		else:
			button.name = "Pressed"
			pressedButtons = pressedButtons + 1
			table.visible = true
			lightBottom.visible = false
			lightTop.visible = false
			lightSound.play()
			defibActivePlr = false
			playerCycle = not playerCycle
			canPress = true

# rmb press for player logic
func _rmbPlayerPress(button):
	if button.get_parent().name == "Player1" and not "Pressed" in button.name:
		canPress = false
		table.visible = false
		lightBottom.visible = true
		lightTop.visible = false
		timer.play()
		buttonSound.play()
		button.visible = false
		xp = xp + randi_range(200,300)
		await get_tree().create_timer(6.0).timeout
		if button.name == "Death":
			canPress = false
			ambience.stop()
			gunshotSound.play()
			tableShoot.visible = true
			await get_tree().create_timer(0.05).timeout
			tableBlood.visible = true
			await get_tree().create_timer(2.5).timeout
			xp = xp + randi_range(600,800)
			playerEnd(true,true)
			get_tree().change_scene_to_file("res://scenes/gameComplete.tscn")
		else:
			ambience.stop()
			deadScreen.visible = true
			gunshotSound.play()
			await get_tree().create_timer(2.5).timeout
			playerEnd(false,null)
			get_tree().change_scene_to_file("res://scenes/gameComplete.tscn")

# card menu animation player
func _cardButtonPressed():
	if blackBar.position.y == 272: # if its already up
		$Blackbar/AnimationPlayer.play("slidedown")
	else:
		$Blackbar/AnimationPlayer.play("slideup")

# ai lmb press logic
func _aiLMBPress(chosenButton):
	if chosenButton.get_parent().name == "Player2" and not "Pressed" in chosenButton.name:
		table.visible = false
		lightBottom.visible = false
		lightTop.visible = true
		timer.play()
		buttonSound.play()
		chosenButton.position = chosenButton.position - Vector2(0,8)
		await get_tree().create_timer(6.0).timeout
		if chosenButton.name == "Death":
			if defibActiveAI == true:
				chosenButton.name = "Pressed"
				pressedButtonsAI = pressedButtonsAI + 1
				table.visible = true
				lightBottom.visible = false
				lightTop.visible = false
				lightSound.play()
				defibActiveAI = false
				var unpressedButtons = []
				for buttonAI in $Player2.get_children():
					if not "Pressed" in buttonAI.name:
						unpressedButtons.append(buttonAI)
				unpressedButtons.pick_random().name = "Death"
				defibSound.play()
				playerCycle = not playerCycle
				canPress = true
			else:
				ambience.stop()
				gunshotSound.play()
				tableShoot.visible = true
				await get_tree().create_timer(0.05).timeout
				tableBlood.visible = true
				await get_tree().create_timer(1).timeout
				for i in range(3):
					$Player1/Death.visible = not $Player1/Death.visible
					await get_tree().create_timer(.5).timeout
				playerEnd(true,false)
				get_tree().change_scene_to_file("res://scenes/gameComplete.tscn")
		else:
			chosenButton.name = "Pressed"
			pressedButtonsAI = pressedButtonsAI + 1
			table.visible = true
			lightBottom.visible = false
			lightTop.visible = false
			lightSound.play()
			playerCycle = not playerCycle
			canPress = true

# ai rmb press logic
func _aiRmbPress(button):
	if button.get_parent().name == "Player2" and not "Pressed" in button.name:
		table.visible = false
		lightBottom.visible = false
		lightTop.visible = true
		timer.play()
		buttonSound.play()
		button.visible = false
		await get_tree().create_timer(6.0).timeout
		if button.name == "Death":
			ambience.stop()
			deadScreen.visible = true
			gunshotSound.play()
			await get_tree().create_timer(2.5).timeout
			playerEnd(false,true)
			get_tree().change_scene_to_file("res://scenes/gameComplete.tscn")
		else:
			canPress = false
			ambience.stop()
			gunshotSound.play()
			tableShoot.visible = true
			await get_tree().create_timer(0.05).timeout
			tableBlood.visible = true
			await get_tree().create_timer(1).timeout
			for i in range(3):
				$Player1/Death.visible = not $Player1/Death.visible
				await get_tree().create_timer(.5).timeout
			xp = xp + randi_range(600,800)
			playerEnd(true,false)
			get_tree().change_scene_to_file("res://scenes/gameComplete.tscn")


func _aiPress():
	# ai press logic (choosing button to press)
	if playerCycle == false:
		if canPress == true:
			canPress = false
			# if ai has cards, add extra time for card decision
			if aiCards > 0:
				await get_tree().create_timer(randi_range(1,2)).timeout
				if randi_range(1,3) == 2:
					print("Chosen to use card")
					_triggerCardAI()
					cardSound.play()
			await get_tree().create_timer(randi_range(2,4)).timeout
			var unpressed = []
			# sort unpressed into a list so that the ai doesn't press old buttons
			for aiButton in $Player2.get_children():
				if not "Pressed" in aiButton.name:
					unpressed.append(aiButton)
			var chosenButton = unpressed[randi_range(0,len(unpressed)-1)]
			if len(unpressed) <= 2: # if there is 2 or less buttons remaining, the ai will take the chance and pull out a button 
				_aiRmbPress(chosenButton)
			else: # otherwise, it presses lmb
				_aiLMBPress(chosenButton)

func _giveCardPlr():
	# deterministic card placement function and assignment
	if card1.visible == true:
		if card2.visible == true:
			if card3.visible == true:
				pass # 3 cards have been given, don't give more cards
			else:
				card3.visible = true
				cardSound.play()
				var chosenCard = randi_range(1,2)
				if chosenCard == 1:
					cardMenu3.texture = cardType1Tex
					cardMenu3L.text = cardTypes["1"]
					cardMenu3.get_node("AnimationPlayer").play("RESET")
					cardMenu3.visible = true
				elif chosenCard == 2:
					cardMenu3.texture = cardType2Tex
					cardMenu3L.text = cardTypes["2"]
					cardMenu3.get_node("AnimationPlayer").play("RESET")
					cardMenu3.visible = true
				elif chosenCard == 3:
					cardMenu3.texture = cardType3Tex
					cardMenu3L.text = cardTypes["3"]
					cardMenu3.get_node("AnimationPlayer").play("RESET")
					cardMenu3.visible = true
				elif chosenCard == 4:
					cardMenu3.texture = cardType4Tex
					cardMenu3L.text = cardTypes["4"]
					cardMenu3.get_node("AnimationPlayer").play("RESET")
					cardMenu3.visible = true
		else:
			card2.visible = true
			cardSound.play()
			var chosenCard = randi_range(1,2)
			if chosenCard == 1:
				cardMenu2.texture = cardType1Tex
				cardMenu2L.text = cardTypes["1"]
				cardMenu2.get_node("AnimationPlayer").play("RESET")
				cardMenu2.visible = true
			elif chosenCard == 2:
				cardMenu2.texture = cardType2Tex
				cardMenu2L.text = cardTypes["2"]
				cardMenu2.get_node("AnimationPlayer").play("RESET")
				cardMenu2.visible = true
			elif chosenCard == 3:
				cardMenu2.texture = cardType3Tex
				cardMenu2L.text = cardTypes["3"]
				cardMenu2.get_node("AnimationPlayer").play("RESET")
				cardMenu2.visible = true
			elif chosenCard == 4:
				cardMenu2.texture = cardType4Tex
				cardMenu2L.text = cardTypes["4"]
				cardMenu2.get_node("AnimationPlayer").play("RESET")
				cardMenu2.visible = true
	else:
		card1.visible = true
		cardSound.play()
		var chosenCard = randi_range(1,2)
		if chosenCard == 1:
			cardMenu1.texture = cardType1Tex
			cardMenu1L.text = cardTypes["1"]
			cardMenu1.get_node("AnimationPlayer").play("RESET")
			cardMenu1.visible = true
		elif chosenCard == 2:
			cardMenu1.texture = cardType2Tex
			cardMenu1L.text = cardTypes["2"]
			cardMenu1.get_node("AnimationPlayer").play("RESET")
			cardMenu1.visible = true
		elif chosenCard == 3:
			cardMenu1.texture = cardType3Tex
			cardMenu1L.text = cardTypes["3"]
			cardMenu1.get_node("AnimationPlayer").play("RESET")
			cardMenu1.visible = true
		elif chosenCard == 4:
			cardMenu1.texture = cardType4Tex
			cardMenu1L.text = cardTypes["4"]
			cardMenu1.get_node("AnimationPlayer").play("RESET")
			cardMenu1.visible = true


func _giveCardAi():
	# deterministic card placement function for AI's card deck
	if card4.visible == true:
		if card5.visible == true:
			if card6.visible == true:
				pass # 3 cards have been given, don't give more cards
			else:
				card6.visible = true
				cardSound.play()
				aiCards = aiCards + 1 # add to the count of cards that the ai has for the card triggering
		else:
			card5.visible = true
			cardSound.play()
			aiCards = aiCards + 1
	else:
		card4.visible = true
		cardSound.play()
		aiCards = aiCards + 1

# trigger actual card functionality
func _triggerCardPlr(card,cardFake):
	var debounce = false
	if canPress and debounce == false:
		if playerCycle:
			if card.texture == cardType1Tex: # refresh
				debounce = true
				$Player2/Death.name = "TextureButtonReplaced"
				var unpressedOpp = []
				for oppButton in $Player2.get_children():
					if not "Pressed" in oppButton.name:
						unpressedOpp.append(oppButton)
				unpressedOpp.pick_random().name = "Death"
				$Blackbar.get_node("%s/AnimationPlayer" % card.name).play("slideup")
				useCardSound.play()
				await get_tree().create_timer(0.25).timeout
				card.visible = false
				cardFake.visible = false
				$Blackbar.get_node("%s/AnimationPlayer" % card.name).play("RESET")
				xp = xp + randi_range(120,200)
				debounce = false
			elif card.texture == cardType2Tex: # defib
				debounce = true
				defibActivePlr = true
				$Blackbar.get_node("%s/AnimationPlayer" % card.name).play("slideup")
				useCardSound.play()
				await get_tree().create_timer(0.25).timeout
				card.visible = false
				cardFake.visible = false
				$Blackbar.get_node("%s/AnimationPlayer" % card.name).play("RESET")
				xp = xp + randi_range(120,200)
				debounce = false

# ai card trigger logic
func _triggerCardAI():
	aiCards = aiCards - 1
	var chosenCard = randi_range(1,2)
	# if card is refresh
	if chosenCard == 1:
		$Player1/Death.name = "TextureButtonReplaced"
		var unpressedOpp = []
		for oppButton in $Player1.get_children():
			if not "Pressed" in oppButton.name:
				unpressedOpp.append(oppButton)
		unpressedOpp.pick_random().name = "Death"
		xp = xp + randi_range(25,50)
	elif chosenCard == 2: # defib
		defibActiveAI = true
	
	# remove cards from ai deck
	if card6.visible == true:
		card6.visible = false
	elif card5.visible == true:
		card5.visible = false
	elif card4.visible == true:
		card4.visible = false
	

# turn label logic
func turnLabel():
	if playerCycle == true:
		if canPress == true:
			if playerTurnLabel.visible == false:
				playerTurnLabel.visible = true
				aiTurnLabel.visible = false
	else:
		if canPress == true:
			if aiTurnLabel.visible == false:
				playerTurnLabel.visible = false
				aiTurnLabel.visible = true

# player game status data
func playerEnd(winStatus,winType):
	var file = FileAccess.open("res://tempSave.dat",FileAccess.WRITE)
	file.store_var(winStatus)
	file.store_var(winType)
	file.store_var(xp)
	file.close()

func _process(_delta: float) -> void:
	# set xp earned label
	xpEarned.text = "XP Earned: " + str(xp)
	
	# turn label
	turnLabel()
	
	# if the player has pressed 3 buttons, attempt to assign a card.
	if pressedButtons == 3:
		pressedButtons = 0
		_giveCardPlr()
	
	# if the AI has pressed 3 buttons, attempt to assign a card.
	if pressedButtonsAI == 3:
		pressedButtonsAI = 0
		_giveCardAi()
	
	# if it is the bot's turn, trigger ai press logic
	if playerCycle == false:
		if canPress == true:
			_aiPress()
