extends Resource
class_name AIColours

export(Color) var sleep
export(Color) var flee
export(Color) var attack
export(Color) var object
export(Color) var default

export(Array, Resource) var death_images
export(Array, Resource) var enemy_images
export(Array, Resource) var passive_images
export(Array, Resource) var object_images
export(Array, Resource) var player_images
export(Array, Resource) var tentacle_images

func get_colour_for_state(state : int) -> Color:
	if state == 0:
		return sleep
	if state == 1:
		return flee
	if state == 2:
		return attack
	if state == 3:
		return object
	return default

func rand_array(array: Array):
	randomize()
	array.shuffle()
	return(array[randi() % array.size()])
	
func get_random_death_image() -> Texture:
	return rand_array(death_images)

func get_random_enemy_image() -> Texture:
	return rand_array(enemy_images)

func get_random_passive_image() -> Texture:
	return rand_array(passive_images)

func get_random_object_image() -> Texture:
	return rand_array(object_images)

func get_random_player_image() -> Texture:
	return rand_array(player_images)

func get_random_tentacle_image() -> Texture:
	return rand_array(tentacle_images)
