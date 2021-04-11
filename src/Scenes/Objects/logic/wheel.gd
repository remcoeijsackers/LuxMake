extends StaticBody2D

var stored = "" # Whatever is inside the bonus block
var childstored = null
var hitdirectionstored = 0
var hitdownstored = false
var player = null
var speed = 200
var back_speed = -200
var up_speed = 0
var down_speed = 0

func _ready():
	set_constant_linear_velocity(Vector2(speed,up_speed))

func _physics_process(delta):
	if GameVariables.toggle_state == "on":
		set_constant_linear_velocity(Vector2(back_speed,down_speed))
		$Control/AnimatedSprite.set_animation("run_back")

	if GameVariables.toggle_state == "off":
		set_constant_linear_velocity(Vector2(speed,up_speed))
		$Control/AnimatedSprite.set_animation("run")
