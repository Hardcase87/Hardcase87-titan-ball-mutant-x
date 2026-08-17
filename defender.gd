extends CharacterBody3D
class_name MutantXDefender

@export var target_path:NodePath
@export var archetype:="chaser"
@export var lane_bias:=0.0
@export var chase_speed:=5.7
@export var acceleration:=18.0
@export var tackle_damage:=10
@export var tackle_force:=8.0

var target:CharacterBody3D
var stunned:=0.0
var hit_cooldown:=0.0
var active:=false
var home_position:=Vector3.ZERO
var rig:Node3D
var left_arm:Node3D
var right_arm:Node3D
var left_leg:Node3D
var right_leg:Node3D
var run_clock:=0.0

func _ready()->void:
    home_position=global_position
    target=get_node_or_null(target_path)
    _configure()
    _build()

func _configure()->void:
    if archetype=="speed":
        chase_speed=7.2;tackle_damage=8;tackle_force=6.5
    elif archetype=="bruiser":
        chase_speed=4.7;tackle_damage=16;tackle_force=11.0
    else:
        chase_speed=5.8;tackle_damage=10;tackle_force=8.0

func _mat(color:Color, emission:Color=Color(0,0,0,1), energy:=0.0)->StandardMaterial3D:
    var m:=StandardMaterial3D.new()
    m.albedo_color=color
    m.metallic=0.18
    m.roughness=0.52
    if energy>0.0:
        m.emission_enabled=true
        m.emission=emission
        m.emission_energy_multiplier=energy
    return m

func _box(parent:Node,pos:Vector3,size:Vector3,mat:Material)->MeshInstance3D:
    var n:=MeshInstance3D.new();var mesh:=BoxMesh.new()
    mesh.size=size;mesh.material=mat;n.mesh=mesh;n.position=pos;parent.add_child(n);return n

func _capsule(parent:Node,pos:Vector3,r:float,h:float,mat:Material)->MeshInstance3D:
    var n:=MeshInstance3D.new();var mesh:=CapsuleMesh.new()
    mesh.radius=r;mesh.height=h;mesh.material=mat;n.mesh=mesh;n.position=pos;parent.add_child(n);return n

func _sphere(parent:Node,pos:Vector3,r:float,mat:Material)->MeshInstance3D:
    var n:=MeshInstance3D.new();var mesh:=SphereMesh.new()
    mesh.radius=r;mesh.height=r*2.0;mesh.material=mat;n.mesh=mesh;n.position=pos;parent.add_child(n);return n

func _build()->void:
    var black:=_mat(Color(0.02,0.018,0.028,1))
    var hot:=_mat(Color(0.34,0.01,0.18,1),Color(1.0,0.03,0.55,1),1.7)
    var acid:=_mat(Color(0.22,0.55,0.03,1),Color(0.55,1.0,0.04,1),1.4)
    rig=Node3D.new();rig.position.y=-0.82;add_child(rig)

    var scale_mult:=1.0
    if archetype=="speed":scale_mult=0.92
    if archetype=="bruiser":scale_mult=1.18
    rig.scale=Vector3(scale_mult,scale_mult,scale_mult)

    _box(rig,Vector3(0,1.55,0),Vector3(0.90,0.94,0.56),black)
    _box(rig,Vector3(0,1.84,-0.58),Vector3(0.52,0.36,0.58),hot)
    _box(rig,Vector3(0,1.84,0.58),Vector3(0.52,0.36,0.58),hot)
    _sphere(rig,Vector3(0,2.28,0),0.37,black)
    _box(rig,Vector3(-0.31,2.29,0),Vector3(0.15,0.21,0.55),acid)

    left_arm=Node3D.new();left_arm.position=Vector3(0,1.72,-0.68);rig.add_child(left_arm)
    right_arm=Node3D.new();right_arm.position=Vector3(0,1.72,0.68);rig.add_child(right_arm)
    _capsule(left_arm,Vector3(0,-0.32,0),0.15,0.72,black)
    _capsule(right_arm,Vector3(0,-0.32,0),0.15,0.72,black)

    left_leg=Node3D.new();left_leg.position=Vector3(0,1.08,-0.27);rig.add_child(left_leg)
    right_leg=Node3D.new();right_leg.position=Vector3(0,1.08,0.27);rig.add_child(right_leg)
    _capsule(left_leg,Vector3(0,-0.43,0),0.19,0.90,black)
    _capsule(right_leg,Vector3(0,-0.43,0),0.19,0.90,black)

    var n:=Label3D.new()
    n.text="88" if archetype!="bruiser" else "66"
    n.font_size=78
    n.modulate=Color(1.0,0.03,0.55,1)
    n.position=Vector3(-0.48,1.58,0)
    n.rotation_degrees=Vector3(0,-90,0)
    n.outline_size=8
    rig.add_child(n)

func _physics_process(delta:float)->void:
    stunned=max(0.0,stunned-delta)
    hit_cooldown=max(0.0,hit_cooldown-delta)

    if not active:
        velocity.x=move_toward(velocity.x,0.0,12.0*delta)
        velocity.z=move_toward(velocity.z,0.0,12.0*delta)
    elif target:
        if stunned>0.0:
            velocity.x=move_toward(velocity.x,0.0,7.0*delta)
            velocity.z=move_toward(velocity.z,0.0,7.0*delta)
        else:
            var aim:=target.global_position+Vector3(0,0,lane_bias)
            var to_target:=aim-global_position
            to_target.y=0
            var desired:=to_target.normalized()*chase_speed

            # Cheap separation steering keeps the defensive wall readable.
            var separation:=Vector3.ZERO
            for other in get_tree().get_nodes_in_group("defender"):
                if other==self or other==null:
                    continue
                var away:=global_position-other.global_position
                away.y=0
                var dist:=away.length()
                if dist>0.01 and dist<1.65:
                    separation+=away.normalized()*(1.65-dist)*3.2
            desired+=separation

            velocity.x=move_toward(velocity.x,desired.x,acceleration*delta)
            velocity.z=move_toward(velocity.z,desired.z,acceleration*delta)

    velocity.y=-0.1 if is_on_floor() else velocity.y-28.0*delta
    move_and_slide()
    _animate(delta)

    if active and target and hit_cooldown<=0.0 and global_position.distance_to(target.global_position)<1.08:
        if target.has_method("receive_tackle"):
            var push:=(target.global_position-global_position).normalized()
            target.receive_tackle(tackle_damage,push*tackle_force)
            hit_cooldown=1.0

func _animate(delta:float)->void:
    if rig==null:return
    var speed:=Vector2(velocity.x,velocity.z).length()
    run_clock+=delta*(8.0+speed)
    var swing:=sin(run_clock)
    var stride:=0.65 if speed>0.3 else 0.08
    left_arm.rotation.z=swing*stride
    right_arm.rotation.z=-swing*stride
    left_leg.rotation.z=-swing*stride*0.7
    right_leg.rotation.z=swing*stride*0.7
    rig.position.y=-0.82+abs(sin(run_clock*2.0))*0.045

func smash_hit(from_position:Vector3,force:float)->void:
    var dir:=global_position-from_position
    dir.y=0
    if dir.length()<0.01:dir=Vector3(1,0,0)
    velocity=dir.normalized()*force
    velocity.y=3.0
    stunned=0.9
    hit_cooldown=0.5

func reset_defender()->void:
    global_position=home_position
    velocity=Vector3.ZERO
    stunned=0.0
    hit_cooldown=0.45
