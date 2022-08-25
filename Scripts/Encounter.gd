extends Node2D
class_name Encounter

export(NodePath) var _map_path
var map : TileMap

var player : Player
var entities = []

var player_ready : bool
var lost : bool

func _ready():
	randomize()
	# Tell the world, this is the new pathfinding node
	map = get_node(_map_path)
	Pathfinder.set_encounter(self)
	
	for e in get_tree().get_nodes_in_group("Entity"):
		entities.push_back((e as Entity).startup())
		if e.is_in_group("Player"):
			player = e as Player
			player.connect("chosen_direction", self, "receive_dir_player", [true])


func tick():
	for e in entities:
		e.advance();

func occupied_at(grid_position: Vector2, player_blocking: bool):
	print("Checking Position: ", grid_position, " blocking: ", player_blocking)
	if player_blocking and player.grid_position == grid_position:
		return player
	else:
		for e in entities:
			if e.state >= 0 and e.grid_position == grid_position and not e.is_in_group("Player"):
				return e
	return false
	
func receive_dir_player(isBody: bool):
	if isBody: player_ready = true
	if player_ready:
		tick()

func lose():
	if not lost:
		print("player dead")
		player.change_state(-1)
		lost = true
