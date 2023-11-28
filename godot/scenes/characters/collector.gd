extends CharacterBody2D

@export var move_speed : int = 250.0	# Global move speed (units per second)
@export var move_speed_modifier : float = 1.0
var is_moving = false	# Boolean to check if the player is moving

var start_position = Vector2()
var end_position = Vector2()
var lerp_t : float = 0.0	# Interpolation weight (0.0 to 1.0)
var direction = Vector2()
var returning = false	# Flag to check if the player is returning to the start
var last_direction = Vector2.ZERO

# Define the signal
signal movement_complete
signal returning_started

func update_animation():
	var current_direction = (end_position - start_position).normalized()
	# Check if the direction has changed since the last frame
	if current_direction != last_direction:
		last_direction = current_direction
		play_animation_based_on_direction(current_direction)

func play_animation_based_on_direction(direction):
	# Determine the direction of movement and play the corresponding animation
	if abs(direction.x) > abs(direction.y):
		if direction.x > 0:
			$AnimationPlayer.play("run_right")
		else:
			$AnimationPlayer.play("run_left")
	else:
		if direction.y > 0:
			$AnimationPlayer.play("run_down")
		else:
			$AnimationPlayer.play("run_up")


func _physics_process(delta):
	if is_moving:
		lerp_t += delta * (move_speed*move_speed_modifier) / start_position.distance_to(end_position)
		if lerp_t < 1.0:
			position = start_position.lerp(end_position, lerp_t)
			update_animation()
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

