extends RigidBody2D

# --- EXPORT VÁLTOZÓK ---
@export var break_velocity : float = 5
@export var detach_force : float = 2000
@export var pin_joint_left : PinJoint2D
@export var pin_joint_right : PinJoint2D
@export var rocket_node_path : NodePath

# --- BELSŐ ---
var detached : bool = false
var rocket_ref : Node = null

func _ready():
	if rocket_node_path != NodePath():
		rocket_ref = get_node(rocket_node_path)

func _physics_process(delta):
	if detached:
		return
	
	# ha boost aktív VAGY bent van a refuel zone-ban → nem szakadhat
	if rocket_ref and (
		("is_launch_boosting" in rocket_ref and rocket_ref.is_launch_boosting)
		or ("is_inside_refuel_zone" in rocket_ref and rocket_ref.is_inside_refuel_zone)
	):
		return

	# ütközés vizsgálat
	for body in get_colliding_bodies():
		if body.is_in_group("ground") and linear_velocity.length() > break_velocity:
			detach()
			break

func detach():
	detached = true

	# PinJoint-ek törlése
	if pin_joint_left and pin_joint_left.is_inside_tree():
		pin_joint_left.queue_free()
		pin_joint_left = null
	if pin_joint_right and pin_joint_right.is_inside_tree():
		pin_joint_right.queue_free()
		pin_joint_right = null

	# Ütközés ki
	collision_layer = 0
	collision_mask = 0
	
	# Impulzus rakétától kifelé
	if rocket_ref:
		var direction = (global_position - rocket_ref.global_position).normalized()
		apply_central_impulse(direction * detach_force)

		# Ha leszakad → rakéta robban
