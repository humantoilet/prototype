extends RigidBody2D

# --- EXPORT VÁLTOZÓK ---
@export var break_velocity : float = 5           # Sebesség, ami felett leszakad
@export var detach_force : float = 2000         # Lökés nagysága
@export var pin_joint : PinJoint2D              # Inspectorból assignálható
@export var groove_joint : GrooveJoint2D        # Inspectorból assignálható
@export var rocket_node_path : NodePath         # Rakéta node-ja, impulzus irányához

# --- BELSO VÁLTOZÓK ---
var detached : bool = false

# --- FIZIKA FOLYAMAT ---
func _physics_process(delta):
	if detached:
		return

	# Ellenőrizzük az ütközést a talajjal
	for body in get_colliding_bodies():
		if body.is_in_group("ground") and linear_velocity.length() > break_velocity:
			detach()
			break

# --- LESZAKADÁS METÓDUS ---
func detach():
	detached = true

	# PinJoint eltávolítása
	if pin_joint and pin_joint.is_inside_tree():
		pin_joint.queue_free()
		pin_joint = null

	# GrooveJoint eltávolítása
	if groove_joint and groove_joint.is_inside_tree():
		groove_joint.queue_free()
		groove_joint = null

	# Ütközés kikapcsolása
	collision_layer = 0
	collision_mask = 0
	
	# Impulzus a rakétától kifelé
	if rocket_node_path:
		var rocket = get_node(rocket_node_path)
		if rocket:
			var direction = (global_position - rocket.global_position).normalized()
			apply_central_impulse(direction * detach_force)

			# --- Új rész: láb leszakadása → rakéta HP = 0 ---
			if "current_health" in rocket and "destroy_ship" in rocket:
				rocket.current_health = 0
				rocket.destroy_ship()
