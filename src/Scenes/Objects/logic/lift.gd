extends StaticBody2D

var speed = 0
var back_speed = 0
var up_speed = 2000
var down_speed = -2000

func _ready():
	pass
	#set_constant_linear_velocity(Vector2(speed,up_speed))

func _physics_process(delta):
	if GameVariables.toggle_state == "on":
		#set_constant_linear_velocity(Vector2(back_speed,down_speed))
		$Control/AnimatedSprite.set_animation("run_back")

	if GameVariables.toggle_state == "off":
		#set_constant_linear_velocity(Vector2(speed,up_speed))
		$Control/AnimatedSprite.set_animation("run")


func _on_Area2D_area_entered(area):
		pass


func _on_Area2D_body_entered(body):
	if body.is_in_group("player"):
		body.bounce(300,300, false)
	if body.is_in_group("badguys"):
		body.bounce(300,300, false)
	#TODO handle objects
