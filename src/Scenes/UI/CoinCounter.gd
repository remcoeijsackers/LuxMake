extends Node

onready var game = get_node("/root/GameVariables")
onready var health = game.player_health

var coins = 0
var offset = 0

const SMOOTH_FACTOR = 5

func _ready():
	offset = 100
	health = 3
	$CoinCounter/CoinCount.text = "0"
	$Health/HealthCount.text = "3"
	
func _process(_delta):
	$CoinCounter.rect_position.x = get_viewport().size.x + offset
	if offset < 2:
		offset = 0
	else: offset *= 0.8
	$CoinCounter/CoinCount.rect_size.x = 0
	$CoinCounter/CoinCount.rect_position.x = -34 - ($CoinCounter/CoinCount.rect_size.x * 0.5)
	$CoinCounter/CoinCount.text = str(coins)
	$Health.rect_position.x = get_viewport().size.x + offset
	$Health/HealthCount.rect_size.x = 0
	$Health/HealthCount.rect_position.x = -34 - ($Health/HealthCount.rect_size.x * 1)
	$Health/HealthCount.text = str(health)
