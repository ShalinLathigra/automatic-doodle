extends Node2D

export(NodePath) var _entry_path

onready var camera : Node2D = get_node("Camera2D")
var next_scene = "res://Scenes/Success.tscn"
var encounter : Encounter

var encounters = []

func _ready():
	for child in get_children():
		if child.is_in_group("Encounter"):
			encounters.push_back(child.name)
	change_encounter(get_node(_entry_path))
	Stats.start_time = OS.get_ticks_msec()
	Stats.moves = 0
	Stats.kills = 0

func change_encounter(var new : Node):
	# store new encounter 
	var old = encounter
	encounter = new as Encounter
	encounter.enter_encounter()
	# exit current encounter
	if old:
		old.exit_encounter()
	# tween to the new anchor position
	var tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(encounter, "modulate", Color.white, 0.5).from(Color.black)
	tween.tween_property(camera, "position", encounter.cam_anchor, 0.5)
	#camera.position = encounter.cam_anchor
	if old:
		tween.tween_property(old, "modulate", Color.black, 0.5).from(Color.white)
	yield(tween, "finished")
	
	# set up new encounter
	encounter.connect("advance_encounter", self, "process_next_scene", [1])
	encounter.connect("backtrack_encounter", self, "process_next_scene", [-1])
	encounter.start_encounter()
	
func process_next_scene(var offset : int):
	var current_index = encounters.find(encounter.name)
	if current_index >= 0:
		var next_index = current_index + offset
		if next_index < encounters.size() or next_index < 0:
			change_encounter(get_node(encounters[next_index]))
			return
			
	get_tree().change_scene(next_scene)
