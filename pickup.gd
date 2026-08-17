extends Area3D
class_name MutantXPickup

@export var kind:="juice"
var base_y:=0.7
var t:=0.0

func _ready()->void:
    base_y=position.y
    body_entered.connect(_on_body)
    _build()

func _process(delta:float)->void:
    t+=delta
    rotate_y(delta*1.8)
    position.y=base_y+sin(t*2.4)*0.10

func _build()->void:
    var mesh_node:=MeshInstance3D.new()
    var mesh:=CylinderMesh.new()
    mesh.top_radius=0.24
    mesh.bottom_radius=0.29
    mesh.height=0.62

    var material:=StandardMaterial3D.new()
    material.albedo_color=Color(0.05,0.12,0.02,1) if kind=="juice" else Color(0.14,0.01,0.10,1)
    material.metallic=0.48
    material.roughness=0.30
    material.emission_enabled=true
    material.emission=Color(0.55,1.0,0.04,1) if kind=="juice" else Color(1.0,0.03,0.55,1)
    material.emission_energy_multiplier=2.0
    mesh.material=material
    mesh_node.mesh=mesh
    add_child(mesh_node)

    var ring:=MeshInstance3D.new()
    var torus:=TorusMesh.new()
    torus.inner_radius=0.34
    torus.outer_radius=0.40
    torus.material=material
    ring.mesh=torus
    ring.rotation_degrees=Vector3(90,0,0)
    ring.position=Vector3(0,-0.28,0)
    add_child(ring)

    var shape:=CollisionShape3D.new()
    var sphere:=SphereShape3D.new()
    sphere.radius=0.62
    shape.shape=sphere
    add_child(shape)

    var label:=Label3D.new()
    label.text="SKULL JUICE" if kind=="juice" else "MUTANT LOOPS"
    label.font_size=28
    label.position=Vector3(0,0.58,0)
    label.modulate=material.emission
    label.outline_size=5
    label.billboard=1
    add_child(label)

func _on_body(body:Node)->void:
    if not body.is_in_group("player"):
        return
    if kind=="juice":
        body.heal(25)
    else:
        body.add_mutation(35)
    queue_free()
