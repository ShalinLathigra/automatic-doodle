extends Entity
class_name Enemy

var near_player : bool
var dir_to_player : Vector2
var check_position : Vector2

func _ready():
	._ready()
	modulate = colours.get_colour_for_state(state)
	texture = colours.get_random_enemy_image()
	
func advance():
	
	# Find move_vector
	# take grid position, add it, convert it to world space
	if state == 0 and Pathfinder.dist_to_player(grid_position) <=5:
		change_state(2)
	
	if not shoved:
		move_vector = Pathfinder.path_to_last_player(grid_position)
	
	var should_die : bool
	if shoved:
		# check if your path includes an obstacle
		var current_position = grid_position
		var shove_direction = move_vector
		if Pathfinder.path_obstructed(current_position, shove_direction):
			should_die = true
			pass
		
	.advance()
	move_vector = Vector2.ZERO
	
	if should_die:
		print("dead!") 
		change_state(-1)
		texture = colours.get_random_death_image()
		show_behind_parent = true
	
	# if your turn ENDS near the player twice in a row, then the player loses
	# i.e. player moves, enemy moves, ends up adjacent
	# player stands still, enemy stands still, they are still adjacent at the end of the next turn
	# possibly clear nearness
	if state > -1:
		near_player = Pathfinder.dist_to_player(grid_position) < 1.1
		var new_dir_to_player : Vector2 = Pathfinder.dir_to_player(grid_position)
		if near_player: 
			if check_position == grid_position and dir_to_player == new_dir_to_player:
				Pathfinder.encounter.lose()
			else:
				dir_to_player = new_dir_to_player
				check_position = grid_position
	print("END GAME STATS: ", check_position, " ", dir_to_player)
			
