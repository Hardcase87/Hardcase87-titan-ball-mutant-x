extends Node
class_name MutantXMatchController

signal hud_changed(down:int,yards_to_go:int,field_yards:int,score:int,drive:int,message:String)
signal major_event(text:String)

@export var player_path:NodePath
var player:CharacterBody3D
var defenders:Array[Node]=[]
var active:=false
var down:=1
var yards_to_go:=20
var field_yards:=0
var score:=0
var drive:=1
var start_x:=-12.0
var touchdown_x:=13.2
var last_down_x:=-12.0
var reset_timer:=0.0
var message:="DRIVE 1"
var game_over:=false

func _ready()->void:
    add_to_group("match_controller")
    player=get_node_or_null(player_path)
    call_deferred("_collect")
    if player:last_down_x=player.global_position.x
    _emit()

func _collect()->void:
    defenders=get_tree().get_nodes_in_group("defender")

func set_active(v:bool)->void:
    active=v
    if player:player.active=v
    for d in defenders:
        if d:d.active=v

func _physics_process(delta:float)->void:
    if not active or player==null or game_over:return

    if reset_timer>0.0:
        reset_timer-=delta
        if reset_timer<=0.0:_reset_play()
        return

    field_yards=max(0,int((player.global_position.x-start_x)*3.0))
    yards_to_go=max(0,20-int((player.global_position.x-last_down_x)*3.0))

    if player.global_position.x>=touchdown_x:
        score+=7
        message="TOUCHDOWN // +7"
        major_event.emit("TOUCHDOWN")
        drive+=1
        reset_timer=1.5
        _emit()
        return

    if player.hp<=0:
        message="KNOCKED OUT // GAME OVER"
        major_event.emit("GAME OVER")
        game_over=true
        _emit()

func end_down(reason:String="TACKLED")->void:
    if reset_timer>0.0 or game_over or not active:return
    var gained:=int((player.global_position.x-last_down_x)*3.0)
    if gained>=20:
        down=1
        last_down_x=player.global_position.x
        yards_to_go=20
        message="FIRST DOWN"
        major_event.emit("FIRST DOWN")
    else:
        down+=1
        message=reason
        if down>4:
            down=1
            drive+=1
            last_down_x=start_x
            message="TURNOVER // DRIVE %d" % drive
            major_event.emit("TURNOVER")
    reset_timer=0.95
    _emit()

func _reset_play()->void:
    if player==null:return

    if message.begins_with("TOUCHDOWN") or message.begins_with("TURNOVER"):
        player.reset_player(Vector3(start_x,1.1,0))
        last_down_x=start_x
        field_yards=0
        yards_to_go=20
    else:
        player.reset_player(Vector3(player.global_position.x,1.1,0))

    for d in defenders:
        if d and d.has_method("reset_defender"):d.reset_defender()

    message="DRIVE %d" % drive
    _emit()

func restart_game()->void:
    score=0;drive=1;down=1;yards_to_go=20;field_yards=0
    last_down_x=start_x;game_over=false;message="DRIVE 1"
    player.hp=player.max_hp
    player.mutation_meter=0.0
    player.reset_player(Vector3(start_x,1.1,0))
    for d in defenders:
        if d and d.has_method("reset_defender"):d.reset_defender()
    _emit()

func _emit()->void:
    hud_changed.emit(down,yards_to_go,field_yards,score,drive,message)
