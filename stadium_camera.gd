extends Camera3D

@export var target_path: NodePath
@export var follow_distance: float = 10.8
@export var follow_height: float = 6.4
@export var look_ahead: float = 4.6
@export var follow_speed: float = 6.0

var target = null

func _ready():
    target = get_node_or_null(target_path)
    current = true
    fov = 58.0

func _process(delta):
    if target == null:
        target = get_node_or_null(target_path)
        return

    var desired_position = target.global_position + Vector3(-follow_distance, follow_height, 0.0)
    global_position = global_position.lerp(desired_position, clamp(delta * follow_speed, 0.0, 1.0))

    var look_point = target.global_position + Vector3(look_ahead, 1.2, 0.0)
    look_at(look_point, Vector3.UP)
