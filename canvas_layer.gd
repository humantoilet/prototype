# UI.gd
extends CanvasLayer

@export var rocket_node: RigidBody2D

# Hivatkozások a két Labelre.
@onready var hp_label: Label = $HPLabel
@onready var fuel_label: Label = $FuelLabel # <-- ÚJ SOR


# UI.gd
func _process(_delta: float) -> void:
	if not is_instance_valid(rocket_node):
		return
	
	# Frissítjük a HP Label szövegét.
	# Itt ellenőrizzük, hogy a rocket_node-nak VAN-E 'current_health' tulajdonsága.
	if "current_health" in rocket_node:
		hp_label.text = "HP: " + str(roundi(rocket_node.current_health))
	
	# Frissítjük a Fuel Label szövegét.
	# Itt ellenőrizzük, hogy a rocket_node-nak VAN-E 'current_fuel' tulajdonsága.
	if "current_fuel" in rocket_node:
		fuel_label.text = "Fuel: " + str(roundi(rocket_node.current_fuel))
