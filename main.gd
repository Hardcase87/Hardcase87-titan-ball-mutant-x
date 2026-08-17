extends Node3D

@onready var player=$Player
@onready var match_controller=$MatchController
@onready var audio_manager=$AudioManager

var ui:CanvasLayer
var title_screen:Control
var select_screen:Control
var loading_screen:Control
var gameplay_hud:Control
var title_image:TextureRect
var loading_image:TextureRect
var portrait:TextureRect
var score_label:Label
var down_label:Label
var status_label:Label
var callout:Label
var flash:ColorRect
var restart_button:Button
var current_character:="dex"
var loading_timer:=0.0
var callout_timer:=0.0

func _ready()->void:
    _build_ui()
    _wire()
    _show_title()
    player.impact_fx.connect(_on_impact)
    player.character_changed.connect(_refresh_portrait)
    match_controller.hud_changed.connect(_on_hud)
    match_controller.major_event.connect(_major_event)

func _wire()->void:
    $HUDRoot/Touch/Left.button_down.connect(func():player.set_touch_direction(Vector2(-1,0)))
    $HUDRoot/Touch/Left.button_up.connect(func():player.set_touch_direction(Vector2.ZERO))
    $HUDRoot/Touch/Right.button_down.connect(func():player.set_touch_direction(Vector2(1,0)))
    $HUDRoot/Touch/Right.button_up.connect(func():player.set_touch_direction(Vector2.ZERO))
    $HUDRoot/Touch/Up.button_down.connect(func():player.set_touch_direction(Vector2(0,-1)))
    $HUDRoot/Touch/Up.button_up.connect(func():player.set_touch_direction(Vector2.ZERO))
    $HUDRoot/Touch/Down.button_down.connect(func():player.set_touch_direction(Vector2(0,1)))
    $HUDRoot/Touch/Down.button_up.connect(func():player.set_touch_direction(Vector2.ZERO))
    $HUDRoot/Touch/Dash.pressed.connect(player.fire_dash)
    $HUDRoot/Touch/Smash.pressed.connect(player.fire_smash)
    $HUDRoot/Touch/Mutation.pressed.connect(player.fire_mutation)

func _build_ui()->void:
    ui=$HUDRoot

    # gameplay HUD
    gameplay_hud=Control.new()
    gameplay_hud.name="GameplayHUD"
    gameplay_hud.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    gameplay_hud.mouse_filter=Control.MOUSE_FILTER_IGNORE
    ui.add_child(gameplay_hud)
    # Touch controls must render ABOVE the full-screen passive HUD.
    ui.move_child(gameplay_hud,0)

    var top:=ColorRect.new()
    top.color=Color(0.01,0.01,0.018,0.86)
    top.mouse_filter=Control.MOUSE_FILTER_IGNORE
    top.position=Vector2(218,22);top.size=Vector2(1100,122)
    gameplay_hud.add_child(top)

    var title:=Label.new()
    title.text="TITAN BALL: MUTANT X  //  THE PIT"
    title.position=Vector2(28,12);title.size=Vector2(950,34)
    title.add_theme_color_override("font_color",Color(1,0.05,0.55,1))
    title.add_theme_font_size_override("font_size",26)
    top.add_child(title)

    score_label=Label.new()
    score_label.text="TITANS 000   //   MUTANTS 000"
    score_label.position=Vector2(28,49);score_label.size=Vector2(540,34)
    score_label.add_theme_color_override("font_color",Color(0.60,1.0,0.08,1))
    score_label.add_theme_font_size_override("font_size",25)
    top.add_child(score_label)

    down_label=Label.new()
    down_label.text="DOWN 1   //   20 TO GO   //   BALL ON 0"
    down_label.position=Vector2(575,49);down_label.size=Vector2(390,34)
    down_label.horizontal_alignment=HORIZONTAL_ALIGNMENT_RIGHT
    down_label.add_theme_color_override("font_color",Color(0.10,0.82,1.0,1))
    down_label.add_theme_font_size_override("font_size",19)
    top.add_child(down_label)

    var card:=ColorRect.new()
    card.color=Color(0.01,0.012,0.018,0.88)
    card.mouse_filter=Control.MOUSE_FILTER_IGNORE
    card.position=Vector2(320,810);card.size=Vector2(400,180)
    gameplay_hud.add_child(card)

    portrait=TextureRect.new()
    portrait.position=Vector2(12,15);portrait.size=Vector2(118,150)
    portrait.expand_mode=TextureRect.EXPAND_IGNORE_SIZE
    portrait.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED
    card.add_child(portrait)

    status_label=Label.new()
    status_label.position=Vector2(138,18);status_label.size=Vector2(245,150)
    status_label.add_theme_color_override("font_color",Color(0.62,1.0,0.08,1))
    status_label.add_theme_font_size_override("font_size",18)
    card.add_child(status_label)

    callout=Label.new()
    callout.position=Vector2(448,195);callout.size=Vector2(640,110)
    callout.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
    callout.vertical_alignment=VERTICAL_ALIGNMENT_CENTER
    callout.add_theme_color_override("font_color",Color(1,0.05,0.55,1))
    callout.add_theme_font_size_override("font_size",54)
    gameplay_hud.add_child(callout)

    restart_button=Button.new()
    restart_button.text="RESTART GAME"
    restart_button.position=Vector2(1220,165);restart_button.size=Vector2(210,55)
    restart_button.visible=false
    restart_button.pressed.connect(match_controller.restart_game)
    gameplay_hud.add_child(restart_button)

    flash=ColorRect.new()
    flash.color=Color(1,0.05,0.55,0)
    flash.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    flash.mouse_filter=Control.MOUSE_FILTER_IGNORE
    gameplay_hud.add_child(flash)

    # Title screen
    title_screen=_panel_screen("TitleScreen")
    title_image=TextureRect.new()
    title_image.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    title_image.expand_mode=TextureRect.EXPAND_IGNORE_SIZE
    title_image.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_COVERED
    title_image.mouse_filter=Control.MOUSE_FILTER_IGNORE
    title_screen.add_child(title_image)

    # The artwork already contains the full title treatment.
    # Tap anywhere to enter character select.
    var start:=Button.new()
    start.text=""
    start.flat=true
    start.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    start.pressed.connect(_show_select)
    title_screen.add_child(start)

    # Select screen
    select_screen=_panel_screen("SelectScreen")
    var select_bg:=TextureRect.new()
    select_bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    select_bg.expand_mode=TextureRect.EXPAND_IGNORE_SIZE
    select_bg.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_COVERED
    select_bg.mouse_filter=Control.MOUSE_FILTER_IGNORE
    select_bg.modulate=Color(0.42,0.42,0.42,1)
    if ResourceLoader.exists("res://pit_backdrop.png"):
        select_bg.texture=load("res://pit_backdrop.png")
    select_screen.add_child(select_bg)

    var sel_title:=Label.new()
    sel_title.text="CHOOSE YOUR MUTANT"
    sel_title.position=Vector2(438,82);sel_title.size=Vector2(660,80)
    sel_title.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
    sel_title.add_theme_color_override("font_color",Color(1,0.05,0.55,1))
    sel_title.add_theme_font_size_override("font_size",46)
    select_screen.add_child(sel_title)

    _character_card("dex",Vector2(180,205))
    _character_card("nikki",Vector2(598,205))
    _character_card("mack",Vector2(1016,205))

    # Loading screen
    loading_screen=_panel_screen("LoadingScreen")
    loading_image=TextureRect.new()
    loading_image.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    loading_image.expand_mode=TextureRect.EXPAND_IGNORE_SIZE
    loading_image.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_COVERED
    loading_image.mouse_filter=Control.MOUSE_FILTER_IGNORE
    loading_screen.add_child(loading_image)

    _load_optional_images()

func _panel_screen(name:String)->Control:
    var c:=Control.new()
    c.name=name
    c.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    var bg:=ColorRect.new()
    bg.color=Color(0.004,0.003,0.009,0.965)
    bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    c.add_child(bg)
    ui.add_child(c)
    return c

func _character_card(id:String,pos:Vector2)->void:
    var c:=MutantXCharacterDB.get_character(id)
    var panel:=ColorRect.new()
    panel.color=Color(0.02,0.02,0.035,0.96)
    panel.position=pos;panel.size=Vector2(340,560)
    select_screen.add_child(panel)

    var tex:=TextureRect.new()
    tex.position=Vector2(20,18);tex.size=Vector2(300,330)
    tex.expand_mode=TextureRect.EXPAND_IGNORE_SIZE
    tex.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED
    var path:String=c["portrait"]
    if ResourceLoader.exists(path):tex.texture=load(path)
    panel.add_child(tex)

    var l:=Label.new()
    l.text="%s  #%s\n%s\nSPEED  %d\nPOWER  %d\nHP  %d\n%s" % [
        c["name"],c["number"],c["role"],
        int(c["speed"]*10),int(c["power"]*70),c["hp"],c["special"]
    ]
    l.position=Vector2(20,355);l.size=Vector2(300,125)
    l.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
    l.add_theme_color_override("font_color",c["primary"])
    l.add_theme_font_size_override("font_size",18)
    panel.add_child(l)

    var b:=Button.new()
    b.text="SELECT"
    b.position=Vector2(80,500);b.size=Vector2(180,46)
    b.pressed.connect(func():_choose_character(id))
    panel.add_child(b)

func _load_optional_images()->void:
    var title_path:="res://mutantx_title.png"
    if ResourceLoader.exists(title_path):
        title_image.texture=load(title_path)

    var load_path:="res://team_loading.png"
    if not ResourceLoader.exists(load_path):
        load_path="res://pit_loading.png"
    if ResourceLoader.exists(load_path):
        loading_image.texture=load(load_path)

func _refresh_portrait(_id:String)->void:
    var c:=MutantXCharacterDB.get_character(current_character)
    var path:String=c["portrait"]
    portrait.texture=load(path) if ResourceLoader.exists(path) else null

func _show_title()->void:
    title_screen.visible=true
    select_screen.visible=false
    loading_screen.visible=false
    gameplay_hud.visible=false
    $HUDRoot/Touch.visible=false
    match_controller.set_active(false)

func _show_select()->void:
    title_screen.visible=false
    select_screen.visible=true
    loading_screen.visible=false
    gameplay_hud.visible=false
    $HUDRoot/Touch.visible=false
    match_controller.set_active(false)

func _choose_character(id:String)->void:
    current_character=id
    player.apply_character(id)
    _refresh_portrait(id)
    title_screen.visible=false
    select_screen.visible=false
    loading_screen.visible=true
    gameplay_hud.visible=false
    $HUDRoot/Touch.visible=false
    loading_timer=1.35
    match_controller.set_active(false)

func _start_game()->void:
    loading_screen.visible=false
    gameplay_hud.visible=true
    $HUDRoot/Touch.visible=true
    match_controller.restart_game()
    match_controller.set_active(true)

func _process(delta:float)->void:
    if loading_timer>0.0:
        loading_timer-=delta
        if loading_timer<=0.0:_start_game()

    if gameplay_hud.visible:
        status_label.text="%s  #%s\n%s\nHP  %d/%d\nMUTATION  %d%%\n%s" % [
            player.display_name,player.display_number,player.display_role,
            player.hp,player.max_hp,int(player.mutation_meter),player.special_name
        ]

    if callout_timer>0.0:
        callout_timer-=delta
        callout.modulate.a=clamp(callout_timer/0.6,0.0,1.0) if callout_timer<0.6 else 1.0
    else:
        callout.text=""

    if flash.color.a>0.0:
        var c:=flash.color
        c.a=max(0.0,c.a-delta*2.8)
        flash.color=c

func _on_hud(down:int,yards:int,field:int,score:int,drive:int,msg:String)->void:
    score_label.text="TITANS %03d   //   MUTANTS %03d   //   DRIVE %d" % [score,0,drive]
    down_label.text="DOWN %d   //   %d TO GO   //   BALL ON %d" % [down,yards,field]
    restart_button.visible=msg.contains("GAME OVER")

func _major_event(text:String)->void:
    callout.text=text
    callout_timer=1.9
    if text=="TOUCHDOWN":
        audio_manager.play_event("touchdown")
    elif text=="FIRST DOWN":
        audio_manager.play_event("first_down")

func _on_impact(kind:String,strength:float)->void:
    audio_manager.play_event(kind)
    var c:=Color(1,0.05,0.55,0.16*strength)
    if kind=="mutation":c=Color(0.55,1.0,0.06,0.22)
    if kind=="tackle":c=Color(1,0.15,0.05,0.20)
    flash.color=c
