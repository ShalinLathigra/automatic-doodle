extends Node2D

export(NodePath) var target_label_path
onready var target = get_node(target_label_path) as Label

func _process(delta):
	# calculate dist to player vs 64. Fade out tex
	var dist_to_player = ($"%Player".position - position).length() / 64.0
	target.modulate.a = 1.0 - min(dist_to_player, 1.0)
