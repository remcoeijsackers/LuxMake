extends "BlockLogic.gd"
signal on
signal off
#overide physics trigger 
func  apply_central_impulse(_force):
	pass
	
func on_empty_hit():
	if $off_sprite.visible == true:
		$on_sprite.set_visible(true)
		#TODO implement toggle signal
		emit_signal("on")
		print("on")
		$off_sprite.set_visible(false)
	else:
		$on_sprite.set_visible(false)
		emit_signal("off")
		print("off")
		$off_sprite.set_visible(true)			

# Break on buttjump
func _on_Area2D_area_entered(area):
	if area.get_parent().is_in_group("player"):
		pass
