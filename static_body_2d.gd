@tool
extends StaticBody2D # Vagy RigidBody2D, Area2D

# Eltároljuk az utolsó ismert állapotot
var last_known_transform: Transform2D
var last_known_polygon: PackedVector2Array

# A gyermekeink referenciái, hogy ne kelljen mindig megkeresni őket
@onready var polygon_2d: Polygon2D = $Polygon2D
@onready var collision_polygon: CollisionPolygon2D = $CollisionPolygon2D


func _ready() -> void:
	# A szkript betöltésekor azonnal beállítjuk a kezdeti állapotot
	if polygon_2d:
		last_known_transform = polygon_2d.transform
		last_known_polygon = polygon_2d.polygon
		_update_collision()


func _process(_delta: float) -> void:
	# Csak a szerkesztőben fusson ez a logika
	if not Engine.is_editor_hint():
		return
	
	# Ellenőrizzük, hogy a csomópontok léteznek-e még
	if not is_instance_valid(polygon_2d) or not is_instance_valid(collision_polygon):
		return

	# Összehasonlítjuk a jelenlegi állapotot az utolsó ismerttel
	var is_transform_dirty = (polygon_2d.transform != last_known_transform)
	var is_polygon_dirty = (polygon_2d.polygon != last_known_polygon)

	# Ha bármelyik megváltozott...
	if is_transform_dirty or is_polygon_dirty:
		# ...akkor frissítjük a collisiont
		_update_collision()
		
		# ...és elmentjük az új állapotot, mint "utolsó ismert"
		last_known_transform = polygon_2d.transform
		last_known_polygon = polygon_2d.polygon


func _update_collision() -> void:
	# Ez a funkció végzi a tényleges másolást
	if not is_instance_valid(polygon_2d) or not is_instance_valid(collision_polygon):
		return
		
	collision_polygon.transform = polygon_2d.transform
	collision_polygon.polygon = polygon_2d.polygon
	# print("CollisionPolygon2D automatically updated!") # Ezt a sort kikommentelheted, ha nem akarod, hogy teleírja a konzolt")
