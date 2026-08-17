extends Node
class_name MutantXCharacterDB

const CHARACTERS := {
    "dex": {
        "name":"DEX VOLT",
        "number":"7",
        "role":"BALANCED",
        "speed":8.4,
        "dash":15.5,
        "power":1.00,
        "hp":100,
        "primary":Color(0.62,1.0,0.05,1),
        "secondary":Color(1.0,0.04,0.56,1),
        "visor":Color(0.04,0.9,1.0,1),
        "special":"VOLT STORM",
        "portrait":"res://art/characters/dex/dex_portrait.png",
        "model":"res://art/characters/dex/model/dex.glb"
    },
    "nikki": {
        "name":"NIKKI NITRO",
        "number":"94",
        "role":"SPEED // DODGE",
        "speed":9.8,
        "dash":18.2,
        "power":0.88,
        "hp":92,
        "primary":Color(1.0,0.03,0.56,1),
        "secondary":Color(0.60,0.07,0.90,1),
        "visor":Color(0.05,0.95,1.0,1),
        "special":"NITRO BREAK",
        "portrait":"res://art/characters/nikki/nikki_portrait.png",
        "model":"res://art/characters/nikki/model/nikki.glb"
    },
    "mack": {
        "name":"MACK MAUL",
        "number":"99",
        "role":"POWER // TANK",
        "speed":6.8,
        "dash":12.7,
        "power":1.48,
        "hp":140,
        "primary":Color(0.55,1.0,0.04,1),
        "secondary":Color(0.75,0.03,0.45,1),
        "visor":Color(1.0,0.12,0.55,1),
        "special":"EARTHQUAKE",
        "portrait":"res://art/characters/mack/mack_portrait.png",
        "model":"res://art/characters/mack/model/mack.glb"
    }
}

static func get_character(id:String) -> Dictionary:
    return CHARACTERS.get(id, CHARACTERS["dex"])
