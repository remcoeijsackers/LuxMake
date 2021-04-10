extends "BlockLogic.gd"

#overide physics trigger 
func  apply_central_impulse(_force):
	pass
	
func on_empty_hit():
	if $off_sprite.visible == true:
		GameVariables.toggle_state = "on"
		$on_sprite.set_visible(true)
		#TODO implement toggle signal
		#emit_signal("on")
		print("on")
		$off_sprite.set_visible(false)
	else:
		$on_sprite.set_visible(false)
		GameVariables.toggle_state = "off"
		#emit_signal("off")
		print("off")
		$off_sprite.set_visible(true)			

# Break on buttjump
func _on_Area2D_area_entered(area):
	if area.get_parent().is_in_group("player"):
		pass
