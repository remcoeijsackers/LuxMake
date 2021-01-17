extends Node2D

var childstored = null
var stored = "" # Whatever is inside the bonus block
var gravity = false
export var physics = false

func _ready():
	if get_tree().current_scene.editmode == false:
		for child in get_tree().current_scene.get_node("Level").get_children():
			if child.position == position and child.get_name() != self.get_name() and not child.is_in_group("layers") and not child.is_in_group("expandable") and not child.is_in_group("stackable"):
				stored = child.filename
				childstored = load(str(stored)).instance()
				childstored.position = position
				child.queue_free()
	else:
		physics = true

func _physics_process(delta):
	if get_tree().current_scene.editmode == true: return
