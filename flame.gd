extends Node2D

@export var ground_distance_threshold : float = 50.0
@export var smoke_particles_node_path : NodePath
@export var raycast_node_path : NodePath
@export var thrust_action : String = "thrust"
@export var smoke_ramp_time : float = 0.2

@onready var smoke_particles : CPUParticles2D = get_node_or_null(smoke_particles_node_path)
@onready var ray : RayCast2D = get_node_or_null(raycast_node_path)

var ramp_timer := 0.0
var target_scale_min : float = 1.0
var target_scale_max : float = 1.0

func _ready():
	# A célméretet közvetlenül a CPUParticles2D node-ról olvassuk ki
	if smoke_particles:
		target_scale_min = smoke_particles.scale_amount_min
		target_scale_max = smoke_particles.scale_amount_max

func _physics_process(delta):
	if not smoke_particles or not ray:
		if smoke_particles:
			smoke_particles.emitting = false
		return

	ray.force_raycast_update()

	var should_emit := false
	if Input.is_action_pressed(thrust_action) and ray.is_colliding():
		var distance_to_ground = ray.get_collision_point().distance_to(global_position)
		if distance_to_ground <= ground_distance_threshold:
			should_emit = true
			smoke_particles.global_position = ray.get_collision_point()

	smoke_particles.emitting = should_emit

	if should_emit:
		if ramp_timer < smoke_ramp_time:
			ramp_timer += delta
			var t = clamp(ramp_timer / smoke_ramp_time, 0.0, 1.0)
			# Közvetlenül a node méret-tulajdonságait animáljuk
			smoke_particles.scale_amount_min = lerp(0.0, target_scale_min, t)
			smoke_particles.scale_amount_max = lerp(0.0, target_scale_max, t)
	else:
		# Visszaállítjuk az időzítőt és a méretet a következő induláshoz
		ramp_timer = 0.0
		smoke_particles.scale_amount_min = target_scale_min
		smoke_particles.scale_amount_max = target_scale_max
