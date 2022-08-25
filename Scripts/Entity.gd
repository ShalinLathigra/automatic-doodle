extends Sprite
class_name Entity


export(Resource) var colours_resource
# What do entities do?
# They track a grid position
var grid_position : Vector2
var last_position : Vector2
var move_vector : Vector2
var moving : bool
var shoved : bool
var colours : AIColours
var state : int 
# 0 == idle
# 1 == flee
# 2 == attack

func _ready():
	colours = colours_resource as AIColours
	state = 0
	
func startup():
	grid_position = Pathfinder.world_to_grid(position)
	return self

func advance():
	last_position = grid_position
	var obstruction = Pathfinder.movement_invalid(grid_position, move_vector)
	if state > 0:
		moving = true
		if obstruction: grid_position = obstruction
		else: grid_position += move_vector
		var trans = Tween.TRANS_CUBIC
		var duration = 0.25
		if shoved:
			trans = Tween.TRANS_ELASTIC
			duration = 0.35
		var tween = create_tween().set_trans(trans).set_ease(Tween.EASE_OUT)
		tween.tween_property(self, "position", Pathfinder.grid_to_world(grid_position), duration)
		yield (tween, "finished")
		moving = false
	shoved = false

func change_state(next_state: int):
	state = next_state
	if state > -1:
		modulate = colours.get_colour_for_state(state)
	else:
		texture = colours.get_random_death_image()

func shove(shove_vector : Vector2):
	# find out how far this needs to go, then shove yourself
	shoved = true
	move_vector = shove_vector
