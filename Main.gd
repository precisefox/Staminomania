extends Node2D

@export var happy: Texture2D
@export var neutral: Texture2D
@export var sad: Texture2D
@export var dead: Texture2D

@export var finish_texture: Texture2D
var finish_spot: Node = null
var game_won: bool = false

var batteryScene = preload("res://Battery.tscn")
var batteries: Dictionary = {}

func spawn_batteries(amount: int):
	var available_spots = gameSpaces.duplicate()
	available_spots.shuffle()
	var battery_count = min(amount, available_spots.size() - 1)
	
	for i in range(min(amount, available_spots.size())):
		var spot = available_spots[i]
		var battery = batteryScene.instantiate()
		add_child(battery)
		battery.global_position = spot.global_position
		batteries[spot] = battery # Save battery to this spot
	finish_spot = available_spots[battery_count]
	var finish_node = Sprite2D.new()
	finish_node.texture = finish_texture
	add_child(finish_node)
	finish_node.global_position = finish_spot.global_position


# stamina bar
@onready var staminaBar : ProgressBar = $CanvasLayer/StaminaBar
@onready var staminaLabel : Label = $CanvasLayer/StaminaLabel

var maxStamina : float = 10
var stamina : float = 10
var movementCost : int = 1



# movement and stuff
@onready var player : Sprite2D = $Player
@export var gameSpaces : Array[Node]
var place : int = 0
var numberOfSpaces : int
var boardWidth : int = 24
var boardHeight : int = 8
var canMove : bool = true

func _ready() -> void:
	gameSpaces.clear()

	# 1. Add the "Start" node first so it becomes index 0 (column 1)!
	var start_spot = get_node_or_null("Start")
	if start_spot != null:
		gameSpaces.append(start_spot)

	# 2. Now add Spot1 through Spot191
	for i in range(1, 192):
		var spot = get_node_or_null("Spot" + str(i))
		if spot != null:
			gameSpaces.append(spot)

	numberOfSpaces = gameSpaces.size()
	spawn_batteries(10)
	staminaLabel.text = str(int(stamina)) + "/" + str(int(maxStamina))
	$Player.texture = happy
	player.position = gameSpaces.front().position
	$CanvasLayer/WinLabel.visible = false
	
func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("retry"):
		get_tree().reload_current_scene()
		return
	if gameSpaces[place] == finish_spot and not game_won:
		if batteries.is_empty():
			game_won = true
			canMove = false
			$CanvasLayer/WinLabel.visible = true
		else:
			print("Batteries left: ", batteries.size())

	
	var tween = create_tween()
	if stamina >= movementCost and not game_won:
		moveUp(tween)
		moveDown(tween)
		moveLeft(tween)
		moveRight(tween)

	# 1. Check if the space we are standing on has a battery
	var current_spot = gameSpaces[place]
	if batteries.has(current_spot):
		batteries[current_spot].queue_free() # Delete the battery sprite
		batteries.erase(current_spot)        # Forget this spot so we don't collect it twice
		stamina = min(stamina + 6, maxStamina)
		staminaBar.value = stamina
		staminaLabel.text = str(int(stamina)) + "/" + str(int(maxStamina))

	# 2. Update the player's face
	if staminaBar.value == 0:
		$Player.texture = dead
	elif staminaBar.value <= 3:
		$Player.texture = sad
	elif staminaBar.value <= 7:
		$Player.texture = neutral
	else:
		$Player.texture = happy
func moveUp(tween):
	if Input.is_action_just_pressed("up") and place >= boardWidth and canMove:
		canMove = false;
		stamina -= movementCost
		staminaBar.value = stamina
		staminaLabel.text = str(int(stamina)) + "/" + str(int(maxStamina))
		place -= 24
		tween.tween_property(player, "position", gameSpaces[place].position, 0.1)
		await get_tree().create_timer(0.2).timeout
		canMove = true
	elif place >= numberOfSpaces:
		print("place is out of bounds")
func moveDown(tween):
	if Input.is_action_just_pressed("down") and place <= gameSpaces.size() - boardWidth - 1 and canMove:
		canMove = false;
		stamina -= movementCost
		staminaBar.value = stamina
		staminaLabel.text = str(int(stamina)) + "/" + str(int(maxStamina))
		place += 24
		tween.tween_property(player, "position", gameSpaces[place].position, 0.1)
		await get_tree().create_timer(0.2).timeout
		canMove = true
	elif place >= numberOfSpaces:
		print("place is out of bounds")
func moveLeft(tween):
	if Input.is_action_just_pressed("left") and place % boardWidth != 0 and canMove:
		canMove = false;
		stamina -= movementCost
		staminaBar.value = stamina
		staminaLabel.text = str(int(stamina)) + "/" + str(int(maxStamina))
		place -= 1
		tween.tween_property(player, "position", gameSpaces[place].position, 0.1)
		await get_tree().create_timer(0.2).timeout
		canMove = true
	elif place >= numberOfSpaces:
		print("place is out of bounds")
func moveRight(tween):
	if Input.is_action_just_pressed("right") and place % boardWidth != boardWidth - 1 and canMove:
		canMove = false;
		stamina -= movementCost
		staminaBar.value = stamina
		staminaLabel.text = str(int(stamina)) + "/" + str(int(maxStamina))
		place += 1
		tween.tween_property(player, "position", gameSpaces[place].position, 0.1)
		await get_tree().create_timer(0.2).timeout
		canMove = true
	elif place >= numberOfSpaces:
		print("place is out of bounds")
