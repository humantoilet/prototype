extends RigidBody2D
class_name Rocket

# --- ÉLETERŐ ÉS SÉRÜLÉS ---
@export_group("Health and Destruction")
@export var max_health: float = 100.0
@export var crash_speed_threshold: float = 1.0

# --- ÜZEMANYAG ---
@export_group("Fuel System")
@export var max_fuel: float = 100.0
@export var main_thrust_fuel_consumption: float = 3.0
@export var side_thruster_fuel_consumption: float = 1.0

# --- FŐHAJTÓMŰ ---
@export_group("Main Thruster")
@export var max_main_thrust: float = 3500.0
@export var min_main_thrust: float = 0.0
@export var thrust_ramp_up_time: float = 2.0
@export var main_thruster_offset: Vector2 = Vector2(0, 50)

# --- OLDAL THRUSTEREK ---
@export_group("Side Thrusters")
@export var side_thruster_force: float = 50.0
@export var side_thruster_offset_x: float = 25.0
@export var side_thruster_offset_y: float = 10.0

# --- LAUNCH BOOST ---
@export_group("Launch Boost")
@export var launch_boost_force: float = 10000.0
@export var launch_boost_sideways_force: float = 0.0
@export var launch_boost_rotation_impulse_strength: float = 50.0 # <--- ÚJ: A boost forgató hatásának erőssége
@export var launch_boost_time: float = 0.25
@export var stationary_threshold: float = 5.0

var is_launch_boosting: bool = false
var is_inside_refuel_zone: bool = false
var can_launch_boost: bool = false
var boost_timer: Timer
var current_main_thrust: float
var current_fuel: float
var current_health: float
var is_destroyed: bool = false

# --- LÁNGOK ---
@onready var main_flame_polygon: Polygon2D = $Flame
@onready var left_thruster_flame: Polygon2D = $LeftThrusterFlame
@onready var right_thruster_flame: Polygon2D = $RightThrusterFlame

func _ready() -> void:
	current_health = max_health
	current_fuel = max_fuel
	current_main_thrust = min_main_thrust

	if main_flame_polygon: main_flame_polygon.visible = false
	if left_thruster_flame: left_thruster_flame.visible = false
	if right_thruster_flame: right_thruster_flame.visible = false

	# Boost timer
	boost_timer = Timer.new()
	boost_timer.one_shot = true
	add_child(boost_timer)
	boost_timer.timeout.connect(_on_boost_timeout)

func _on_boost_timeout():
	is_launch_boosting = false

# --- ÚJ FÜGGVÉNY AZ ÚJRAINDÍTÁSHOZ ---
func _process(delta: float) -> void:
	# Játék újraindítása az 'r' billentyű lenyomására
	if Input.is_action_just_pressed("restart"):
		get_tree().reload_current_scene()

func _physics_process(delta: float) -> void:
	if is_destroyed:
		return

	# --- NYUGALMI ÁLLAPOT ELLENŐRZÉSE ---
	if linear_velocity.length() <= stationary_threshold:
		can_launch_boost = true
	else:
		can_launch_boost = false

	# --- LAUNCH BOOST ---
	if can_launch_boost and Input.is_action_just_pressed("thrust") and is_inside_refuel_zone:
		# Lineáris (elmozduló) impulzus
		var boost_vector = Vector2(launch_boost_sideways_force, -launch_boost_force)
		var boost_impulse = boost_vector.rotated(rotation)
		apply_central_impulse(boost_impulse)
		
		# MÓDOSÍTVA: Forgatónyomaték-impulzus hozzáadása az oldalirányú erő alapján
		# Ez elfordítja a hajót a lökés irányába.
		if launch_boost_sideways_force != 0.0:
			var rotation_impulse = launch_boost_sideways_force * launch_boost_rotation_impulse_strength
			apply_torque_impulse(rotation_impulse)

		is_launch_boosting = true
		can_launch_boost = false
		boost_timer.start(launch_boost_time)
		print("Launch boost applied! Impulse: ", boost_impulse)


	# --- FŐ VEZÉRLÉS ---
	handle_rotation(delta)
	handle_main_thrust(delta)

func handle_rotation(delta: float) -> void:
	left_thruster_flame.visible = false
	right_thruster_flame.visible = false

	if current_fuel <= 0:
		return

	if Input.is_action_pressed("rotate_left"):
		current_fuel -= side_thruster_fuel_consumption * delta
		right_thruster_flame.visible = true
		var thruster_pos = Vector2(side_thruster_offset_x, side_thruster_offset_y)
		var force = Vector2.LEFT * side_thruster_force
		apply_force(force.rotated(rotation), thruster_pos.rotated(rotation))

	if Input.is_action_pressed("rotate_right"):
		current_fuel -= side_thruster_fuel_consumption * delta
		left_thruster_flame.visible = true
		var thruster_pos = Vector2(-side_thruster_offset_x, side_thruster_offset_y)
		var force = Vector2.RIGHT * side_thruster_force
		apply_force(force.rotated(rotation), thruster_pos.rotated(rotation))

func handle_main_thrust(delta: float) -> void:
	if Input.is_action_pressed("thrust"):
		if current_fuel <= 0:
			main_flame_polygon.visible = false
			return

		current_fuel -= main_thrust_fuel_consumption * delta
		main_flame_polygon.visible = true

		var ramp_amount = ((max_main_thrust - min_main_thrust) / thrust_ramp_up_time) * delta
		current_main_thrust += ramp_amount
		current_main_thrust = clampf(current_main_thrust, min_main_thrust, max_main_thrust)

		var flame_scale_y = remap(current_main_thrust, min_main_thrust, max_main_thrust, 0.4, 1.5)
		main_flame_polygon.scale.y = flame_scale_y

		var force_to_apply = Vector2.UP.rotated(rotation) * current_main_thrust
		var thruster_pos = main_thruster_offset
		apply_force(force_to_apply, thruster_pos.rotated(rotation))
	else:
		main_flame_polygon.visible = false
		current_main_thrust = min_main_thrust

	current_fuel = max(current_fuel, 0.0)

# --- SÉRÜLÉS ---
func _on_body_entered(body):
	if is_destroyed:
		return
	if body.is_in_group("ground") and linear_velocity.length() > crash_speed_threshold:
		var dmg = roundi(linear_velocity.length())
		take_damage(dmg)

func take_damage(amount: float):
	current_health -= amount
	print("Becsapódás! HP: ", current_health, "/", max_health)
	if current_health <= 0:
		destroy_ship()

func destroy_ship():
	print("Hajó megsemmisült! Vezérlés leállítva.")
	is_destroyed = true
	main_flame_polygon.visible = false
	left_thruster_flame.visible = false
	right_thruster_flame.visible = false

func refuel(amount: float):
	current_fuel += amount
	current_fuel = min(current_fuel, max_fuel)
	print("Tankolás! Új üzemanyagszint: ", current_fuel)

# --- REFUEL ZONE HOOKS ---
func set_inside_refuel_zone(state: bool):
	is_inside_refuel_zone = state

func set_can_launch_boost(state: bool):
	can_launch_boost = state
