extends StaticBody2D

var stored = "" # Whatever is inside the bonus block
var childstored = null
var hitdirectionstored = 0
var hitdownstored = false
var player = null


func _ready():
	set_constant_linear_velocity(Vector2(200,0))

func _physics_process(delta):
	if GameVariables.toggle_state == "on":
		set_constant_linear_velocity(Vector2(-200,0))
		$Control/AnimatedSprite.set_animation("run_back")

	if GameVariables.toggle_state == "off":
		set_constant_linear_velocity(Vector2(200,0))
		$Control/AnimatedSprite.set_animation("run")
