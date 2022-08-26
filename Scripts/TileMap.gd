extends TileMap


func _ready():
	print("Here")
	Pathfinder.set_map(self as TileMap)

