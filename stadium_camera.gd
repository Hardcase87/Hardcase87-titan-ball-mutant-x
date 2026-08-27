extends Camera3D

@export var target_path: NodePath
@export var follow_distance: float = 12.4
@export var follow_height: float = 7.2
@export var look_ahead: float = 5.4
@export var follow_speed: float = 5.5

var target = null

func _ready():
    target = get_node_or_null(target_path)
    current = true
    fov = 61.0

func _process(delta):
    if target == null:
        target = get_node_or_null(target_path)
        return

    # Higher/wider television-style chase framing so the fortress,
    # crowd bowl and field remain visible while the player advances.
    var lateral_pull := clamp(target.global_position.z * 0.10, -0.7, 0.7)
    var desired_position = target.global_position + Vector3(-follow_distance, follow_height, lateral_pull)
    global_position = global_position.lerp(desired_position, clamp(delta * follow_speed, 0.0, 1.0))

    var look_point = target.global_position + Vector3(look_ahead, 0.95, 0.0)
    look_at(look_point, Vector3.UP)
