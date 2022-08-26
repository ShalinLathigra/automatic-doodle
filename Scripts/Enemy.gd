extends Entity
class_name Enemy

var near_player : bool
var dir_to_player : Vector2
var check_position : Vector2

var player : Entity

func _ready():
	._ready()
	modulate = colours.get_colour_for_state(state)
	texture = colours.get_random_enemy_image()
	
func startup():
	var ret = .startup()
	player = Pathfinder.encounter.player
	return self
	
func advance():
	if state == -1: return
	# Find move_vector
	# take grid position, add it, convert it to world space
	if state == 0 and Pathfinder.dist_to_player(grid_position) <=5:
		change_state(2)
		for child in get_children():
			if child is Label:
				var tween = create_tween()
				tween.set_ease(Tween.EASE_OUT).tween_property(child, "modulate", Color.white, 0.25)
				tween.set_ease(Tween.EASE_IN).tween_property(child, "modulate", Color(0,0,0,0), 3)
	
	if not shoved and state > 0:
		move_vector = Pathfinder.path_to_last_player(grid_position)
	
	var should_die : bool
	if shoved:
		check_position = Vector2.ZERO
		# check if your path includes an obstacle 
		var current_position = grid_position
		var shove_direction = move_vector
		if Pathfinder.path_obstructed(current_position, shove_direction) or Pathfinder.check_path_for_entities(current_position, shove_direction, false):
			should_die = true
			
		
	.advance()
	move_vector = Vector2.ZERO
	
	if should_die and state >= 0:
		die()
	
	# if your turn ENDS near the player twice in a row, then the player loses
	# i.e. player moves, enemy moves, ends up adjacent
	# player stands still, enemy stands still, they are still adjacent at the end of the next turn
	# possibly clear nearness
	if state > -1:
		near_player = Pathfinder.dist_to_player(grid_position) < 1.1
		var new_dir_to_player : Vector2 = Pathfinder.dir_to_player(grid_position)
		if near_player: 
			if check_position == grid_position and dir_to_player == new_dir_to_player and player.grid_position == player.last_position:
				print("Killed by: ", name)
				var old_position = position
				var tween = create_tween().set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN_OUT)
				tween.tween_property(self, "global_position", global_position + new_dir_to_player * Pathfinder.TILE_SIZE * 0.5, 0.15)
				tween.chain().tween_property(self, "position", old_position, 0.3)
				Pathfinder.encounter.lose()
			else:
				dir_to_player = new_dir_to_player
				check_position = grid_position
	
func die():
	print("dead!") 
	change_state(-1)
	$ImpactPlayer.play()
	$Particles2D.emitting = true
	is_blocking = false
	texture = colours.get_random_death_image()
	show_behind_parent = true
