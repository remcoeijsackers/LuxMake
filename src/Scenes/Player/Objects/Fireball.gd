extends KinematicBody2D

var velocity = Vector2(0,0)
var oldvelocity
var hit = false
var wallcling = ""

func _ready():
	collision_mask = 31
	collision_layer = 1

func explode():
	#remove_from_group("bullets")
	$CollisionShape2D.call_deferred("set_disabled", true)
	$Area2D/EnemyCollision.call_deferred("set_disabled", true)
	$AnimationPlayer.play("Hit")
	hit = true

func _on_fireball_body_entered(body):
	if body.is_in_group("badguys") and hit == false:
		body.velocity.x = velocity.x
		if body.has_method("fireball_kill"):
			body.call("fireball_kill")
		else: body.call("kill")
		explode()
	elif body.is_in_group("player"):
		print("test connection player")
		# add the code to hold player
		collision_mask = 31
		collision_layer = 1
		return

func _physics_process(delta):
	if $VisibilityNotifier2D.is_on_screen() == false:
		queue_free()
	if hit == false:
		if velocity.x > 0:
			if $AnimationPlayer.current_animation != "ActiveRight":
				$AnimationPlayer.play("ActiveRight")
		elif $AnimationPlayer.current_animation != "ActiveLeft":
			$AnimationPlayer.play("ActiveLeft")
		velocity.y += 20
		var collision = move_and_collide(velocity * delta)
		oldvelocity = velocity.x
		if collision:
			align()
			$AnimationPlayer.stop()
			collision_mask = 31
			collision_layer = 1
			velocity.y = 0
			velocity.x = 0
			# timer is also handled in player 'shoot' 
		yield(get_tree().create_timer(2.5), "timeout") #memory leak bug
		explode()
			#velocity = velocity.bounce(collision.normal)
			#if velocity.x != oldvelocity:
			#	explode()
			#	$Extinguish.play()
func align():

	wallcling = "right"

	$CollisionShape2D.position.y = 0
	$CollisionShape2D.position.x = 16
	$Area2D/EnemyCollision.position.y = 0
	$CollisionShape2D.rotation_degrees = 0
	$Area2D/EnemyCollision.rotation_degrees = 0

