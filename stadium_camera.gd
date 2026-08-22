extends Camera3D
class_name MutantXStadiumCamera

@export var target_path: NodePath
@export var follow_distance: float = 10.8
@export var follow_height: float = 6.4
@export var look_ahead: float = 4.6
@export var side_offset: float = 0.0
@export var follow_smooth: float = 7.0
@export var look_smooth: float = 9.0
@export var base_fov: float = 58.0
@export var run_fov: float = 63.0

var target: CharacterBody3D
var smoothed_look := Vector3.ZERO

func _ready() -> void:
    target = get_node_or_null(target_path) as CharacterBody3D
    current = true
    fov = base_fov
    if target != null:
        global_position = _desired_position()
        smoothed_look = _desired_look()
        look_at(smoothed_look, Vector3.UP)

func _physics_process(delta: float) -> void:
    if target == null:
        target = get_node_or_null(target_path) as CharacterBody3D
        if target == null:
            return

    var desired_pos := _desired_position()
    var desired_look := _desired_look()

    var pos_t := 1.0 - exp(-follow_smooth * delta)
    var look_t := 1.0 - exp(-look_smooth * delta)

    global_position = global_position.lerp(desired_pos, pos_t)
    smoothed_look = smoothed_look.lerp(desired_look, look_t)
    look_at(smoothed_look, Vector3.UP)

    var planar_speed := Vector2(target.velocity.x, target.velocity.z).length()
    var speed_mix := clamp(planar_speed / 12.0, 0.0, 1.0)
    fov = lerp(fov, lerp(base_fov, run_fov, speed_mix), 1.0 - exp(-5.0 * delta))

func _desired_position() -> Vector3:
    # Titan Ball advances primarily toward +X.
    # Camera sits behind and above, but is independent of the player's transform.
    return target.global_position + Vector3(-follow_distance, follow_height, side_offset)

func _desired_look() -> Vector3:
    var ahead := look_ahead
    if target.velocity.x < -0.5:
        ahead *= 0.35
    return target.global_position + Vector3(ahead, 1.15, 0.0)
