extends Node2D

var refuel_status = "waiting"  # Ezt az értéket a játék logikája állítja be
var thrust_speed = 0

func _ready():
	pass

func _process(delta):
	if refuel_status == "waiting" and Input.is_action_just_pressed("thrust"):
		thrust_speed = 100000
		print("Thrust speed set to: ", thrust_speed)
