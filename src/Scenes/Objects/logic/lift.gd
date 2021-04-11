extends StaticBody2D

var speed = 0
var back_speed = 0
var up_speed = 2000
var down_speed = -2000

func _ready():
	set_constant_linear_velocity(Vector2(speed,up_speed))

func _physics_process(delta):
	if GameVariables.toggle_state == "on":
		set_constant_linear_velocity(Vector2(back_speed,down_speed))
		$Control/AnimatedSprite.set_animation("run_back")

	if GameVariables.toggle_state == "off":
		set_constant_linear_velocity(Vector2(speed,up_speed))
		$Control/AnimatedSprite.set_animation("run")


func _on_Area2D_area_entered(area):
	if area.get_parent().is_in_group("player"):
		pass
