extends Entity
class_name ObjectEntity

export var random : bool = true
export var auto_color : bool = true

func _ready():
	._ready()
	modulate = colours.get_colour_for_state(3)
	if random:
		texture = colours.get_random_object_image()
	
func startup():
	var ret = .startup()
	return self
	
func advance():
	if state == -1: return
	# Find move_vector
	# take grid position, add it, convert it to world space
	
	var should_die : bool
	if shoved:
		# check if your path includes an obstacle 
		var current_position = grid_position
		var shove_direction = move_vector
		should_die = true
		# for each space in this line, if dying, flag it
		var has_hit_entity = Pathfinder.check_path_for_entities(current_position, shove_direction, false)
		if has_hit_entity:
			var entity_hit = Pathfinder.check_space_for_entities(has_hit_entity, shove_direction.normalized(), false)
			if entity_hit is Enemy:
				(entity_hit as Enemy).die()
		
	.advance()
	move_vector = Vector2.ZERO
	
	if should_die and is_blocking:
		print("dead!") 
		change_state(-2)
		texture = colours.get_random_death_image()
		$CrashPlayer.play()
		show_behind_parent = true
		is_blocking = false
	
	# if your turn ENDS near the player twice in a row, then the player loses
	# i.e. player moves, enemy moves, ends up adjacent
	# player stands still, enemy stands still, they are still adjacent at the end of the next turn
	# possibly clear nearness

func shove(shove_vector : Vector2):
	# find out how far this needs to go, then shove yourself
	shoved = true
	move_vector = shove_vector * 8
