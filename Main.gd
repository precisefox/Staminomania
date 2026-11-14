extends Node2D

var batteryScene = preload("res://Battery.tscn")
func spawn_batteries(amount: int):
	print("Available spaces: ", gameSpaces.size())

	var available_spots = gameSpaces.duplicate()
	available_spots.shuffle()

	for i in range(min(amount, available_spots.size())):
		var battery = batteryScene.instantiate()
		add_child(battery)
		battery.global_position = available_spots[i].global_position



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

	for i in range(1, 193):
		var spot = get_node_or_null("Spot" + str(i))

		if spot != null:
			gameSpaces.append(spot)

	numberOfSpaces = gameSpaces.size()

	print("Total spaces: ", numberOfSpaces)
	print(gameSpaces.size())
	print(gameSpaces)
	spawn_batteries(10)
	for i in range(1, 192):
		gameSpaces.append(get_node("Spot" + str(i)))
	numberOfSpaces = gameSpaces.size()
	staminaLabel.text = str(int(stamina)) + "/" + str(int(maxStamina))

func _unhandled_input(event: InputEvent) -> void:
	var tween = create_tween()
	if stamina >= movementCost:
		moveUp(tween)
		moveDown(tween)
		moveLeft(tween)
		moveRight(tween)
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
