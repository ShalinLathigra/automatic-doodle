extends Node2D
class_name Encounter

signal advance_encounter
signal backtrack_encounter

export(NodePath) var _map_path

var next_scene_trigger
var last_scene_trigger
var map : TileMap
var cam_anchor : Vector2

var player : Player
var entities = []

var player_ready : bool
var lost : bool
var encounter_started : bool
var in_encounter : bool

func _ready():
	randomize()
	# Tell the world, this is the new pathfinding node
	map = get_node(_map_path)
	Pathfinder.set_encounter(self)
	next_scene_trigger = (get_node("NextScene") as Node2D).global_position
	last_scene_trigger = (get_node("LastScene") as Node2D).global_position
	cam_anchor = (get_node("./CameraAnchor") as Node2D).position + position
	
	player = get_tree().get_nodes_in_group("Player")[0] as Player
	player.connect("chosen_direction", self, "receive_dir_player", [true])
	for child in get_children():
		if child.is_in_group("Entity"):
			entities.push_back(child as Entity)
			
	Pathfinder.clear_encounter()
		
func enter_encounter():
	Pathfinder.set_encounter(self)
	in_encounter = true

func start_encounter():
	player.startup()
	for entity in entities:
		entity.startup()
		print(entity.grid_position)
	encounter_started = true
	print("Starting Encounter: ", name, player.grid_position)
	
func exit_encounter():
	encounter_started = false
	in_encounter = false

func tick():
	player.advance()
	for e in entities:
		e.advance()

func _process(delta):
	if not in_encounter: return
	var player_position_delta = player.global_position - next_scene_trigger
	if player_position_delta.length_squared() < pow(Pathfinder.TILE_SIZE, 2):
		emit_signal("advance_encounter")
		
	player_position_delta = player.global_position - last_scene_trigger
	if player_position_delta.length_squared() < pow(Pathfinder.TILE_SIZE, 2):
		emit_signal("backtrack_encounter")

func occupied_at(grid_position: Vector2, player_blocking: bool):
	if player_blocking and player.grid_position == grid_position:
		return player
	else:
		for e in entities:
			if e.is_blocking and e.grid_position == grid_position and not e.is_in_group("Player"):
				return e
	return false
	
func receive_dir_player(isBody: bool):
	if not encounter_started: return
	if isBody: player_ready = true
	if player_ready:
		tick()

func lose():
	if not lost:
		print("player dead")
		player.die()
		lost = true
