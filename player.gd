extends Sprite2D

@export var happy: Texture2D
@export var neutral: Texture2D
@export var sad: Texture2D

func update_appearance(health: int) -> void:
	if staminaBar.value <= 30:
		texture = sad
	elif staminaBar.value < 50:
		texture = neutral
	else:
		texture = happy
