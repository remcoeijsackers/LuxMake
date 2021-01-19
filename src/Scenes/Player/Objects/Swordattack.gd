extends KinematicBody2D

var velocity = Vector2(0,0)
var oldvelocity
var hit = false

func explode():
	$CollisionShape2D.call_deferred("set_disabled", true)
	$Area2D/EnemyCollision.call_deferred("set_disabled", true)
	hit = true

func _on_fireball_body_entered(body):
	if body.is_in_group("badguys") and hit == false:
		body.velocity.x = velocity.x
		if body.has_method("fireball_kill"):
			body.call("fireball_kill")
		else: body.call("kill")
		explode()

func _physics_process(delta):
	if $VisibilityNotifier2D.is_on_screen() == false:
		queue_free()
	if hit == false:
		var collision = move_and_collide(velocity * delta)
		oldvelocity = velocity.x
		if collision:
			velocity = velocity.bounce(collision.normal)
			if velocity.x != oldvelocity:
				explode()

