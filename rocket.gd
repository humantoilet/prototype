# Rocket.gd - Teljes verzió
class_name Rocket # Ajánlott a jobb típuskezeléshez!
extends RigidBody2D

# --- ÉLETERŐ ÉS SÉRÜLÉS BEÁLLÍTÁSAI ---
@export_group("Health and Destruction")
@export var max_health: float = 100.0
@export var crash_speed_threshold: float = 1.0

# --- ÜZEMANYAG BEÁLLÍTÁSOK ---
@export_group("Fuel System")
@export var max_fuel: float = 100.0
@export var main_thrust_fuel_consumption: float = 3.0
@export var side_thruster_fuel_consumption: float = 1.0

# --- FŐ HAJTÓMŰ BEÁLLÍTÁSAI ---
@export_group("Main Thruster")
@export var max_main_thrust: float = 3500.0
@export var min_main_thrust: float = 0.0
@export var thrust_ramp_up_time: float = 2.0
@export var main_thruster_offset: Vector2 = Vector2(0, 50)

# --- KORMÁNYFÚVÓKÁK (FORGÁSHOZ) ---
@export_group("Side Thrusters")
@export var side_thruster_force: float = 50.0
@export var side_thruster_offset_x: float = 25.0
@export var side_thruster_offset_y: float = 10.0

# --- CSOMÓPONT HIVATKOZÁSOK ---
@onready var main_flame_polygon: Polygon2D = $Flame
@onready var left_thruster_flame: Polygon2D = $LeftThrusterFlame
@onready var right_thruster_flame: Polygon2D = $RightThrusterFlame

# --- BELSŐ VÁLTOZÓK ---
var current_health: float
var current_fuel: float
var current_main_thrust: float
var is_destroyed: bool = false


func _ready() -> void:
	# Kezdeti értékek beállítása a játék indulásakor.
	current_health = max_health
	current_fuel = max_fuel
	current_main_thrust = min_main_thrust
	
	# Mindhárom láng legyen láthatatlan a játék kezdetekor.
	if main_flame_polygon: main_flame_polygon.visible = false
	if left_thruster_flame: left_thruster_flame.visible = false
	if right_thruster_flame: right_thruster_flame.visible = false


func _physics_process(delta: float) -> void:
	# A "KILL SWITCH": Ha a hajó megsemmisült, minden vezérlés leáll.
	if is_destroyed:
		return

	# Vezérlési funkciók meghívása.
	handle_rotation(delta)
	handle_main_thrust(delta)


# Forgás kezelése üzemanyag-fogyasztással és animációval.
func handle_rotation(delta: float) -> void:
	left_thruster_flame.visible = false
	right_thruster_flame.visible = false

	# Ha nincs üzemanyag, a forgatás sem működhet.
	if current_fuel <= 0:
		return

	if Input.is_action_pressed("rotate_left"):
		current_fuel -= side_thruster_fuel_consumption * delta
		right_thruster_flame.visible = true
		var thruster_position = Vector2(side_thruster_offset_x, side_thruster_offset_y)
		var force_to_apply = Vector2.LEFT * side_thruster_force
		apply_force(force_to_apply.rotated(rotation), thruster_position.rotated(rotation))

	if Input.is_action_pressed("rotate_right"):
		current_fuel -= side_thruster_fuel_consumption * delta
		left_thruster_flame.visible = true
		var thruster_position = Vector2(-side_thruster_offset_x, side_thruster_offset_y)
		var force_to_apply = Vector2.RIGHT * side_thruster_force
		apply_force(force_to_apply.rotated(rotation), thruster_position.rotated(rotation))


# Főhajtómű kezelése üzemanyag-fogyasztással, fokozatos erőnöveléssel és animációval.
func handle_main_thrust(delta: float) -> void:
	if Input.is_action_pressed("thrust"):
		if current_fuel <= 0:
			main_flame_polygon.visible = false
			return
		
		current_fuel -= main_thrust_fuel_consumption * delta
		main_flame_polygon.visible = true
		
		var ramp_increase_amount = ((max_main_thrust - min_main_thrust) / thrust_ramp_up_time) * delta
		current_main_thrust += ramp_increase_amount
		current_main_thrust = clampf(current_main_thrust, min_main_thrust, max_main_thrust)
		
		var target_flame_scale_y = remap(current_main_thrust, min_main_thrust, max_main_thrust, 0.4, 1.5)
		main_flame_polygon.scale.y = target_flame_scale_y
		
		var force_to_apply = Vector2.UP.rotated(rotation) * current_main_thrust
		var thruster_position = main_thruster_offset
		apply_force(force_to_apply, thruster_position.rotated(rotation))
		
	else:
		main_flame_polygon.visible = false
		current_main_thrust = min_main_thrust
	
	current_fuel = max(current_fuel, 0.0)


# --- SÉRÜLÉSI, MEGSEMMISÜLÉSI ÉS TANKOLÁSI LOGIKA ---

# Ezt a funkciót kell bekötni a 'body_entered' jelzéshez.
func _on_body_entered(body):
	if is_destroyed:
		return

	if body.is_in_group("ground"):
		if linear_velocity.length() > crash_speed_threshold:
			var damage_amount = roundi(linear_velocity.length())
			take_damage(damage_amount)

# Sebzés levonása és a HP ellenőrzése.
func take_damage(amount: float):
	current_health -= amount
	print("Becsapódás! HP: ", current_health, " / ", max_health)

	if current_health <= 0:
		destroy_ship()

# A hajó "megsemmisítése" (vezérlés leállítása).
func destroy_ship():
	print("Hajó megsemmisült! Vezérlés leállítva.")
	is_destroyed = true
	
	main_flame_polygon.visible = false
	left_thruster_flame.visible = false
	right_thruster_flame.visible = false

# Ezt a funkciót hívhatja meg egy külső objektum (pl. töltőállomás).
func refuel(amount: float):
	current_fuel += amount
	current_fuel = min(current_fuel, max_fuel)
	print("Tankolás! Új üzemanyagszint: ", current_fuel)
