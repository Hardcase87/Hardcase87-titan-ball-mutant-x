extends Node3D
class_name MutantXArenaVisual

var pulse_materials: Array = []
var phase: float = 0.0

func _ready() -> void:
    _build_the_pit()

func _process(delta: float) -> void:
    phase += delta
    for index in range(pulse_materials.size()):
        var material = pulse_materials[index]
        if material != null:
            material.emission_energy_multiplier = 1.05 + 0.18 * sin(phase * 1.7 + float(index) * 0.4)

func _make_material(color: Color, emission: Color, energy: float, metallic: float, roughness: float) -> StandardMaterial3D:
    var material = StandardMaterial3D.new()
    material.albedo_color = color
    material.metallic = metallic
    material.roughness = roughness
    if energy > 0.0:
        material.emission_enabled = true
        material.emission = emission
        material.emission_energy_multiplier = energy
        pulse_materials.append(material)
    return material

func _box(node_name: String, pos: Vector3, size: Vector3, material: Material) -> MeshInstance3D:
    var node = MeshInstance3D.new()
    node.name = node_name
    var mesh = BoxMesh.new()
    mesh.size = size
    mesh.material = material
    node.mesh = mesh
    node.position = pos
    add_child(node)
    return node

func _solid_box(node_name: String, pos: Vector3, size: Vector3, material: Material) -> StaticBody3D:
    var body = StaticBody3D.new()
    body.name = node_name
    body.position = pos
    add_child(body)

    var mesh_node = MeshInstance3D.new()
    var mesh = BoxMesh.new()
    mesh.size = size
    mesh.material = material
    mesh_node.mesh = mesh
    body.add_child(mesh_node)

    var collision_node = CollisionShape3D.new()
    var shape = BoxShape3D.new()
    shape.size = size
    collision_node.shape = shape
    body.add_child(collision_node)
    return body

func _omni(node_name: String, pos: Vector3, color: Color, energy: float, range_value: float) -> void:
    var light = OmniLight3D.new()
    light.name = node_name
    light.position = pos
    light.light_color = color
    light.light_energy = energy
    light.omni_range = range_value
    light.shadow_enabled = false
    add_child(light)

func _label(text_value: String, pos: Vector3, rotation_value: Vector3, color: Color, font_size_value: int) -> void:
    var label = Label3D.new()
    label.text = text_value
    label.position = pos
    label.rotation_degrees = rotation_value
    label.modulate = color
    label.font_size = font_size_value
    label.outline_size = 8
    add_child(label)

func _load_texture(path: String):
    if ResourceLoader.exists(path):
        return load(path)
    return null

func _build_the_pit() -> void:
    var black = _make_material(Color(0.008,0.008,0.014,1), Color(0.035,0.0,0.03,1), 0.10, 0.62, 0.34)
    var stand = _make_material(Color(0.018,0.014,0.026,1), Color(0.08,0.0,0.07,1), 0.16, 0.22, 0.72)
    var concrete = _make_material(Color(0.035,0.035,0.045,1), Color(0,0,0,1), 0.0, 0.05, 0.88)
    var pink = _make_material(Color(0.10,0.004,0.055,1), Color(1.0,0.015,0.50,1), 1.45, 0.18, 0.38)
    var acid = _make_material(Color(0.05,0.10,0.01,1), Color(0.48,1.0,0.02,1), 1.35, 0.15, 0.42)

    # ------------------------------------------------------------------
    # PHYSICAL PLAYING SURFACE — 36 x 20.25, matched to a 16:9 turf crop.
    # ------------------------------------------------------------------
    var turf = _make_material(Color(1,1,1,1), Color(0.02,0.05,0.01,1), 0.04, 0.0, 0.96)
    var turf_texture = _load_texture("res://thepit.png")
    if turf_texture != null:
        turf.albedo_texture = turf_texture
    _box("FieldSurface", Vector3(0,0.115,0), Vector3(36.0,0.035,20.25), turf)

    # Stadium apron joins the turf to the bowl so the field no longer floats.
    _box("LeftApron", Vector3(0,0.08,-11.25), Vector3(38.0,0.10,2.25), concrete)
    _box("RightApron", Vector3(0,0.08,11.25), Vector3(38.0,0.10,2.25), concrete)
    _box("FarApron", Vector3(19.0,0.08,0), Vector3(2.0,0.10,24.5), concrete)

    # Sideline / far-end collision keeps play inside the actual arena.
    _solid_box("LeftBoundary", Vector3(0,0.52,-10.55), Vector3(36.8,0.85,0.24), black)
    _solid_box("RightBoundary", Vector3(0,0.52,10.55), Vector3(36.8,0.85,0.24), black)
    _solid_box("FarBoundary", Vector3(18.15,0.52,0), Vector3(0.24,0.85,21.2), black)

    _box("LeftRail", Vector3(0,1.01,-10.55), Vector3(36.8,0.09,0.10), pink)
    _box("RightRail", Vector3(0,1.01,10.55), Vector3(36.8,0.09,0.10), acid)
    _box("FarRail", Vector3(18.15,1.01,0), Vector3(0.10,0.09,21.2), pink)

    # ------------------------------------------------------------------
    # OPEN 3D STADIUM BOWL — the camera sits in the open near end.
    # ------------------------------------------------------------------
    for side_value in [-1,1]:
        var side = float(side_value)
        for tier in range(7):
            var z = side * (11.25 + float(tier) * 0.86)
            var y = 0.34 + float(tier) * 0.58
            _box(
                "SideStand_%d_%d" % [side_value,tier],
                Vector3(1.0,y,z),
                Vector3(40.0,0.48,1.20),
                stand
            )

        # Rear bowl wall and glowing fascia.
        _box("RearBowl_%d" % side_value, Vector3(1.0,4.8,side*17.0), Vector3(40.0,9.2,0.50), black)
        _box("BowlFascia_%d" % side_value, Vector3(1.0,2.10,side*12.05), Vector3(39.0,0.25,0.16), pink if side_value < 0 else acid)

    # Far-end seats and architecture only; near end remains open for the chase camera.
    for tier in range(6):
        var x = 19.4 + float(tier) * 0.82
        var y = 0.38 + float(tier) * 0.60
        _box("FarStand_%d" % tier, Vector3(x,y,0), Vector3(1.18,0.50,25.0), stand)

    # Fortress / scoreboard end.
    _box("FortressCore", Vector3(24.4,5.2,0), Vector3(2.8,10.4,12.8), black)
    _box("FortressGlow", Vector3(22.94,5.1,0), Vector3(0.10,6.0,8.5), acid)
    for tower_z in [-8.6,8.6]:
        _box("Tower_%s" % str(tower_z), Vector3(23.3,5.7,tower_z), Vector3(2.3,11.2,2.7), black)
        _box("TowerGlow_%s" % str(tower_z), Vector3(22.10,5.8,tower_z), Vector3(0.10,5.6,1.65), pink)

    # Stadium art is an IN-WORLD far-end architectural screen, never a fake world backdrop.
    var stadium_texture = _load_texture("res://stadium_world.png")
    if stadium_texture != null:
        var screen = Sprite3D.new()
        screen.name = "FortressVideoWall"
        screen.texture = stadium_texture
        screen.position = Vector3(22.72,6.05,0)
        screen.rotation_degrees = Vector3(0,-90,0)
        screen.pixel_size = 0.0100
        screen.shaded = false
        screen.modulate = Color(1,1,1,0.93)
        add_child(screen)

    # ------------------------------------------------------------------
    # LIGHT TOWERS / OPEN SKY FRAME
    # ------------------------------------------------------------------
    for x_value in [-11.5,12.0]:
        for z_value in [-15.5,15.5]:
            _box(
                "LightTower_%s_%s" % [str(x_value),str(z_value)],
                Vector3(x_value,6.2,z_value),
                Vector3(0.34,12.2,0.34),
                black
            )
            _box(
                "LightBank_%s_%s" % [str(x_value),str(z_value)],
                Vector3(x_value,12.0,z_value),
                Vector3(1.95,0.52,0.78),
                acid if z_value > 0.0 else pink
            )

    _omni("PinkFloodNear", Vector3(-7.0,7.2,-9.0), Color(1,0.02,0.48,1), 4.0, 17.0)
    _omni("PinkFloodFar", Vector3(10.0,8.0,-9.0), Color(1,0.02,0.48,1), 3.8, 17.0)
    _omni("AcidFloodNear", Vector3(-4.0,7.0,9.0), Color(0.46,1,0.03,1), 4.0, 17.0)
    _omni("AcidFloodFar", Vector3(13.0,8.0,9.0), Color(0.46,1,0.03,1), 3.8, 17.0)

    _label("THE PIT", Vector3(4.0,4.0,-16.74), Vector3(0,0,0), Color(1,0.03,0.52,1), 56)
    _label("SLUDGE STADIUM", Vector3(4.0,4.0,16.74), Vector3(0,180,0), Color(0.55,1,0.04,1), 48)
    _label("MUTANT FOOTBALL LEAGUE", Vector3(22.75,9.0,0), Vector3(0,-90,0), Color(1,0.05,0.55,1), 32)
