extends KinematicBody2D

const FLOOR = Vector2(0, -1)
# Instant speed when starting walk
const WALK_ADD = 120.0
# Speed Tux accelerates per second when walking
const WALK_ACCEL = 350.0
# Speed Tux accelerates per second when running
const RUN_ACCEL = 400.0

# Speed you need to start running
const WALK_MAX = 230.0
# Maximum horizontal speed
var run_max = 320.0
# Backflip horizontal speed
const BACKFLIP_SPEED = -128

# Speed which Tux slows down
const FRICTION = 0.93
# Speed Tux slows down when sliding
const SLIDE_FRICTION = 0.99
# Acceleration when holding the opposite direction
const TURN_ACCEL = 1800.0

# Jump velocity
const JUMP_POWER = 580
# Running Jump / Backflip velocity
const RUNJUMP_POWER = 640
# Amount of frames you can hold jump before landing and still jump
const JUMP_BUFFER_TIME = 15
# Gravity
const GRAVITY = 20.0
# Gravity when buttjumping
const BUTTJUMP_GRAVITY = 120.0
# Amount of frames Tux can still jump after falling off a ledge
const LEDGE_JUMP = 3
# Falling speedcap
const FALL_SPEED = 1280.0
# Buttjumping speedcap
const BUTTJUMP_FALL_SPEED = 2000.0
# How long to stay in the buttjump landing pose
const BUTTJUMP_LAND_TIME = 0.3

# Fireball speed
const FIREBALL_SPEED = 800

const FRICTION_AIR = 0.95		# The friction while airborne
const FRICTION_GROUND = 0.85
const CHAIN_PULL = 200
var shoot_wait = 2
var velocity = Vector2()
var on_ground = 999 # Frames Tux has been in air (0 if grounded)
var jumpheld = 0 # Amount of frames jump has been held
var jumpcancel = false # Can let go of jump to stop vertical ascent
var skidding = false # Skidding
var sliding = false # Sliding
var ducking = false # Ducking
var backflip = false # Backflipping
var backflip_rotation = 0 # Backflip rotation
var buttjump = false # Butt-jumping
var camera_offset = 0 # Moves camera horizontally for extended view
var camera_position = Vector2() # Camera Position
var dead = false # Stop doing stuff if true
var restarted = false # Should Tux call restart level
var invincible_damage = false
var invincible = false
var using_star = false
var holding_object = false
var object_held = ""
var wind = 0

var shooting = false
var swordattack = false

var can_jump = false	
var chain_velocity := Vector2(0,0)
var walk = (Input.get_action_strength("right") - Input.get_action_strength("left")) * WALK_ADD
var JUMP_COUNT = 0
var WALL_JUMP_COUNT = 0
const MAX_JUMP_COUNT = 2
var mouse = get_local_mouse_position()
onready var game = get_node("/root/GameVariables")
onready var health = game.player_health
onready var anim = get_node('AnimationPlayer')

var actiontracker = false

export (int, 0, 200) var push = 100

# Set the players current animation
func set_animation(animation):
	if game.player_state == "small": $Control/AnimatedSprite.play(str(animation, ""))
	else: $Control/AnimatedSprite.play(animation)

func _on_AnimationPlayer_finished():
	anim.stop()
	
# Player Damage
func hurt():
	if invincible_damage == false and invincible == false:
		var health_count = get_tree().get_nodes_in_group("HealthCounter")[0]
		health_count.health -= 1
		game.player_health -= 1
		if game.player_health < 0:
			kill()
		elif game.player_state == "big":
			game.player_health -= 1
			game.player_state = "small"
			backflip = false
			buttjump = false
			ducking = false
			$SFX/Hurt.play()
			$Control/AnimatedSprite.play("hurt")
			damage_invincibility()
			var frame = $Control/AnimatedSprite.frame
			set_animation($Control/AnimatedSprite.animation)
			$Control/AnimatedSprite.frame = frame
		else:
			game.player_state = "big"
			$Control/AnimatedSprite.play("hurt")
			# Hide the fire particles to show the player lost the ability to fire
			$Control/lit.hide()
			$SFX/Hurt.play()
			damage_invincibility()

# Kill the player
func kill():
	invincible = false
	invincible_damage = false
	game.player_state = "small"
	$SFX/Kill.play()
	$AnimationPlayerInvincibility.play("Stop")
	$Control/AnimatedSprite.rotation_degrees = 0
	$Control/AnimatedSprite.scale.x = 1.963
	$AnimationPlayer.play("Stop")
	set_animation("gameover")
	dead = true
	velocity = Vector2 (0,-JUMP_POWER * 1.5)
	game.player_health = 3
	
func _ready():
	position = Vector2(0,0)
	for child in get_tree().current_scene.get_node("Level").get_children():
		if child.is_in_group("spawnpoint"):
			position = child.position
		#if get_tree().current_scene.editmode == false:
		#	if child.is_in_group("toggle_group"):
		#		$toggle.connect("on", $Player, "lit")

#=============================================================================
# PHYSICS
# Grappling Hook Functions
func _input(event: InputEvent) -> void:
	if game.player_state == "hook":
		if event is InputEventMouseButton:
			if event.pressed:
			# We clicked the mouse -> shoot()
				$Chain.shoot(event.position - get_viewport().size * 0.5)
			else:
			# We released the mouse -> release()
				$Chain.release()

func get_input():
	var dir = 0
	if Input.is_action_pressed("move_right"):
		dir += 1
	if Input.is_action_pressed("move_left"):
		dir -= 1
	if dir != 0:
		velocity.x = lerp(velocity.x, dir * velocity.x, WALK_ACCEL)
	else:
		velocity.x = lerp(velocity.x, 0, FRICTION)
			
func _physics_process(delta):
	if GameVariables.toggle_state == "on":
		$Control/lit.set_visible(true)
	if GameVariables.toggle_state == "off":
		$Control/lit.set_visible(false)
	#Hook
	# Hook physics
	if $Chain.hooked:
		# `to_local($Chain.tip).normalized()` is the direction that the chain is pulling
		chain_velocity = to_local($Chain.tip).normalized() * CHAIN_PULL
		if chain_velocity.y > 0:
			# Pulling down isn't as strong
			chain_velocity.y *= 0.55
		else:
			# Pulling up is stronger
			chain_velocity.y *= 1.65
		if sign(chain_velocity.x) != sign(walk):
			# if we are trying to walk in a different
			# direction than the chain is pulling
			# reduce its pull
			chain_velocity.x *= 0.7
	else:
		# Not hooked -> no chain velocity
		chain_velocity = Vector2(0,0)
	velocity += chain_velocity

	velocity.x += walk		# apply the walking
	move_and_slide(velocity, Vector2.UP)	# Actually apply all the forces
	velocity.x -= walk		# take away the walk speed again
	# ^ This is done so we don't build up walk speed over time

	# Manage friction and refresh jump and stuff
	velocity.y = clamp(velocity.y, -run_max, run_max)	# Make sure we are in our limits
	velocity.x = clamp(velocity.x, -run_max, run_max)
	var grounded = is_on_floor()
	if grounded:
		velocity.x *= FRICTION_GROUND	# Apply friction only on x (we are not moving on y anyway)
		can_jump = true 				# We refresh our air-jump
		if velocity.y >= 5:		# Keep the y-velocity small such that
			velocity.y = 5		# gravity doesn't make this number huge
	elif is_on_ceiling() and velocity.y <= -5:	# Same on ceilings
		velocity.y = -5

	# Apply air friction
	if !grounded:
		velocity.x *= FRICTION_AIR
		if velocity.y > 0:
			velocity.y *= FRICTION_AIR
	#end hook

	for index in get_slide_count():
		var collision = get_slide_collision(index)
		if collision.collider.is_in_group("bodies"):
#			var cpos = collision.collider.to_local(collision.position)
			collision.collider.apply_central_impulse(-collision.normal * push)
		else:
			pass
			
	$Hitbox.disabled = get_tree().current_scene.editmode
	if get_tree().current_scene.editmode == true:
		set_animation("idle")
		return
		
	#State, animation after dead
	if dead == true: 
		if Input.is_action_pressed("pause"):
			if restarted == false:
					get_tree().current_scene.call("restart_level")
					restarted = true
		if position.y >= UIHelpers.get_camera().limit_bottom and velocity.y > 0:
			if restarted == false:
				get_tree().current_scene.call("restart_level")
				restarted = true
			self.visible = false
			return
		$Control/AnimatedSprite.z_index = 999
		$Hitbox.disabled = true
		$ButtjumpHitbox/CollisionShape2D.disabled = true
		position += velocity * delta
		velocity.y += GRAVITY
		return
		

	# Horizontal movement
	if (ducking == false or on_ground != 0) and backflip == false and skidding == false and sliding == false and $ButtjumpLandTimer.time_left == 0:
		if Input.is_action_pressed("move_right"):
			$Control/AnimatedSprite.scale.x = 1.963
			swordattack = false

			# Moving
			if velocity.x >= 0:
				if velocity.x < WALK_ADD:
					velocity.x = WALK_ADD
				if abs(velocity.x) > WALK_MAX:
						velocity.x += RUN_ACCEL * delta
				else: velocity.x += WALK_ACCEL * delta

			# Skidding
			elif on_ground == 0 and abs(velocity.x) >= WALK_MAX:
				if !skidding:
					skidding = true

			# Air turning
			else: velocity.x += TURN_ACCEL * delta

		if Input.is_action_pressed("move_left"):
			$Control/AnimatedSprite.scale.x = -1.963
			if velocity.x <= 0:
				swordattack = false

				# Moving
				#$Control/AnimatedSprite.scale.x = -1.963
				if velocity.x > -WALK_ADD:
					velocity.x = -WALK_ADD
				if abs(velocity.x) > WALK_MAX:
						velocity.x -= RUN_ACCEL * delta
				else: velocity.x -= WALK_ACCEL * delta

			# Skidding
			elif on_ground == 0 and abs(velocity.x) >= WALK_MAX:
				if skidding == false:
					skidding = true
					$SFX/Skid.play()

			# Air turning
			else: velocity.x -= TURN_ACCEL * delta

	# Friction
	if backflip == false and (skidding or (ducking and on_ground == 0) or (not Input.is_action_pressed("move_left") and not Input.is_action_pressed("move_right"))):

		# Turn when skidding
		if skidding:
			if velocity.x > 0:
				$Control/AnimatedSprite.scale.x = -1.963
			if velocity.x < 0:
				$Control/AnimatedSprite.scale.x = 1.963

	# Move
	var oldvelocity = velocity
	if on_ground == 0 and wind == 0:
		velocity = move_and_slide_with_snap(velocity, Vector2(0, 20), FLOOR)
	else: velocity = move_and_slide(velocity, FLOOR)
	if abs(velocity.x) > abs(oldvelocity.x) and $ButtjumpLandTimer.time_left > 0:
		pass#start_sliding()

	# Gravity
	if $ButtjumpTimer.time_left > 0:
		velocity *= 0.5
	elif buttjump == false or velocity.y <= 0:
		if on_ground:
			velocity.y += GRAVITY
			if velocity.y > FALL_SPEED: velocity.y = FALL_SPEED
	else:
		if on_ground:
			velocity.y += BUTTJUMP_GRAVITY
			if velocity.y > BUTTJUMP_FALL_SPEED: velocity.y = BUTTJUMP_FALL_SPEED
			
	# Wall Check	
	if is_on_wall():
		if WALL_JUMP_COUNT < MAX_JUMP_COUNT:
			WALL_JUMP_COUNT += 1
			JUMP_COUNT -= 1
		else: 
			JUMP_COUNT = 2
	
	# Allows for jumping from wall to wall
	if not is_on_wall():
		WALL_JUMP_COUNT = 0

	# Floor check
	if is_on_floor():
		WALL_JUMP_COUNT = 0
		if on_ground != 0:
			$AnimationPlayer.stop()
			$AnimationPlayer.playback_speed = 1
			if buttjump == true:
				$AnimationPlayer.play("ButtjumpLand")
				$ButtjumpLandTimer.start(BUTTJUMP_LAND_TIME)
				$SFX/Brick.play()
				buttjump = false
			elif on_ground >= 40:
				$AnimationPlayer.play("Land")
			elif on_ground >= 20:
				$AnimationPlayer.play("LandSmall")
			else:
				$AnimationPlayer.play("Stop")
		# On the floor, reset the jump count
		on_ground = 0
		JUMP_COUNT = 0
		jumpcancel = false
		if backflip == true:
			backflip = false
			velocity.x = 0
	else:
		#in air?
		on_ground += 1
		$ButtjumpLandTimer.stop()

	# Ducking / Sliding
	if on_ground == 0:
		# Stop ducking in certain situations
		if not Input.is_action_pressed("duck"): ducking = false

		# Duck if in one block space
		if $StandWindow.is_colliding() == true and !sliding: ducking = true

		# Ducking / Sliding
		elif Input.is_action_pressed("duck") and !sliding and !skidding and $ButtjumpLandTimer.time_left == 0:
			if abs(velocity.x) < WALK_MAX:
				if game.player_state != "small": ducking = true
			else: pass#start_sliding()
	elif $StandWindow.is_colliding() == true and sliding == false and game.player_state != "small": ducking = true
	else: 
		ducking = false

	# Jump buffering
	if Input.is_action_pressed("jump"):
		jumpheld += 1
	else: jumpheld = 0

	# Jumping
	if Input.is_action_pressed("jump") and jumpheld <= JUMP_BUFFER_TIME:
		if JUMP_COUNT < 2 and $ButtjumpLandTimer.time_left <= BUTTJUMP_LAND_TIME - 0.02:
			JUMP_COUNT += 1
			if Input.is_action_pressed("duck") == true and $StandWindow.is_colliding() == false and sliding == false and $ButtjumpLandTimer.time_left == 0:
				backflip = true
				backflip_rotation = 0
				velocity.y = -RUNJUMP_POWER
				$SFX/Flip.play()
			elif abs(velocity.x) >= run_max or $ButtjumpLandTimer.time_left > 0:
				velocity.y = -RUNJUMP_POWER
			else:
				velocity.y = -JUMP_POWER
			if game.player_state == "small":
				$SFX/Jump.play()
			else: $SFX/BigJump.play()
			on_ground = LEDGE_JUMP + 1
			$AnimationPlayer.playback_speed = 1
			$AnimationPlayer.stop()
			$AnimationPlayer.play("Stop")
			set_animation("jump")
			jumpheld = JUMP_BUFFER_TIME + 1
			on_ground = LEDGE_JUMP + 1
			jumpcancel = true
			sliding = false
			skidding = false
			ducking = false
			if $StandWindow.is_colliding() == true and game.player_state != "small": ducking = true

	# Jump cancelling
	if on_ground != 0 and not Input.is_action_pressed("jump") and backflip == false and jumpcancel == true:
		if velocity.y < 0:
			$AnimationPlayer.playback_speed += 0.3
			velocity.y *= 0.5
		else:
			jumpcancel = false

	# Backflip speed and rotation
	$Control/AnimatedSprite.rotation_degrees = 0
	if backflip == true:
		if $Control/AnimatedSprite.scale.x == 1:
			velocity.x = BACKFLIP_SPEED
			backflip_rotation -= 15
		else:
			velocity.x = -BACKFLIP_SPEED
			backflip_rotation += 15
		$Control/AnimatedSprite.rotation_degrees = backflip_rotation

	# Buttjump
	if on_ground != 0 and Input.is_action_just_pressed("duck") and backflip == false and buttjump == false:
		buttjump = true
		$AnimationPlayer.stop()
		$AnimationPlayer.play("Buttjump")
		$ButtjumpTimer.start(0.15)

	# Stop buttjump if small
	if buttjump == true and game.player_state == "small":
		buttjump = false
		$AnimationPlayer.stop()
		$AnimationPlayer.play("Stop")
		set_animation("fall")

	# Animations
	$Control/AnimatedSprite.speed_scale = 1
	#if abs(velocity.x) == 0 and shooting == false and not Input.is_action_just_pressed("action"):
	#	set_animation("idle")
	if shooting == true:
		set_animation("attack")
	elif swordattack == true:
		set_animation("sword")
	elif buttjump == true:
		set_animation("buttjump")
	elif backflip == true:
		set_animation("backflip")
	elif ducking == true:
		set_animation("duck")
	elif sliding == true:
		set_animation("slide")
	else:
		if on_ground <= LEDGE_JUMP:
			if $ButtjumpLandTimer.time_left > 0:
				set_animation("buttjumpland")
			elif skidding == true:
				set_animation("skid")
			elif abs(velocity.x) >= WALK_ADD / 2:
				$Control/AnimatedSprite.speed_scale = abs(velocity.x) * 0.0035
				if $Control/AnimatedSprite.speed_scale < 0.4:
					$Control/AnimatedSprite.speed_scale = 0.4
				set_animation("walk")
			else: set_animation("idle")
		elif velocity.y > 0:
			if $Control/AnimatedSprite.animation == ("jump") or $Control/AnimatedSprite.animation == ("fall_transition") or  $Control/AnimatedSprite.animation == ("jump_small") or $Control/AnimatedSprite.animation == ("fall_transition_small"):
				set_animation("fall_transition")
			else: set_animation("fall")
		else: set_animation("jump")

	# Duck Hitboxes
	if ducking == true or sliding == true or buttjump == true:
		$Hitbox.shape.extents.y = 15
		$Hitbox.position.y = 17
		$ShootLocation.position.y = 17
	else:
		$Hitbox.shape.extents.y = 31
		$Hitbox.position.y = 1
		$ShootLocation.position.y = 1
	$ShootLocation.position.x = $Control/AnimatedSprite.scale.x * 8

	# Buttjump hitboxes
	if buttjump == true and $ButtjumpTimer.time_left == 0:
		$ButtjumpHitbox/CollisionShape2D.disabled = false

		# Change the buttjump hitbox's size so it always collides before Tux hits the ground
		if velocity.y > 0:
			$ButtjumpHitbox/CollisionShape2D.shape.extents = Vector2(25,16 + (velocity.y * delta))
			$ButtjumpHitbox/CollisionShape2D.position.y = (velocity.y * delta)
		else:
			$ButtjumpHitbox/CollisionShape2D.shape.extents = Vector2(25,16)
			$ButtjumpHitbox/CollisionShape2D.position.y = 0
	else:
		$ButtjumpHitbox/CollisionShape2D.shape.extents = Vector2(0,0)
		$ButtjumpHitbox/CollisionShape2D.disabled = true

	# Shooting
	if Input.is_action_pressed("action") and game.player_state == "fire" and get_tree().get_nodes_in_group("bullets").size() < 3:
		shooting = true
		while shoot_wait > 0:
			$SFX/Shoot.play()
			var fireball = load("res://Scenes/Player/Objects/Fireball.tscn").instance()
			fireball.position = $ShootLocation.global_position
			fireball.velocity = Vector2((FIREBALL_SPEED * $Control/AnimatedSprite.scale.x) + velocity.x,0)
			fireball.add_collision_exception_with(self) # Prevent fireball colliding with player
			get_parent().add_child(fireball) # Shoot fireball as child of player
			# after shooting, reinstate the collision exception
			shoot_wait -= 2
			#fireball.remove_collision_exception_with(self)
		yield(get_tree().create_timer(2), "timeout")
		game.bullets_explode = false
		shoot_wait = 2
		shooting = false
	if Input.is_action_pressed("explode"):
		game.bullets_explode = true
	# Sword attack
	if Input.is_action_pressed("sword"):
		swordattack = true
		var sword = load("res://Scenes/Player/Objects/Swordattack.tscn").instance()
		sword.position = $SwordLocation.global_position
		sword.add_collision_exception_with(self)
		get_parent().add_child(sword)
		#swordattack = false
		#get_parent().remove_child(sword)
		
	# Camera Positioning
	if abs(velocity.x) > WALK_ADD:
		camera_offset += 2 * (velocity.x / abs(velocity.x))
		if abs(camera_offset) >= (get_viewport().size.x * 0.1) * UIHelpers.get_camera().zoom.x:
			camera_offset = (get_viewport().size.x * 0.1) * UIHelpers.get_camera().zoom.x * (camera_offset / abs(camera_offset))
	camera_position.x = camera_position.x + (camera_offset - camera_position.x) / 5
	UIHelpers.get_camera().position = Vector2(position.x + camera_position.x,position.y + camera_position.y)

	# Block player leaving screen
	if position.x <= UIHelpers.get_camera().limit_left + 16:
		position.x = UIHelpers.get_camera().limit_left + 16
		velocity.x = 0
	if position.x >= UIHelpers.get_camera().limit_right - 16:
		position.x = UIHelpers.get_camera().limit_right - 16
		velocity.x = 0
	if position.y >= UIHelpers.get_camera().limit_bottom:
		position.y = UIHelpers.get_camera().limit_bottom
		kill()

	# Carry objects
	if holding_object == true:
		# Set the object's position
		get_tree().current_scene.get_node(str("Level/", object_held)).position = Vector2(position.x + $ShootLocation.position.x, position.y + $ShootLocation.position.y)

		# Set the object's direction
		#if get_tree().current_scene.get_node(str("Level/", object_held)).has_node("Sprite"): get_tree().current_scene.get_node(str("Level/", object_held, "/Sprite")).scale.x = $Control/AnimatedSprite.scale.x * -1
		#if get_tree().current_scene.get_node(str("Level/", object_held)).has_node("AnimatedSprite"): get_tree().current_scene.get_node(str("Level/", object_held, "/AnimatedSprite")).scale.x = $Control/AnimatedSprite.scale.x * -1
		#if get_tree().current_scene.get_node(str("Level/", object_held)).has_node("Control/AnimatedSprite"): get_tree().current_scene.get_node(str("Level/", object_held, "/Control/AnimatedSprite")).scale.x = $Control/AnimatedSprite.scale.x * -1

		# Throw objects
		if not Input.is_action_pressed("pickup"):
			$Control/AnimatedSprite.play("attack")
			holding_object = false
			if get_tree().current_scene.get_node(str("Level/", object_held)).has_method("throw"):
				get_tree().current_scene.get_node(str("Level/", object_held)).throw()
				if not Input.is_action_pressed("duck"): get_tree().current_scene.get_node(str("Level/", object_held)).velocity.x = velocity.x + (200 * $Control/AnimatedSprite.scale.x)

# Star invincibility
func star_invincibility():
	using_star = true
	invincible = true
	self.show()
	$InvincibilityTimer.start(14)
	get_tree().current_scene.play_music("invincible.ogg")
	$AnimationPlayerInvincibility.stop()
	$AnimationPlayerInvincibility.play("InvincibleStar")

# Damage invincibility
func damage_invincibility():
	invincible_damage = true
	$InvincibilityTimer.start(1.8)
	$AnimationPlayerInvincibility.stop()
	$AnimationPlayerInvincibility.play("HurtInvincibility")

func _on_InvincibilityTimer_timeout():
	invincible = false
	invincible_damage = false
	using_star = false
	self.show()
	$AnimationPlayerInvincibility.stop()
	$AnimationPlayerInvincibility.play("Stop")

# Bounce off squished enemies
func bounce(low, high, cancellable):
	on_ground = LEDGE_JUMP + 1
	sliding = false
	backflip = false
	buttjump = false
	on_ground = LEDGE_JUMP + 1
	$ButtjumpTimer.stop()
	$ButtjumpLandTimer.stop()
	$AnimationPlayer.play("Stop")
	$Control/AnimatedSprite.play("jump")
	set_animation("jump")
	if jumpheld > 0:
		velocity.y = -high
		jumpcancel = cancellable
	else:
		velocity.y = -low
		jumpcancel = false

func lit():
	print("lit used")
	if $Control/lit.visible == true:
		print("turning off")
		$Control/lit.set_visible(false)
	else: 
		$Control/lit.set_visible(true)
		print("turning on")
