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

    _build_the_pit_ttd()

func _process(delta: float) -> void:
    phase += delta
    for i in range(pulse_materials.size()):
        var m = pulse_materials[i]
        if m != null:
            m.emission_energy_multiplier = 1.15 + 0.28 * sin(phase * 2.0 + float(i) * 0.51)

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
    l.outline_size = 10
    l.position = pos
    l.rotation_degrees = rot
    add_child(l)
    return l

func _load_tex(path: String):
    if ResourceLoader.exists(path):
        return load(path)
    return null

func _build_side_bowl(side: float, concrete: Material, crowd: Material, rail: Material, acid: Material) -> void:
    var z0 := 11.0 * side
    for tier in range(5):
        var t := float(tier)
        var z := z0 + side * (t * 1.95)
        var y := 0.95 + t * 1.10
        _box("SideConcrete_%d_%d" % [int(side), tier], Vector3(0.0, y, z), Vector3(36.0, 1.35, 2.2), concrete)
        var crowd_z := z - side * 0.95
        _box("SideCrowd_%d_%d" % [int(side), tier], Vector3(0.0, y + 0.58, crowd_z), Vector3(35.2, 0.76, 0.18), crowd)

    _box("SideTopRail_%d" % int(side), Vector3(0.0, 6.25, z0 + side * 7.9), Vector3(37.0, 0.25, 0.38), rail)

    # Neon ribbon board running the full stadium side.
    _box("Ribbon_%d" % int(side), Vector3(0.0, 3.5, z0 + side * 0.12), Vector3(35.2, 0.52, 0.12), rail)
    var sign_z := z0 - side * 0.02
    var rot_y := 0.0 if side < 0.0 else 180.0
    _label("THE PIT  //  TTD  //  NO MERCY  //  TITAN BALL  //  MUTANT X", Vector3(0,3.5,sign_z), Vector3(0,rot_y,0), Color(1,0.05,0.55,1), 34)

    # Toxic canisters along the lower rail.
    for x in [-14,-10,-6,-2,2,6,10,14]:
        _cylinder("SideSludge_%d_%d" % [int(side),x], Vector3(float(x),1.0,9.95*side), 0.16, 1.15, acid)

func _build_end_bowl(x_side: float, concrete: Material, crowd: Material, rail: Material) -> void:
    var x0 := 18.0 * x_side
    for tier in range(5):
        var t := float(tier)
        var xx := x0 + x_side * (t * 1.95)
        var y := 0.95 + t * 1.10
        _box("EndConcrete_%d_%d" % [int(x_side), tier], Vector3(xx,y,0), Vector3(2.2,1.35,21.0), concrete)
        var crowd_x := xx - x_side * 0.95
        _box("EndCrowd_%d_%d" % [int(x_side), tier], Vector3(crowd_x,y+0.58,0), Vector3(0.18,0.76,20.2), crowd)
    _box("EndTopRail_%d" % int(x_side), Vector3(x0 + x_side*7.9,6.25,0), Vector3(0.38,0.25,22.2), rail)

func _build_light_tower(name_value: String, pos: Vector3, metal: Material, glow: Material) -> void:
    _cylinder(name_value+"_StemA", pos+Vector3(0,4.0,-0.48),0.13,8.0,metal)
    _cylinder(name_value+"_StemB", pos+Vector3(0,4.0,0.48),0.13,8.0,metal)
    _box(name_value+"_Cross",pos+Vector3(0,8.0,0),Vector3(0.45,0.45,3.4),metal)
    for zoff in [-1.2,-0.4,0.4,1.2]:
        _box(name_value+"_Lamp_%s" % str(zoff),pos+Vector3(-0.28,8.0,zoff),Vector3(0.12,0.72,0.62),glow)

func _build_pipe_arch(name_value: String, x: float, metal: Material, glow: Material) -> void:
    _cylinder(name_value+"_L",Vector3(x,5.0,-5.6),0.24,8.0,metal)
    _cylinder(name_value+"_R",Vector3(x,5.0,5.6),0.24,8.0,metal)
    _box(name_value+"_Top",Vector3(x,9.0,0),Vector3(0.42,0.42,11.5),metal)
    _box(name_value+"_Glow",Vector3(x-0.28,9.0,0),Vector3(0.06,0.22,10.3),glow)

func _build_fortress_face(metal: Material, pink: Material, acid: Material, cyan: Material) -> void:
    # Giant industrial fortress behind the far end zone.
    _box("FortressCore",Vector3(23.8,7.1,0),Vector3(2.2,13.5,18.6),metal)
    _box("FortressWingL",Vector3(22.3,6.0,-10.4),Vector3(3.6,11.2,4.0),metal)
    _box("FortressWingR",Vector3(22.3,6.0,10.4),Vector3(3.6,11.2,4.0),metal)

    # Main TTD THE PIT screen.
    _box("PitScreenFrame",Vector3(22.55,9.0,0),Vector3(0.65,6.0,13.6),metal)
    _box("PitScreenPink",Vector3(22.18,9.0,0),Vector3(0.06,5.25,12.7),pink)
    var main_label := _label("TTD  THE PIT\nTITANS  VS  MUTANTS",Vector3(22.08,9.2,0),Vector3(0,-90,0),Color(0.7,1.0,0.05,1),72)
    main_label.outline_size = 16

    # Giant skull crown made from simple geometry so it exists in 3D even without art.
    _box("SkullCrown",Vector3(23.2,14.4,0),Vector3(1.6,2.7,3.2),metal)
    _box("SkullEyeL",Vector3(22.3,14.7,-0.78),Vector3(0.12,0.65,0.75),pink)
    _box("SkullEyeR",Vector3(22.3,14.7,0.78),Vector3(0.12,0.65,0.75),acid)
    _box("SkullMouth",Vector3(22.28,13.65,0),Vector3(0.12,0.48,1.7),cyan)

    # Side tower branding.
    _label("TTD",Vector3(21.0,8.0,-12.0),Vector3(0,-90,0),Color(0.55,1,0.05,1),62)
    _label("TTD",Vector3(21.0,8.0,12.0),Vector3(0,-90,0),Color(1,0.05,0.55,1),62)

    # Pipe arches make the end zone feel like a refinery.
    _build_pipe_arch("PipeArchA",20.0,metal,pink)
    _build_pipe_arch("PipeArchB",24.5,metal,acid)

func _build_concept_screen() -> void:
    var tex = _load_tex("res://the_pit_fortress.png")
    if tex == null:
        return
    var bg := Sprite3D.new()
    bg.name = "ThePitFortressConcept"
    bg.texture = tex
    bg.position = Vector3(25.65,8.4,0)
    bg.rotation_degrees = Vector3(0,-90,0)
    bg.pixel_size = 0.0108
    bg.modulate = Color(0.88,0.88,0.92,1)
    bg.no_depth_test = false
    bg.render_priority = -1
    add_child(bg)

func _build_the_pit_ttd() -> void:
    var turf_mat := _make_material(Color(0.04,0.09,0.035,1),Color(0.02,0.12,0.03,1),0.06,0.0,0.92)
    var turf_tex = _load_tex("res://thepit.png")
    if turf_tex != null:
        turf_mat.albedo_texture = turf_tex
        turf_mat.albedo_color = Color(1,1,1,1)

    var pink := _make_material(Color(0.075,0.005,0.042,1),Color(1.0,0.02,0.52,1),1.55,0.18,0.42)
    var acid := _make_material(Color(0.055,0.10,0.015,1),Color(0.52,1.0,0.02,1),1.35,0.08,0.52)
    var cyan := _make_material(Color(0.008,0.05,0.075,1),Color(0.02,0.82,1.0,1),1.30,0.12,0.40)
    var concrete := _make_material(Color(0.025,0.025,0.035,1),Color(0.03,0.0,0.04,1),0.03,0.22,0.78)
    var metal := _make_material(Color(0.012,0.012,0.018,1),Color(0.05,0.0,0.04,1),0.08,0.72,0.30)
    var crowd := _make_material(Color(0.11,0.025,0.12,1),Color(0.35,0.02,0.40,1),0.32,0.0,0.74)

    # Gameplay turf remains exactly same scale.
    _box("HD_Turf",Vector3(0,0.115,0),Vector3(34.0,0.035,19.0),turf_mat)

    # Boundary rails.
    _box("SidelineL",Vector3(0,0.45,-9.7),Vector3(34.8,0.58,0.24),pink)
    _box("SidelineR",Vector3(0,0.45,9.7),Vector3(34.8,0.58,0.24),pink)
    _box("EndWallA",Vector3(-17.45,0.52,0),Vector3(0.24,0.72,19.6),cyan)
    _box("EndWallB",Vector3(17.45,0.52,0),Vector3(0.24,0.72,19.6),acid)

    # Five-tier enclosed stadium.
    _build_side_bowl(-1.0,concrete,crowd,pink,acid)
    _build_side_bowl(1.0,concrete,crowd,pink,acid)
    _build_end_bowl(-1.0,concrete,crowd,cyan)
    _build_end_bowl(1.0,concrete,crowd,acid)

    # Massive corner towers.
    for xs in [-1.0,1.0]:
        for zs in [-1.0,1.0]:
            _box("Corner_%d_%d" % [int(xs),int(zs)],Vector3(20.3*xs,4.1,13.5*zs),Vector3(3.4,8.2,3.4),metal)
            _cylinder("CornerTank_%d_%d" % [int(xs),int(zs)],Vector3(20.3*xs,9.2,13.5*zs),1.1,3.2,metal)

    # Goal.
    _cylinder("GoalStem",Vector3(16.15,1.75,0),0.08,3.3,cyan)
    _box("GoalCross",Vector3(16.15,3.0,0),Vector3(0.12,0.12,4.2),cyan)
    _cylinder("GoalL",Vector3(16.15,4.15,-2.0),0.055,2.3,cyan)
    _cylinder("GoalR",Vector3(16.15,4.15,2.0),0.055,2.3,cyan)

    # Main fortress / giant TTD screen.
    _build_fortress_face(metal,pink,acid,cyan)
    _build_concept_screen()

    # Stadium wall propaganda.
    _label("NO MERCY\nALL MUTANT",Vector3(-7.8,3.0,-10.15),Vector3(0,0,0),Color(0.55,1,0.06,1),38)
    _label("VICTORY\nOR EXTINCTION",Vector3(8.5,3.0,-10.15),Vector3(0,0,0),Color(1,0.05,0.55,1),38)
    _label("THE PIT",Vector3(-14.0,5.4,10.2),Vector3(0,180,0),Color(1,0.05,0.55,1),44)
    _label("TITAN BALL",Vector3(14.0,5.4,10.2),Vector3(0,180,0),Color(0.55,1,0.06,1),44)

    # Industrial smoke / tower silhouettes.
    for x in [-15.0,-9.0,-3.0,3.0,9.0,15.0]:
        _cylinder("Refinery_%s" % str(x),Vector3(24.8,11.5,x*0.60),0.52,8.0,metal)
        _cylinder("RefineryGlow_%s" % str(x),Vector3(24.15,12.8,x*0.60),0.18,3.8,acid if int(x)%2==0 else pink)

    # Tall floodlights.
    _build_light_tower("LightNW",Vector3(-19.8,0,-13.0),metal,cyan)
    _build_light_tower("LightSW",Vector3(-19.8,0,13.0),metal,cyan)
    _build_light_tower("LightNE",Vector3(19.8,0,-13.0),metal,pink)
    _build_light_tower("LightSE",Vector3(19.8,0,13.0),metal,pink)

    # Existing city horizon retained behind everything.
    var backdrop = _load_tex("res://pit_backdrop.png")
    if backdrop != null:
        var bg := Sprite3D.new()
        bg.name = "TitanCityHorizon"
        bg.texture = backdrop
        bg.position = Vector3(32.0,14.0,0)
        bg.rotation_degrees = Vector3(0,-90,0)
        bg.pixel_size = 0.031
        bg.modulate = Color(0.56,0.56,0.66,1)
        bg.no_depth_test = false
        add_child(bg)
