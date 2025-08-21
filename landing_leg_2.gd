extends RigidBody2D

# --- EXPORT VÁLTOZÓK ---
@export var break_velocity : float = 5           # Sebesség, ami felett leszakad
@export var detach_force : float = 2000         # Lökés nagysága
@export var pin_joint_left : PinJoint2D         # Inspectorból assignálható (bal oldal)
@export var pin_joint_right : PinJoint2D        # Inspectorból assignálható (jobb oldal)
@export var rocket_node_path : NodePath         # Rakéta node-ja, impulzus irányához

# --- BELSŐ VÁLTOZÓK ---
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

	# PinJoint-ok eltávolítása
	if pin_joint_left and pin_joint_left.is_inside_tree():
		pin_joint_left.queue_free()
		pin_joint_left = null

	if pin_joint_right and pin_joint_right.is_inside_tree():
		pin_joint_right.queue_free()
		pin_joint_right = null

	# Ütközés kikapcsolása (hogy ne akadjon be a rakétába)
	collision_layer = 0
	collision_mask = 0
	
	# Impulzus a rakétától kifelé
	if rocket_node_path:
		var rocket = get_node(rocket_node_path)
		if rocket:
			var direction = (global_position - rocket.global_position).normalized()
			apply_central_impulse(direction * detach_force)

			# --- Új rész: ha láb leszakad → rakéta is robban ---
			if "current_health" in rocket and "destroy_ship" in rocket:
				rocket.current_health = 0
				rocket.destroy_ship()
