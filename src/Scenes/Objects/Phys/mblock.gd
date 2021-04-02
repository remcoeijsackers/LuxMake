extends KinematicBody2D

const BOUNCE_LOW = 530
const BOUNCE_HIGH = 1000
const FLOOR = Vector2(0, -1)

var velocity = Vector2()
var wallcling = ""
var on_ground = true
var state = "active"

var cling_to_walls = false
var portable = false

func _ready():
	collision_mask = 31
	collision_layer = 1


func _physics_process(delta):
	if $Control/AnimatedSprite.scale.x == 1: $Control/AnimatedSprite.flip_h = false
	else: $Control/AnimatedSprite.flip_h = true
	if velocity == Vector2(0,0) and cling_to_walls == true: align()
	if get_tree().current_scene.editmode == true: return

	if wallcling == "" and state == "active":
		if portable == true:
			velocity.y += 20
		else: velocity.y += 20 * 2
		velocity = move_and_slide(velocity, FLOOR)

	if is_on_floor():
		if get_tree().current_scene.editmode == true: return
		if state != "active": return
		if on_ground == false:
			$Thud.play()
			$Control/AnimatedSprite.frame = 0
			$Control/AnimatedSprite.play("land")
		on_ground = true
		velocity.x *= 0.9
	else: on_ground = false

	if portable == true and state == "active" and $SolidTimer.time_left == 0:
		var bodies = $GrabRadius.get_overlapping_bodies()
		for body in bodies:
			if body.is_in_group("player"):
				if Input.is_action_pressed("pickup") and body.holding_object == false and body.sliding == false:
					body.holding_object = true
					body.object_held = name
					state = "grabbed"
					collision_mask = 0
					collision_layer = 0

func _on_Area2D_body_entered(body):
	if get_tree().current_scene.editmode == true: return
	if state != "active": return
	if body.is_in_group("player"):
		return


func align():
	$Control.rect_rotation = 0
	#$CollisionShape2D.position = Vector2(0, 2)
	$Area2D/CollisionShape2D.position = Vector2(0, -2)
	$CollisionShape2D.rotation_degrees = 0
	$Area2D/CollisionShape2D.rotation_degrees = 0
	wallcling = ""

	if $LeftWallDetector.is_colliding() and not $RightWallDetector.is_colliding():
		wallcling = "left"
		$Control.rect_pivot_offset.y = -1
		$Control.rect_rotation = 90
		$CollisionShape2D.position.y = 0
		$CollisionShape2D.position.x = -16
		$Area2D/CollisionShape2D.position.y = 0
		$CollisionShape2D.rotation_degrees = $Control.rect_rotation
		$Area2D/CollisionShape2D.rotation_degrees = $Control.rect_rotation

	elif $RightWallDetector.is_colliding() and not $LeftWallDetector.is_colliding():
		wallcling = "right"
		$Control.rect_pivot_offset.y = -1
		$Control.rect_rotation = -90
		$CollisionShape2D.position.y = 0
		$CollisionShape2D.position.x = 16
		$Area2D/CollisionShape2D.position.y = 0
		$CollisionShape2D.rotation_degrees = $Control.rect_rotation
		$Area2D/CollisionShape2D.rotation_degrees = $Control.rect_rotation

	elif $CeilingDetector.is_colliding():
		wallcling = "top"
		$Control.rect_pivot_offset.y = 0
		$Control.rect_rotation = 180
		$CollisionShape2D.position.y = -16
		$Area2D/CollisionShape2D.position.y = -8
		$CollisionShape2D.rotation_degrees = 0
		$Area2D/CollisionShape2D.rotation_degrees = 0

# When thrown by player
func throw():
	state = "active"
	velocity.y = -250
	if Input.is_action_pressed("throw"):
		velocity = Vector2(0,0)
		collision_mask = 31
		collision_layer = 1
	else: $SolidTimer.start(0.25)

func _on_SolidTimer_timeout():
	if state == "active":
		collision_mask = 31
		collision_layer = 1
