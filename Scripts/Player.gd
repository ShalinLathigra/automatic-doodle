extends Entity
class_name Player

signal chosen_direction
var shove_dir : Vector2

func _ready():
	._ready()
	texture = colours.get_random_player_image()
	$"%Tentacle".texture = colours.get_random_tentacle_image()

func _process(_delta):
	var new_dir = Vector2()
	var skip = false
	
	# Move inputs
	if Input.is_action_pressed("move_up"):		new_dir=Vector2.UP
	if Input.is_action_pressed("move_down"):	new_dir=Vector2.DOWN
	if Input.is_action_pressed("move_left"):	new_dir=Vector2.LEFT
	if Input.is_action_pressed("move_right"):	new_dir=Vector2.RIGHT
	if Input.is_action_pressed("skip_move"):	
		new_dir=Vector2.ZERO
		skip=true
		
	# Shove inputs
	if Input.is_action_pressed("shove_up"):		shove_dir=Vector2.UP
	if Input.is_action_pressed("shove_down"):	shove_dir=Vector2.DOWN
	if Input.is_action_pressed("shove_left"):	shove_dir=Vector2.LEFT
	if Input.is_action_pressed("shove_right"):	shove_dir=Vector2.RIGHT
	
	var new_pos = lerp($TentacleReticle.position, shove_dir * Pathfinder.TILE_SIZE * 0.5, 0.5)
	$TentacleReticle.position = new_pos
	$TentacleReticle.modulate.a = new_pos.length() 
	if not moving and (new_dir != move_vector or skip):
		move_vector = new_dir
		emit_signal("chosen_direction")

func die():
	change_state(-1)
	$DeathPlayer.play()
	
func advance():
	if state != 0: return
	print("\n------------------------------------------")
	print("PLAYER: ", grid_position)
	# freeze up inputs for now
	moving = true
	last_position = grid_position
	# check for entities + handle shoving/move cancel
	#print("\t Move_vector: ", move_vector)
	_handle_shove_interactions()
	#print("\t Post Shove: ", move_vector)
	var boosting : bool = _check_and_handle_boost_jump()
	#print("\t Post Boost: ", move_vector)
	# ensure there is at least a quarter second of moving/animating
	var timer = get_tree().create_timer(0.25)
	
	# Account for obstructions in the path
	var location_or_false = Pathfinder.movement_invalid(grid_position, move_vector, false)
	if location_or_false: grid_position = location_or_false
	else: grid_position += move_vector
	
	#print("\t Post Grid Correction: ", move_vector)
	# Pick an animation
	var tween : SceneTreeTween
	if boosting:
		tween = _animate_boost_jump()
	else: 
		tween = _animate_move_and_shove()
	if (grid_position != last_position):
		$StepPlayer.play()
	yield (tween, "finished")
	moving = false
	move_vector = Vector2.ZERO
	shove_dir = Vector2.ZERO
	$"%Tentacle".texture = colours.get_random_tentacle_image()
	yield (timer, "timeout")
	print("\t Player End position: ", grid_position)

func _animate_move_and_shove() -> SceneTreeTween:
	# In parallel
	var tween = create_tween().set_parallel(true)
	# Animate body Position towards destination
	tween.tween_property(self, "position", Pathfinder.grid_to_world(grid_position), 0.25) \
		.set_trans(Tween.TRANS_CUBIC) \
		.set_ease(Tween.EASE_OUT) 
		
	# Animate Tentacle?
	if shove_dir != Vector2.ZERO:
		$ImpactPlayer.play()
		# There
		tween.tween_property($"%Tentacle", "position", shove_dir * Pathfinder.TILE_SIZE, 0.1) \
			.set_trans(Tween.TRANS_EXPO) \
			.set_ease(Tween.EASE_OUT)
		# Schlorp back
		tween.chain() \
			.tween_property($"%Tentacle", "position", Vector2.ZERO, 0.4) \
			.set_trans(Tween.TRANS_ELASTIC) \
			.set_ease(Tween.EASE_IN_OUT)
	return tween

func _animate_boost_jump() -> SceneTreeTween:
	# for the boost jump it'll
	var tween = create_tween().set_parallel(true)
	# tentacle schlorp out,
	tween.tween_property($"%Tentacle", "position", shove_dir * Pathfinder.TILE_SIZE, 0.2) \
		.set_trans(Tween.TRANS_EXPO) \
		.set_ease(Tween.EASE_OUT)
	# Animate Position towards destination + tentacle to other side really fast
	tween.chain() \
		.tween_property(self, "position", Pathfinder.grid_to_world(grid_position), 0.15) \
		.set_trans(Tween.TRANS_CUBIC) \
		.set_ease(Tween.EASE_OUT) \
		
	tween.parallel() \
		.tween_property($"%Tentacle", "position", -shove_dir * Pathfinder.TILE_SIZE, 0.1) \
		.set_trans(Tween.TRANS_EXPO) \
		.set_ease(Tween.EASE_OUT)
	# Animate tentacle back to your side
	tween.tween_property($"%Tentacle", "position", Vector2.ZERO, 0.1) \
		.set_trans(Tween.TRANS_ELASTIC) \
		.set_ease(Tween.EASE_OUT)
	return tween

func _handle_shove_interactions() -> void:
	if shove_dir != Vector2.ZERO:
		$TentaclePlayer.play()
	var shove_mod = max(shove_dir.dot(move_vector), 0)
	var pushed = Pathfinder.check_space_for_entities(grid_position, shove_dir, false)
	if pushed:
		move_vector -= move_vector * shove_mod
		pushed.shove(shove_dir + shove_dir * shove_mod)
	
func _check_and_handle_boost_jump() -> bool:
	var boosting = false
	var move_mod = max(move_vector.dot(shove_dir), 0)
	move_vector += move_vector * move_mod
	moving = true
	if move_mod > 0:
		boosting = true
	return boosting
