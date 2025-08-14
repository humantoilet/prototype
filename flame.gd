extends Node2D

@export var ground_distance_threshold : float = 50.0
@export var smoke_particles_node_path : NodePath
@export var raycast_node_path : NodePath

@onready var smoke_particles : CPUParticles2D = get_node_or_null(smoke_particles_node_path)
@onready var ray : RayCast2D = get_node_or_null(raycast_node_path)

func _physics_process(delta):
	if not smoke_particles or not ray:
		return

	ray.force_raycast_update()
	var close_to_ground = false
	if ray.is_colliding():
		var distance_to_ground = ray.get_collision_point().distance_to(global_position)
		close_to_ground = distance_to_ground <= ground_distance_threshold

	var thrust_pressed = Input.is_action_pressed("thrust")

	# Emitting = csak addig generál új részecskéket, amíg W lenyomva és közel a talaj
	smoke_particles.emitting = thrust_pressed and close_to_ground
