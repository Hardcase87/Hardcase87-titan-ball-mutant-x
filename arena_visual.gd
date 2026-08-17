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

    var pink = _make_material(Color(0.12,0.005,0.07,1), Color(1.0,0.02,0.52,1), 1.65, 0.25, 0.42)
    var acid = _make_material(Color(0.08,0.13,0.02,1), Color(0.52,1.0,0.02,1), 1.25, 0.05, 0.55)
    var cyan = _make_material(Color(0.01,0.08,0.10,1), Color(0.02,0.82,1.0,1), 1.25, 0.20, 0.45)
    var metal = _make_material(Color(0.015,0.015,0.022,1), Color(0.07,0.00,0.06,1), 0.15, 0.55, 0.36)

    # Low dark stadium rails frame the field without blocking the art.
    _box("NearRailL", Vector3(0,0.55,-10.35), Vector3(36.4,0.22,0.22), pink)
    _box("NearRailR", Vector3(0,0.55,10.35), Vector3(36.4,0.22,0.22), pink)
    _box("FarRail", Vector3(18.05,0.65,0), Vector3(0.22,0.24,20.7), acid)

    # Small field-side industrial structures only. No giant purple grandstands.
    for side_value in [-1,1]:
        var side = float(side_value)
        var z = 11.10 * side
        _box("Wall_%d" % side_value, Vector3(1.0,1.0,z), Vector3(34.0,1.7,0.75), metal)
        for x in [-13,-8,-3,2,7,12]:
            _cylinder("Sludge_%d_%d" % [side_value,x], Vector3(float(x),1.55,z - side*0.35), 0.22,2.2, acid)

    # Far goal only; keep it out of the player's camera.
    _cylinder("GoalStem", Vector3(17.1,1.65,0), 0.06,3.1, cyan)
    _box("GoalCross", Vector3(17.1,2.8,0), Vector3(0.10,0.10,3.6), cyan)

    _label("SKULL JUICE", Vector3(-8.0,2.0,-10.85), Vector3(0,0,0), Color(0.55,1,0.08,1), 38)
    _label("MUTANT LOOPS", Vector3(7.0,2.0,-10.85), Vector3(0,0,0), Color(1,0.05,0.55,1), 38)

    # Huge stadium horizon. This is the main Sludge Stadium visual.
    var backdrop = _load_tex("res://pit_backdrop.png")
    if backdrop != null:
        var bg = Sprite3D.new()
        bg.name = "SludgeStadiumBackdrop"
        bg.texture = backdrop
        bg.position = Vector3(17.15,7.0,0)
        bg.rotation_degrees = Vector3(0,-90,0)
        bg.pixel_size = 0.030
        bg.modulate = Color(1,1,1,1)
        bg.no_depth_test = false
        add_child(bg)

    # Secondary side banners, kept dark and subtle.
    for side_value in [-1,1]:
        var l = Label3D.new()
        l.text = "THE PIT  //  SLUDGE STADIUM"
        l.font_size = 42
        l.modulate = Color(1,0.05,0.55,0.82)
        l.position = Vector3(4.0,2.6,10.75*float(side_value))
        l.rotation_degrees = Vector3(0,0,0) if side_value < 0 else Vector3(0,180,0)
        l.outline_size = 8
        add_child(l)
