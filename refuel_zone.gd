extends Area2D
class_name RefuelZone

# --- BEÁLLÍTÁSOK ---
@export_group("Refuel Settings")
@export var refuel_rate: float = 500.0              # mennyi üzemanyagot ad másodpercenként
@export var max_refuel_speed: float = 5.0         # rakéta max sebesség a tankoláshoz
@export var required_stable_time: float = 0.25      # hány másodpercig kell a max_refuel_speed alatt maradnia

# --- ÁLLAPOT ---
var rocket: Rocket = null
var stable_time_counter: float = 0.0



# Ha a rakéta belép a zónába
func _on_body_entered(body: Node) -> void:
	if body is Rocket:
		rocket = body
		rocket.set_inside_refuel_zone(true)
		stable_time_counter = 0.0
		print("Rakéta belépett a refuel zónába.")

# Ha a rakéta elhagyja a zónát
func _on_body_exited(body: Node) -> void:
	if body == rocket:
		rocket.set_inside_refuel_zone(false)
		rocket = null
		stable_time_counter = 0.0
		print("Rakéta elhagyta a refuel zónát.")

# Tankolás logika
func _process(delta: float) -> void:
	if rocket and rocket.is_inside_refuel_zone:
		var speed = rocket.linear_velocity.length()

		# Ha elég lassú → növeljük a számlálót
		if speed <= max_refuel_speed:
			stable_time_counter += delta

			# Ha már túl van a szükséges időn, tankol
			if stable_time_counter >= required_stable_time:
				rocket.refuel(refuel_rate * delta)
		else:
			# Ha gyors, akkor nullázzuk az időzítőt
			if stable_time_counter > 0:
				print("Rakéta túl gyors volt, számláló nullázva.")
			stable_time_counter = 0.0
