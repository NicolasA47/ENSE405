extends CharacterBody2D

@export var move_speed : int = 250.0	# Global move speed (units per second)
@export var move_speed_modifier : float = 1.0
var is_moving = false	# Boolean to check if the player is moving

var start_position = Vector2()
var end_position = Vector2()
var lerp_t : float = 0.0	# Interpolation weight (0.0 to 1.0)
var direction = Vector2()
var returning = false	# Flag to check if the player is returning to the start

# Define the signal
signal movement_complete
signal returning_started

func _physics_process(delta):
	if is_moving:
		lerp_t += delta * (move_speed*move_speed_modifier) / start_position.distance_to(end_position)
		if lerp_t < 1.0:
			position = start_position.lerp(end_position, lerp_t)
		else:
			if returning:
				is_moving = false
				returning = false
				emit_signal("movement_complete")
			else:
				# Start returning to the starting position
				returning = true
				emit_signal("returning_started")
				var temp = start_position
				start_position = end_position
				end_position = temp
				lerp_t = 0.0

func move_player_to(_start_position, _end_position):
	start_position = _start_position
	end_position = _end_position
	position = start_position	# Set player's position to start
	direction = (end_position - start_position).normalized()
	lerp_t = 0.0
	is_moving = true
	returning = false

func _process(delta):
	if is_moving:
		move_and_slide()
