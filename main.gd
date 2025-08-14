# Main.gd - HIBKERESŐ VERZIÓ
extends Node2D

# Hivatkozások a gyermek csomópontokra.
# Győződj meg róla, hogy a csomópontjaidnak pontosan ez a neve a jelenetfában!
@onready var rocket = $Rocket
@onready var ui_layer = $UILayer


# A _ready() funkció a játék indulásakor fut le.
func _ready() -> void:
	print("--- MAIN.GD: _ready() funkció elindult. ---")
	
	# Ellenőrizzük, hogy a szkript megtalálja-e a rakétát.
	if is_instance_valid(rocket):
		print("   - A 'rocket' változó sikeresen hivatkozik a Rocket csomópontra.")
	else:
		print("   - !!! HIBA: Nem található 'Rocket' nevű gyermek csomópont! !!!")

	# Ellenőrizzük, hogy a szkript megtalálja-e a UI-t.
	if is_instance_valid(ui_layer):
		print("   - A 'ui_layer' változó sikeresen hivatkozik a UILayer csomópontra.")
	else:
		print("   - !!! HIBA: Nem található 'UILayer' nevű gyermek csomópont! !!!")

	# Most próbáljuk meg az összekötést.
	if rocket and ui_layer:
		print("   - Próbálkozás az összekötéssel...")
		
		# Hozzáférünk a ui_layer csomópont szkriptjének 'rocket_node' változójához,
		# és beállítjuk az értékét a 'rocket' csomópontra.
		ui_layer.rocket_node = rocket
		
		print("--- MAIN.GD: Összekötés látszólag sikeres. Ellenőrizzük a UI szkriptet. ---")
	else:
		print("--- MAIN.GD: Az összekötés meghiúsult, mert az egyik csomópont hiányzik. ---")
