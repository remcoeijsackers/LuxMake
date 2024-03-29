extends KinematicBody2D

var hit = false
var hitdirection = 0
var stored = "" # Whatever is inside the bonus block
var childstored = null
var hitdirectionstored = 0
var hitdownstored = false
var player = null
var hitbyplayer = false

# To be overridden by sub-classes
func on_empty_hit():
	pass

func _ready():
	if get_tree().current_scene.editmode == false:
		for child in get_tree().current_scene.get_node("Level").get_children():
			if child.position == position and child.get_name() != self.get_name() and not child.is_in_group("layers") and not child.is_in_group("expandable") and not child.is_in_group("stackable"):
				stored = child.filename
				childstored = load(str(stored)).instance()
				childstored.position = position
				child.queue_free()

func _on_Area2D_body_entered(body):
	if body.is_in_group("player"):
		player = body
		hitbyplayer = true
		if body.position.y > position.y:
			if body.position.x > self.position.x:
				hit(-0.1,false)
			else: hit(0.1,false)

		elif body.buttjump == true or body.get_node("ButtjumpLandTimer").time_left > 0:
			if body.position.x > self.position.x:
				hit(-1,true)
			else: hit(1,true)

# Hit the block
func hit(hitdirection, hitdown):
	if hit == true: return

	hitdirectionstored = hitdirection
	hitdownstored = hitdown
	hit = true

	# Spawn contents
	if stored != "":
		if childstored.get("player"):
			childstored.player = player

		$AnimatedSprite.play("empty")
		if hitdown == true:
			$AnimationPlayer.play("hitdown")
		else: $AnimationPlayer.play("hit")

		if childstored.get("collect_on_appear") == true:
			if childstored.collect_on_appear == false:
				$Upgrade.play()

				if hitdown == true:
					childstored.position.y += 32
				else: childstored.position.y -= 32

			else: $Brick.play()
		else:
			$Upgrade.play()

			if hitdown == true:
				childstored.position.y += 32
			else: childstored.position.y -= 32

		get_tree().current_scene.get_node("Level").add_child(childstored)
		if childstored.has_method("appear"):
			childstored.appear(hitdirection,hitdown)
	else:
		$Brick.play()
		on_empty_hit()

# Kill enemies on top of block
func _on_TopHitbox_area_entered(area):
	if area.get_parent().is_in_group("badguys"):
		area.get_parent().kill()
	if area.get("collect_on_appear"):
		if area.get_parent().collect_on_appear:
			area.get_parent().appear(0,false)

func _on_TopHitbox_body_entered(body):
	if body.is_in_group("bonusblock") and body.name != name:
		body.hit(hitdirectionstored,hitdownstored)

#func _support(body):
#	if body.is_in_group("bonusblock")
