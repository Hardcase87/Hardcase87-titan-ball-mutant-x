extends Node3D
class_name MutantXArenaVisual

var phase: float = 0.0
var pulse_materials: Array = []

func _ready() -> void:
    var stadium_model_path := "res://the_pit.glb"
    if ResourceLoader.exists(stadium_model_path):
        var packed = load(stadium_model_path)
        if packed is PackedScene:
            var model = packed.instantiate()
            model.name = "AuthoredStadium"
            add_child(model)

    # Always build the lightweight stadium shell underneath.
    # A future authored GLB can replace / hide this without touching gameplay.
    _build_the_pit_2()

func _process(delta: float) -> void:
    phase += delta
    for i in range(pulse_materials.size()):
        var m = pulse_materials[i]
        if m != null:
            m.emission_energy_multiplier = 1.05 + 0.22 * sin(phase * 2.1 + float(i) * 0.43)

func _make_material(color: Color, emission: Color, energy: float, metallic: float, roughness: float) -> StandardMaterial3D:
    var m := StandardMaterial3D.new()
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
    var n := MeshInstance3D.new()
    n.name = node_name
    var mesh := BoxMesh.new()
    mesh.size = size
    mesh.material = mat
    n.mesh = mesh
    n.position = pos
    add_child(n)
    return n

func _cylinder(node_name: String, pos: Vector3, radius: float, height: float, mat: Material) -> MeshInstance3D:
    var n := MeshInstance3D.new()
    n.name = node_name
    var mesh := CylinderMesh.new()
    mesh.top_radius = radius
    mesh.bottom_radius = radius
    mesh.height = height
    mesh.material = mat
    n.mesh = mesh
    n.position = pos
    add_child(n)
    return n

func _label(text_value: String, pos: Vector3, rot: Vector3, color: Color, font_size_value: int) -> Label3D:
    var l := Label3D.new()
    l.text = text_value
    l.font_size = font_size_value
    l.modulate = color
    l.outline_size = 9
    l.position = pos
    l.rotation_degrees = rot
    add_child(l)
    return l

func _load_tex(path: String):
    if ResourceLoader.exists(path):
        return load(path)
    return null

func _stand_step(prefix: String, pos: Vector3, size: Vector3, mat: Material) -> void:
    _box(prefix, pos, size, mat)

func _build_side_bowl(side: float, concrete: Material, crowd: Material, rail: Material) -> void:
    var z0 := 11.2 * side

    # Four chunky stepped tiers. Cheap geometry, but real parallax and stadium scale.
    for tier in range(4):
        var t := float(tier)
        var depth := 2.3
        var height := 1.55
        var z := z0 + side * (t * 2.15)
        var y := 1.05 + t * 1.25
        _stand_step("SideConcrete_%d_%d" % [int(side), tier], Vector3(0.0, y, z), Vector3(35.5, height, depth), concrete)

        # Crowd strip on the field-facing edge of each tier.
        var crowd_z := z - side * 1.02
        _stand_step("SideCrowd_%d_%d" % [int(side), tier], Vector3(0.0, y + 0.62, crowd_z), Vector3(34.8, 0.75, 0.16), crowd)

    # Top rail / roof lip.
    _box("SideTopRail_%d" % int(side), Vector3(0.0, 6.25, z0 + side * 6.7), Vector3(36.5, 0.28, 0.35), rail)

func _build_end_bowl(x_side: float, concrete: Material, crowd: Material, rail: Material) -> void:
    var x0 := 18.2 * x_side
    for tier in range(4):
        var t := float(tier)
        var x := x0 + x_side * (t * 2.15)
        var y := 1.05 + t * 1.25
        _stand_step("EndConcrete_%d_%d" % [int(x_side), tier], Vector3(x, y, 0.0), Vector3(2.3, 1.55, 20.8), concrete)
        var crowd_x := x - x_side * 1.02
        _stand_step("EndCrowd_%d_%d" % [int(x_side), tier], Vector3(crowd_x, y + 0.62, 0.0), Vector3(0.16, 0.75, 20.1), crowd)

    _box("EndTopRail_%d" % int(x_side), Vector3(x0 + x_side * 6.7, 6.25, 0.0), Vector3(0.35, 0.28, 22.0), rail)

func _build_light_tower(name_value: String, pos: Vector3, metal: Material, glow: Material) -> void:
    _cylinder(name_value + "_Stem", pos + Vector3(0,4.0,0), 0.16, 8.0, metal)
    _box(name_value + "_Bank", pos + Vector3(0,8.0,0), Vector3(0.65,1.25,3.0), metal)
    for zoff in [-1.0, 0.0, 1.0]:
        _box(name_value + "_Glow_%s" % str(zoff), pos + Vector3(-0.37,8.0,zoff), Vector3(0.08,0.62,0.58), glow)

func _build_the_pit_2() -> void:
    # Existing gameplay collision remains untouched in main.tscn.
    # Visual field stays at the original scale so player / AI code does not need a rewrite.
    var turf_mat := _make_material(Color(0.04,0.09,0.035,1), Color(0.02,0.12,0.03,1), 0.05, 0.0, 0.92)
    var turf_tex = _load_tex("res://thepit.png")
    if turf_tex != null:
        turf_mat.albedo_texture = turf_tex
        turf_mat.albedo_color = Color(1,1,1,1)

    var pink := _make_material(Color(0.075,0.005,0.042,1), Color(1.0,0.02,0.52,1), 1.28, 0.18, 0.46)
    var acid := _make_material(Color(0.055,0.10,0.015,1), Color(0.52,1.0,0.02,1), 1.05, 0.08, 0.56)
    var cyan := _make_material(Color(0.008,0.05,0.075,1), Color(0.02,0.82,1.0,1), 1.15, 0.12, 0.44)
    var concrete := _make_material(Color(0.035,0.035,0.045,1), Color(0.03,0.00,0.04,1), 0.04, 0.18, 0.74)
    var metal := _make_material(Color(0.016,0.016,0.023,1), Color(0.06,0.00,0.05,1), 0.10, 0.62, 0.34)
    var crowd := _make_material(Color(0.16,0.05,0.18,1), Color(0.40,0.03,0.45,1), 0.38, 0.0, 0.72)
    var scoreboard_mat := _make_material(Color(0.01,0.015,0.02,1), Color(0.05,0.55,0.18,1), 0.68, 0.35, 0.30)

    # Field and hard boundary.
    _box("HD_Turf", Vector3(0,0.115,0), Vector3(34.0,0.035,19.0), turf_mat)
    _box("SidelineL", Vector3(0,0.45,-9.7), Vector3(34.8,0.58,0.24), pink)
    _box("SidelineR", Vector3(0,0.45,9.7), Vector3(34.8,0.58,0.24), pink)
    _box("EndWallA", Vector3(-17.45,0.52,0), Vector3(0.24,0.72,19.6), cyan)
    _box("EndWallB", Vector3(17.45,0.52,0), Vector3(0.24,0.72,19.6), acid)

    # Proper enclosed bowl — this is the major change.
    _build_side_bowl(-1.0, concrete, crowd, pink)
    _build_side_bowl(1.0, concrete, crowd, pink)
    _build_end_bowl(-1.0, concrete, crowd, cyan)
    _build_end_bowl(1.0, concrete, crowd, acid)

    # Corner buttresses make the four stands read as one arena, not four floating slabs.
    for xs in [-1.0,1.0]:
        for zs in [-1.0,1.0]:
            _box("Corner_%d_%d" % [int(xs),int(zs)], Vector3(20.1*xs,3.2,13.2*zs), Vector3(3.0,6.3,3.0), metal)

    # Goal structure at scoring end.
    _cylinder("GoalStem", Vector3(16.15,1.75,0), 0.08,3.3, cyan)
    _box("GoalCross", Vector3(16.15,3.0,0), Vector3(0.12,0.12,4.2), cyan)
    _cylinder("GoalL", Vector3(16.15,4.15,-2.0), 0.055,2.3, cyan)
    _cylinder("GoalR", Vector3(16.15,4.15,2.0), 0.055,2.3, cyan)

    # Massive scoreboard / mutant jumbotron behind scoring end.
    _box("ScoreboardFrame", Vector3(23.0,8.4,0), Vector3(1.0,6.0,12.0), metal)
    _box("ScoreboardGlow", Vector3(22.42,8.4,0), Vector3(0.08,4.7,10.4), scoreboard_mat)
    var score := _label("THE PIT\nTITANS  00  //  MUTANTS  00", Vector3(22.28,8.6,0), Vector3(0,-90,0), Color(0.60,1.0,0.08,1), 56)
    score.outline_size = 12

    # Stadium branding.
    _label("SKULL JUICE", Vector3(-7.0,2.2,-10.0), Vector3(0,0,0), Color(0.55,1,0.08,1), 38)
    _label("MUTANT LOOPS", Vector3(7.0,2.2,-10.0), Vector3(0,0,0), Color(1,0.05,0.55,1), 38)
    _label("NO MERCY // NO REFUNDS", Vector3(0.0,5.6,15.55), Vector3(0,180,0), Color(1,0.05,0.55,1), 46)
    _label("TITAN CITY MUTANT FOOTBALL", Vector3(-23.0,5.0,0), Vector3(0,90,0), Color(0.10,0.82,1.0,1), 44)

    # Sludge tanks outside the near sideline.
    for side_value in [-1,1]:
        var side := float(side_value)
        var z := 10.65 * side
        for x in [-13,-8,-3,2,7,12]:
            _cylinder("Sludge_%d_%d" % [side_value,x], Vector3(float(x),1.55,z), 0.24,2.2, acid)

    # Four tall light towers sell the arena scale.
    _build_light_tower("LightNW", Vector3(-19.8,0,-13.0), metal, cyan)
    _build_light_tower("LightSW", Vector3(-19.8,0,13.0), metal, cyan)
    _build_light_tower("LightNE", Vector3(19.8,0,-13.0), metal, pink)
    _build_light_tower("LightSE", Vector3(19.8,0,13.0), metal, pink)

    # Keep existing skyline/backdrop as a distant layer only, not as the stadium itself.
    var backdrop = _load_tex("res://pit_backdrop.png")
    if backdrop != null:
        var bg := Sprite3D.new()
        bg.name = "TitanCityHorizon"
        bg.texture = backdrop
        bg.position = Vector3(31.0,13.0,0)
        bg.rotation_degrees = Vector3(0,-90,0)
        bg.pixel_size = 0.030
        bg.modulate = Color(0.78,0.78,0.88,1)
        bg.no_depth_test = false
        add_child(bg)
