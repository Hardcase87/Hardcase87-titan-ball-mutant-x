extends Node3D
class_name MutantXArenaVisual

var phase: float = 0.0
var pulse_materials: Array = []

func _ready() -> void:
    var stadium_model_path = "res://the_pit.glb"
    if ResourceLoader.exists(stadium_model_path):
        var packed = load(stadium_model_path)
        if packed is PackedScene:
            var model = packed.instantiate()
            model.name = "AuthoredStadium"
            add_child(model)
    _build_the_pit()

func _process(delta: float) -> void:
    phase += delta
    for i in range(pulse_materials.size()):
        var m = pulse_materials[i]
        if m != null:
            m.emission_energy_multiplier = 1.15 + 0.30 * sin(phase * 2.2 + float(i) * 0.55)

func _make_material(color: Color, emission: Color, energy: float, metallic: float, roughness: float) -> StandardMaterial3D:
    var m = StandardMaterial3D.new()
    m.albedo_color = color
    m.metallic = metallic
    m.roughness = roughness
    if energy > 0.0:
        m.emission_enabled = true
        m.emission = emission
        m.emission_energy_multiplier = energy
        pulse_materials.append(m)
    return m

func _box(node_name: String, pos: Vector3, size: Vector3, mat: Material) -> MeshInstance3D:
    var n = MeshInstance3D.new()
    n.name = node_name
    var mesh = BoxMesh.new()
    mesh.size = size
    mesh.material = mat
    n.mesh = mesh
    n.position = pos
    add_child(n)
    return n

func _cylinder(node_name: String, pos: Vector3, radius: float, height: float, mat: Material) -> MeshInstance3D:
    var n = MeshInstance3D.new()
    n.name = node_name
    var mesh = CylinderMesh.new()
    mesh.top_radius = radius
    mesh.bottom_radius = radius
    mesh.height = height
    mesh.material = mat
    n.mesh = mesh
    n.position = pos
    add_child(n)
    return n

func _label(text_value: String, pos: Vector3, rot: Vector3, color: Color, font_size_value: int) -> void:
    var l = Label3D.new()
    l.text = text_value
    l.font_size = font_size_value
    l.modulate = color
    l.outline_size = 10
    l.position = pos
    l.rotation_degrees = rot
    add_child(l)

func _load_tex(path: String):
    if ResourceLoader.exists(path):
        return load(path)
    return null

func _build_the_pit() -> void:
    var turf_mat = _make_material(Color(0.04,0.09,0.035,1), Color(0.03,0.16,0.04,1), 0.10, 0.0, 0.95)
    var turf_tex = _load_tex("res://thepit.png")
    if turf_tex != null:
        turf_mat.albedo_texture = turf_tex
        turf_mat.albedo_color = Color(1,1,1,1)

    # Main playable surface. 16:9 texture is framed rather than heavily stretched.
    _box("HD_Turf", Vector3(0,0.115,0), Vector3(36.0,0.035,20.25), turf_mat)

    # Finished visual pass: the HD field artwork already contains its own
    # industrial borders. Keep the actual 3D arena clean instead of stacking
    # prototype rails/posts over the image.

    var backdrop = _load_tex("res://stadium_horizon.png")
    if backdrop != null:
        var bg:=Sprite3D.new()
        bg.name="SludgeStadiumHorizon"
        bg.texture=backdrop
        bg.position=Vector3(16.65,5.20,0)
        bg.rotation_degrees=Vector3(0,-90,0)
        bg.pixel_size=0.0310
        bg.modulate=Color(1,1,1,0.96)
        bg.no_depth_test=false
        add_child(bg)

    # Dark far-wall closes the arena beneath the skyline and kills the floating-image look.
    var wall_mat:=StandardMaterial3D.new()
    wall_mat.albedo_color=Color(0.008,0.004,0.012,1)
    wall_mat.roughness=0.92
    _box("FarDarkWall",Vector3(17.75,3.0,0),Vector3(0.20,6.0,20.8),wall_mat)
