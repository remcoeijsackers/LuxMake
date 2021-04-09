extends KinematicBody2D

var velocity = Vector2(0,0)
var oldvelocity
var hit = false
var wallcling = ""
var time_done = false
signal timer_end
onready var game = get_node("/root/GameVariables")

func _wait( seconds ):
	self._create_timer(self, seconds, true, "_emit_timer_end_signal")
	yield(self,"timer_end")

func _emit_timer_end_signal():
	emit_signal("timer_end")

func _create_timer(object_target, float_wait_time, bool_is_oneshot, string_function):
	var timer = Timer.new()
	timer.set_one_shot(bool_is_oneshot)
	timer.set_timer_process_mode(0)
	timer.set_wait_time(float_wait_time)
	timer.connect("timeout", object_target, string_function)
	self.add_child(timer)
	timer.start()
	time_done = true
	
func _ready():
	collision_mask = 31
	collision_layer = 1

func explode():
	#remove_from_group("bullets")
	$CollisionShape2D.call_deferred("set_disabled", true)
	$Area2D/EnemyCollision.call_deferred("set_disabled", true)
	$AnimationPlayer.play("Hit")
	game.bullets_explode = false
	hit = true

func _on_fireball_body_entered(body):
	if body.is_in_group("badguys") and hit == false:
		body.velocity.x = velocity.x
		if body.has_method("fireball_kill"):
			body.call("fireball_kill")
		else: body.call("kill")
		explode()
	if body.is_in_group("player"):
		print("test connection player")
		# add the code to hold player
		collision_mask = 31
		collision_layer = 1
		return
	if body.is_in_group("bullets"):
		return
func _get_scene():
	return get_tree().current_scene
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
			remove_collision_exception_with(_get_scene().get_node("Player"))
			align()
			$AnimationPlayer.stop()
			collision_mask = 31
			collision_layer = 1
			velocity.y = 0
			velocity.x = 0
			time_done = false
		if game.bullets_explode:
			explode()
			

		
			# timer is also handled in player 'shoot' 
		#yield(get_tree().create_timer(2.5), "timeout") #memory leak bug
		
		
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

