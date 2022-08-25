extends Node2D

export(NodePath) var _encounter_path

onready var encounter = get_node(_encounter_path) as Encounter

func _ready():
	print(encounter)

