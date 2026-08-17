extends CharacterBody3D

signal impact_fx(kind:String, strength:float)
signal character_changed(id:String)

@export var character_id := "dex"

var base_speed := 8.0
var dash_speed := 15.0
var acceleration := 36.0
var friction := 32.0
var max_hp := 100
var power := 1.0

var hp := 100
var mutation_meter := 0.0
var dash_timer := 0.0
var smash_timer := 0.0
var mutation_timer := 0.0
var tackle_lock := 0.0
var touch_vector := Vector2.ZERO
var touch_dash := false
var touch_smash := false
var touch_mutation := false
var knockback := Vector3.ZERO
var active := false
var match_controller:Node

var rig:Node3D
var torso:MeshInstance3D
var left_arm:Node3D
var right_arm:Node3D
var left_leg:Node3D
var right_leg:Node3D
var run_clock := 0.0
var primary_mat:StandardMaterial3D
var secondary_mat:StandardMaterial3D
var visor_mat:StandardMaterial3D
var black_mat:StandardMaterial3D
var skin_mat:StandardMaterial3D
var display_name := "DEX VOLT"
var display_number := "7"
var display_role := "BALANCED"
var special_name := "VOLT STORM"
var authored_model: Node3D = null
var sprite_visual: Sprite3D = null
var sprite_base_y: float = 0.34

@onready var cam:Camera3D = $Camera3D
var cam_base_pos := Vector3(-6.7,3.5,0)
var shake := 0.0

func _ready() -> void:
    add_to_group("player")
    MutantXInputSetup.ensure_actions()
    cam_base_pos = cam.position
    apply_character(character_id)

func _mat(color:Color, emission:Color=Color(0,0,0,1), energy:float=0.0) -> StandardMaterial3D:
    var m := StandardMaterial3D.new()
    m.albedo_color = color
    m.metallic = 0.22
    m.roughness = 0.48
    if energy > 0.0:
        m.emission_enabled = true
        m.emission = emission
        m.emission_energy_multiplier = energy
    return m

func _box(parent:Node,pos:Vector3,size:Vector3,mat:Material) -> MeshInstance3D:
    var n:=MeshInstance3D.new()
    var mesh:=BoxMesh.new()
    mesh.size=size
    mesh.material=mat
    n.mesh=mesh
    n.position=pos
    parent.add_child(n)
    return n

func _sphere(parent:Node,pos:Vector3,radius:float,mat:Material)->MeshInstance3D:
    var n:=MeshInstance3D.new()
    var mesh:=SphereMesh.new()
    mesh.radius=radius
    mesh.height=radius*2.0
    mesh.material=mat
    n.mesh=mesh
    n.position=pos
    parent.add_child(n)
    return n

func _capsule(parent:Node,pos:Vector3,radius:float,height:float,mat:Material)->MeshInstance3D:
    var n:=MeshInstance3D.new()
    var mesh:=CapsuleMesh.new()
    mesh.radius=radius
    mesh.height=height
    mesh.material=mat
    n.mesh=mesh
    n.position=pos
    parent.add_child(n)
    return n

func apply_character(id:String) -> void:
    character_id=id
    var c:=MutantXCharacterDB.get_character(id)
    display_name=c["name"]
    display_number=c["number"]
    display_role=c["role"]
    special_name=c["special"]
    base_speed=c["speed"]
    dash_speed=c["dash"]
    power=c["power"]
    max_hp=c["hp"]
    hp=max_hp

    if rig and is_instance_valid(rig):
        rig.queue_free()
    if authored_model and is_instance_valid(authored_model):
        authored_model.queue_free()
        authored_model = null

    black_mat=_mat(Color(0.018,0.018,0.028,1))
    primary_mat=_mat(c["primary"],c["primary"],1.5)
    secondary_mat=_mat(c["secondary"],c["secondary"],1.15)
    visor_mat=_mat(Color(0.02,0.12,0.18,1),c["visor"],2.4)
    skin_mat=_mat(Color(0.34,0.13,0.07,1))

    sprite_visual = null
    var model_path: String = c["model"]
    if ResourceLoader.exists(model_path):
        var packed = load(model_path)
        if packed is PackedScene:
            authored_model = packed.instantiate()
            authored_model.name = "AuthoredCharacter"
            authored_model.position = Vector3(0,-0.84,0)
            add_child(authored_model)
        else:
            _build_game_sprite(id)
    else:
        _build_game_sprite(id)

    character_changed.emit(id)

func _build_game_sprite(id:String) -> void:
    var sprite_path := "res://dex_game.png"
    if id=="nikki":
        sprite_path="res://nikki_game.png"
    elif id=="mack":
        sprite_path="res://mack_game.png"

    if not ResourceLoader.exists(sprite_path):
        _build_rig(id)
        return

    var sprite:=Sprite3D.new()
    sprite.name="HDGameplaySprite"
    sprite.texture=load(sprite_path)
    sprite.pixel_size=0.00215
    if id=="nikki":
        sprite.pixel_size=0.00205
    elif id=="mack":
        sprite.pixel_size=0.00245
    sprite.position=Vector3(0,sprite_base_y,0)
    sprite.billboard=1
    sprite.shaded=false
    sprite.double_sided=true
    sprite.render_priority=2
    add_child(sprite)
    sprite_visual=sprite
    authored_model=sprite

func _build_rig(id:String) -> void:
    rig=Node3D.new()
    rig.name="CharacterRig"
    rig.position.y=-0.84
    add_child(rig)

    var scale_mult:=1.0
    if id=="nikki": scale_mult=0.96
    if id=="mack": scale_mult=1.20
    rig.scale=Vector3(scale_mult,scale_mult,scale_mult)

    torso=_box(rig,Vector3(0,1.58,0),Vector3(0.84,0.94,0.52),black_mat)
    _box(rig,Vector3(-0.28,1.65,0),Vector3(0.24,0.72,0.58),primary_mat)
    _box(rig,Vector3(0,1.86,-0.55),Vector3(0.52,0.36,0.56),primary_mat)
    _box(rig,Vector3(0,1.86,0.55),Vector3(0.52,0.36,0.56),primary_mat)
    _sphere(rig,Vector3(0,2.30,0),0.36,black_mat)
    _box(rig,Vector3(-0.30,2.31,0),Vector3(0.17,0.22,0.56),visor_mat)

    if id=="dex":
        for i in range(4):
            _box(rig,Vector3(0.03+0.07*float(i),2.62+0.07*float(i),0),Vector3(0.08,0.25,0.10),secondary_mat)
    elif id=="nikki":
        for i in range(6):
            _capsule(rig,Vector3(0.12+0.10*float(i),2.37,0.28-0.10*float(i)),0.055,0.82,secondary_mat)
    else:
        _box(rig,Vector3(0.05,2.61,0),Vector3(0.42,0.24,0.38),primary_mat)
        for z in [-0.25,0.25]:
            _box(rig,Vector3(0.12,2.77,z),Vector3(0.09,0.35,0.09),secondary_mat)

    left_arm=Node3D.new(); left_arm.position=Vector3(0,1.74,-0.65); rig.add_child(left_arm)
    right_arm=Node3D.new(); right_arm.position=Vector3(0,1.74,0.65); rig.add_child(right_arm)
    _capsule(left_arm,Vector3(0,-0.31,0),0.145,0.70,skin_mat)
    _capsule(right_arm,Vector3(0,-0.31,0),0.145,0.70,skin_mat)
    _box(left_arm,Vector3(0,-0.66,0),Vector3(0.27,0.27,0.27),black_mat)
    _box(right_arm,Vector3(0,-0.66,0),Vector3(0.27,0.27,0.27),black_mat)

    left_leg=Node3D.new(); left_leg.position=Vector3(0,1.10,-0.25); rig.add_child(left_leg)
    right_leg=Node3D.new(); right_leg.position=Vector3(0,1.10,0.25); rig.add_child(right_leg)
    _capsule(left_leg,Vector3(0,-0.44,0),0.185,0.92,black_mat)
    _capsule(right_leg,Vector3(0,-0.44,0),0.185,0.92,black_mat)
    _box(left_leg,Vector3(-0.05,-0.43,0),Vector3(0.27,0.27,0.31),primary_mat)
    _box(right_leg,Vector3(-0.05,-0.43,0),Vector3(0.27,0.27,0.31),primary_mat)
    _box(left_leg,Vector3(-0.15,-0.92,0),Vector3(0.46,0.23,0.33),black_mat)
    _box(right_leg,Vector3(-0.15,-0.92,0),Vector3(0.46,0.23,0.33),black_mat)

    var num:=Label3D.new()
    num.text=display_number
    num.font_size=100
    num.modulate=primary_mat.albedo_color
    num.position=Vector3(-0.44,1.64,0)
    num.rotation_degrees=Vector3(0,-90,0)
    num.outline_size=10
    rig.add_child(num)

    # Titan Ball placeholder: replaced automatically later when authored model carries its own ball.
    var ball = MeshInstance3D.new()
    ball.name = "TitanBall"
    var ball_mesh = SphereMesh.new()
    ball_mesh.radius = 0.24
    ball_mesh.height = 0.36
    var ball_mat = StandardMaterial3D.new()
    ball_mat.albedo_color = Color(0.32,0.08,0.025,1)
    ball_mat.roughness = 0.72
    ball_mesh.material = ball_mat
    ball.mesh = ball_mesh
    ball.scale = Vector3(1.25,0.75,0.72)
    ball.position = Vector3(-0.15,1.42,-0.76)
    rig.add_child(ball)

func _physics_process(delta:float) -> void:
    tackle_lock=max(0.0,tackle_lock-delta)
    dash_timer=max(0.0,dash_timer-delta)
    smash_timer=max(0.0,smash_timer-delta)
    mutation_timer=max(0.0,mutation_timer-delta)
    shake=max(0.0,shake-delta*4.0)

    if match_controller==null:
        match_controller=get_tree().get_first_node_in_group("match_controller")

    if active:
        var input_vec:=Input.get_vector("move_left","move_right","move_forward","move_back")
        if touch_vector.length()>input_vec.length():
            input_vec=touch_vector

        var desired:=Vector3(input_vec.y,0.0,input_vec.x)
        var speed:=dash_speed if dash_timer>0.0 else base_speed
        var target:=desired.normalized()*speed if desired.length()>0.05 else Vector3.ZERO
        var rate:=acceleration if desired.length()>0.05 else friction

        velocity.x=move_toward(velocity.x,target.x,rate*delta)
        velocity.z=move_toward(velocity.z,target.z,rate*delta)

        if Input.is_action_just_pressed("dash") or touch_dash:
            dash_timer=0.32
            mutation_meter=min(100.0,mutation_meter+5.0)
            touch_dash=false
            impact_fx.emit("dash",0.35)

        if Input.is_action_just_pressed("smash") or touch_smash:
            smash_timer=0.30
            touch_smash=false
            _smash_nearby()

        if (Input.is_action_just_pressed("mutation") or touch_mutation) and mutation_meter>=100.0:
            mutation_timer=4.0
            mutation_meter=0.0
            touch_mutation=false
            shake=0.55
            impact_fx.emit("mutation",0.8)

        if mutation_timer>0.0:
            velocity.x*=1.02
            velocity.z*=1.02
    else:
        velocity.x=move_toward(velocity.x,0.0,friction*delta)
        velocity.z=move_toward(velocity.z,0.0,friction*delta)

    velocity.x+=knockback.x
    velocity.z+=knockback.z
    knockback=knockback.lerp(Vector3.ZERO,min(1.0,delta*9.0))
    velocity.y=-0.1 if is_on_floor() else velocity.y-28.0*delta

    move_and_slide()
    global_position.x=clamp(global_position.x,-16.7,16.7)
    global_position.z=clamp(global_position.z,-9.25,9.25)

    _animate(delta)
    _camera_fx(delta)

func _animate(delta:float) -> void:
    if sprite_visual != null:
        var sprite_speed:=Vector2(velocity.x,velocity.z).length()
        run_clock+=delta*(8.0+sprite_speed)
        var bob:=0.025
        if sprite_speed>0.3:
            bob=0.075
        if dash_timer>0.0:
            bob=0.11
        sprite_visual.position.y=sprite_base_y+abs(sin(run_clock*2.0))*bob
        var lean_target:=-0.08 if dash_timer>0.0 else 0.0
        sprite_visual.rotation.z=lerp(sprite_visual.rotation.z,lean_target,min(1.0,delta*9.0))
        var pulse:=1.0
        if mutation_timer>0.0:
            pulse=1.0+0.045*sin(Time.get_ticks_msec()/70.0)
        sprite_visual.scale=Vector3(pulse,pulse,pulse)
        return
    if authored_model != null:
        return
    if rig==null:return
    var planar:=Vector2(velocity.x,velocity.z).length()
    var moving:=planar>0.25
    run_clock+=delta*(12.0 if moving else 2.0)
    if dash_timer>0.0: run_clock+=delta*8.0

    var swing:=sin(run_clock)
    var stride:=0.76 if moving else 0.08
    left_arm.rotation.z=swing*stride
    right_arm.rotation.z=-swing*stride
    left_leg.rotation.z=-swing*stride*0.72
    right_leg.rotation.z=swing*stride*0.72
    rig.position.y=-0.84+abs(sin(run_clock*2.0))*(0.07 if moving else 0.018)
    rig.rotation.z=lerp(rig.rotation.z,-0.18 if dash_timer>0.0 else 0.0,min(1.0,delta*10.0))

    if smash_timer>0.0:
        right_arm.rotation.z=-1.85+sin(smash_timer*25.0)*0.25
        torso.rotation.x=-0.22
    else:
        torso.rotation.x=lerp(torso.rotation.x,0.0,min(1.0,delta*10.0))

    var pulse:=1.0+sin(Time.get_ticks_msec()/75.0)*0.2
    primary_mat.emission_energy_multiplier=(3.5*pulse if mutation_timer>0.0 else 1.5)
    secondary_mat.emission_energy_multiplier=(3.0*pulse if mutation_timer>0.0 else 1.15)
    visor_mat.emission_energy_multiplier=(4.3*pulse if mutation_timer>0.0 else 2.4)

func _camera_fx(delta:float) -> void:
    var target_fov:=73.0 if dash_timer>0.0 else 68.0
    if mutation_timer>0.0: target_fov=77.0
    cam.fov=lerp(cam.fov,target_fov,min(1.0,delta*7.0))
    var jitter:=Vector3.ZERO
    if shake>0.0:
        jitter=Vector3(
            sin(Time.get_ticks_msec()*0.045),
            cos(Time.get_ticks_msec()*0.061),
            sin(Time.get_ticks_msec()*0.053)
        )*shake*0.13
    cam.position=cam_base_pos+jitter

func _smash_nearby() -> void:
    var hit:=false
    for enemy in get_tree().get_nodes_in_group("defender"):
        if enemy and global_position.distance_to(enemy.global_position)<=2.25 and enemy.has_method("smash_hit"):
            enemy.smash_hit(global_position,12.5*power)
            mutation_meter=min(100.0,mutation_meter+17.0)
            hit=true
    if hit:
        shake=0.75
        impact_fx.emit("smash",0.9)
    else:
        impact_fx.emit("whiff",0.18)

func receive_tackle(damage:int,push:Vector3) -> void:
    if tackle_lock>0.0 or dash_timer>0.0 or not active:return
    hp=max(0,hp-damage)
    knockback+=push
    tackle_lock=0.65
    shake=0.8
    impact_fx.emit("tackle",1.0)
    if match_controller and match_controller.has_method("end_down"):
        match_controller.end_down("TACKLED // -%d HP" % damage)

func heal(amount:int)->void: hp=min(max_hp,hp+amount)
func add_mutation(amount:float)->void: mutation_meter=min(100.0,mutation_meter+amount)

func reset_player(pos:Vector3)->void:
    global_position=pos
    velocity=Vector3.ZERO
    knockback=Vector3.ZERO
    tackle_lock=0.5

func set_touch_direction(v:Vector2)->void: touch_vector=v
func fire_dash()->void: touch_dash=true
func fire_smash()->void: touch_smash=true
func fire_mutation()->void: touch_mutation=true
