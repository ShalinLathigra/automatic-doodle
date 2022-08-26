extends Node2D

func _process(delta):
	# calculate dist to player vs 64. Fade out tex
	var dist_to_player = ($"%Player".position - position).length() / 64.0
	modulate.a = min(dist_to_player, 1.0)
