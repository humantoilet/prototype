# RefuelZone.gd - Végleges, időzítős, állapotgép alapú verzió
extends Area2D

# --- BEÁLLÍTÁSOK ---
@export var refuel_rate: float = 25.0
@export var stationary_speed_threshold: float = 5.0
@export var wait_time_to_refuel: float = 2.0

# --- CSOMÓPONT HIVATKOZÁSOK ---
@onready var refuel_timer: Timer = $RefuelTimer

# --- ÁLLAPOTGÉP ---
enum State { IDLE, WAITING, REFUELING }
var current_state: State = State.IDLE

# --- BELSŐ VÁLTOZÓ ---
var rocket_in_zone: RigidBody2D = null


func _ready() -> void:
	refuel_timer.wait_time = wait_time_to_refuel
	refuel_timer.one_shot = true


# --- JELZÉSKEZELŐ FUNKCIÓK ---

func _on_body_entered(body):
	if body.is_in_group("player"):
		rocket_in_zone = body
		set_state(State.WAITING)

func _on_body_exited(body):
	if body == rocket_in_zone:
		rocket_in_zone = null
		set_state(State.IDLE)

func _on_refuel_timer_timeout():
	if current_state == State.WAITING:
		set_state(State.REFUELING)


# --- KÖZPONTI LOGIKA ---

func set_state(new_state: State):
	if new_state == current_state: return
	
	current_state = new_state
	
	match new_state:
		State.IDLE:
			refuel_timer.stop()
		State.WAITING:
			refuel_timer.start()
		State.REFUELING:
			# Töltéskor nincs külön teendő, a fizikai ciklus veszi át.
			pass

func _physics_process(delta: float):
	if current_state == State.IDLE:
		return

	if not is_instance_valid(rocket_in_zone):
		set_state(State.IDLE)
		return

	var is_moving_too_fast = rocket_in_zone.linear_velocity.length() > stationary_speed_threshold

	match current_state:
		State.WAITING:
			if is_moving_too_fast:
				# Ha várakozás közben megmozdul, a timer újraindul.
				refuel_timer.start()
				
		State.REFUELING:
			if is_moving_too_fast:
				# Ha töltés közben megmozdul, a töltés megszakad,
				# és újra várakoznia kell.
				set_state(State.WAITING)
				return

			# Ha minden rendben, akkor töltsünk.
			rocket_in_zone.refuel(refuel_rate * delta)
