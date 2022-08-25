extends Sprite


func _process(_delta):
	position = Pathfinder.snap_to_grid(get_viewport().get_mouse_position())
	$Label.text = str(Pathfinder.world_to_grid(get_viewport().get_mouse_position()))

# potentially used to display heads up info if I get to it!
