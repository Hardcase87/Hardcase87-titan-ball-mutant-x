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
    rotate_y(delta*2.0)
    position.y=base_y+sin(t*2.6)*0.12

func _build()->void:
    var mesh_node:=MeshInstance3D.new()
    var mesh:=CylinderMesh.new()
    mesh.top_radius=0.28;mesh.bottom_radius=0.28;mesh.height=0.68
    var mat:=StandardMaterial3D.new()
    mat.albedo_color=Color(0.12,0.20,0.04,1) if kind=="juice" else Color(0.22,0.02,0.18,1)
    mat.emission_enabled=true
    mat.emission=Color(0.55,1.0,0.05,1) if kind=="juice" else Color(1.0,0.04,0.55,1)
    mat.emission_energy_multiplier=2.5
    mesh.material=mat;mesh_node.mesh=mesh;add_child(mesh_node)

    var shape:=CollisionShape3D.new()
    var sphere:=SphereShape3D.new();sphere.radius=0.65
    shape.shape=sphere;add_child(shape)

    var l:=Label3D.new()
    l.text="SKULL\nJUICE" if kind=="juice" else "MUTANT\nLOOPS"
    l.font_size=34;l.position=Vector3(0,0.62,0);l.modulate=mat.emission;l.outline_size=6
    add_child(l)

func _on_body(body:Node)->void:
    if not body.is_in_group("player"):return
    if kind=="juice":body.heal(25)
    else:body.add_mutation(35)
    queue_free()
