extends Camera3D

@export var target_path: NodePath
@export var follow_distance: float = 5.2
@export var follow_height: float = 4.2
@export var look_ahead: float = 4.0
@export var follow_speed: float = 5.5

var target = null

func _ready():
    target = get_node_or_null(target_path)
    current = true
    fov = 68.0
    if target != null:
        # Start on the playable side of the rear wall, even at kickoff.
        global_position = _follow_position()
        look_at(target.global_position + Vector3(look_ahead, 0.95, 0), Vector3.UP)

func _follow_position() -> Vector3:
    return Vector3(
        clamp(target.global_position.x - follow_distance, -16.35, 16.35),
        target.global_position.y + follow_height,
        target.global_position.z * 0.65
    )

func _process(delta):
    if target == null:
        target = get_node_or_null(target_path)
        return

    var desired_position = _follow_position()
    global_position = global_position.lerp(desired_position, clamp(delta * follow_speed, 0.0, 1.0))

    var look_point = target.global_position + Vector3(look_ahead, 0.95, 0.0)
    look_at(look_point, Vector3.UP)
    var desired_fov := 68.0
    if target.mutation_timer > 0.0:
        desired_fov = 77.0
    elif target.dash_timer > 0.0:
        desired_fov = 73.0
    fov = lerp(fov, desired_fov, min(1.0, delta * 7.0))
    if target.shake > 0.0:
        var ticks := float(Time.get_ticks_msec())
        h_offset = sin(ticks * 0.045) * target.shake * 0.10
        v_offset = cos(ticks * 0.061) * target.shake * 0.10
    else:
        h_offset = lerp(h_offset, 0.0, min(1.0, delta * 12.0))
        v_offset = lerp(v_offset, 0.0, min(1.0, delta * 12.0))
