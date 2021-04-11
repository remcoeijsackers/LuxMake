extends KinematicBody2D

var stored = "" # Whatever is inside the bonus block
var childstored = null
var hitdirectionstored = 0
var hitdownstored = false
var player = null


func _ready():
	if get_tree().current_scene.editmode == false:
		for child in get_tree().current_scene.get_node("Level").get_children():
			if child.position == position and child.get_name() != self.get_name() and not child.is_in_group("layers") and not child.is_in_group("expandable") and not child.is_in_group("stackable"):
				stored = child.filename
				childstored = load(str(stored)).instance()
				childstored.position = position
				child.queue_free()

func _physics_process(delta):
	if GameVariables.toggle_state == "on":
		$spike_point.set_visible(true)
		$Area2D/point_collision.set_disabled(false)
		$Area2D.set_visible(false)
		get_node("point_collision2").disabled = false

	if GameVariables.toggle_state == "off":
		$spike_point.set_visible(false)
		$Area2D/point_collision.set_disabled(true)
		$Area2D.set_visible(true)
		get_node("point_collision2").disabled = true

#overide physics trigger 
func  apply_central_impulse(_force):
	pass

# Break on buttjump
func _on_Area2D_area_entered(area):
	if area.get_parent().is_in_group("player"):
		player = area
		
	if area.get_parent().has_method("hurt"):
		area.get_parent().hurt()
	if area.get_parent().is_in_group("badguys"):
		area.get_parent().kill()


func _on_Area2D_body_entered(body):
	if body.get_parent().is_in_group("player"):
		player = body
		if body.has_method("hurt"):
			body.hurt()
	if body.get_parent().is_in_group("badguys"):
		body.get_parent().kill()
