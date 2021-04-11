extends StaticBody2D

var stored = "" # Whatever is inside the bonus block
var childstored = null
var hitdirectionstored = 0
var hitdownstored = false
var player = null


func _ready():
	set_constant_linear_velocity(Vector2(200,0))

