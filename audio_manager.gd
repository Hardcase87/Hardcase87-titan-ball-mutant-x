extends Node
class_name MutantXAudioManager

var hit_player: AudioStreamPlayer
var dash_player: AudioStreamPlayer
var mutation_player: AudioStreamPlayer
var score_player: AudioStreamPlayer

func _ready() -> void:
    hit_player = _make_player("res://audio/sfx/hit.wav", -4.0)
    dash_player = _make_player("res://audio/sfx/dash.wav", -7.0)
    mutation_player = _make_player("res://audio/sfx/mutation.wav", -5.0)
    score_player = _make_player("res://audio/sfx/score.wav", -4.0)

func _make_player(path: String, volume_db: float) -> AudioStreamPlayer:
    var p = AudioStreamPlayer.new()
    p.volume_db = volume_db
    if ResourceLoader.exists(path):
        p.stream = load(path)
    add_child(p)
    return p

func play_event(kind: String) -> void:
    if kind == "tackle" or kind == "smash":
        _play(hit_player)
    elif kind == "dash":
        _play(dash_player)
    elif kind == "mutation":
        _play(mutation_player)
    elif kind == "touchdown" or kind == "first_down":
        _play(score_player)

func _play(p: AudioStreamPlayer) -> void:
    if p != null and p.stream != null:
        p.stop()
        p.play()
