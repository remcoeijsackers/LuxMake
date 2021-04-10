extends "res://Scenes/Objects/Phys/mblock.gd"
var velocity_mov = Vector2(1,1)

func _ready():
	cling_to_walls = true

#func _on_Area2D_body_entered(body):
#	if get_tree().current_scene.editmode == true: return
#	if body.is_in_group("player"): #sliding when touching the player
#		return
#		cling_to_walls = false
#		velocity = velocity(velocity_mov)
