extends "BlockLogic.gd"
signal on
signal off
#overide physics trigger 
func  apply_central_impulse(_force):
	pass
	
func on_empty_hit():
	if $off.visible == true:
		$on.set_visible(true)
		#TODO implement toggle signal
		emit_signal("on")
		$off.set_visible(false)
	else:
		$on.set_visible(false)
		emit_signal("off")
		$off.set_visible(true)			

# Break on buttjump
func _on_Area2D_area_entered(area):
	if area.get_parent().is_in_group("player"):
		pass
