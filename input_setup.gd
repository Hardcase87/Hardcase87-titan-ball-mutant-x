extends Node
class_name MutantXInputSetup

static func ensure_actions() -> void:
    _axis_action("move_left", KEY_A, JOY_AXIS_LEFT_X, -1.0)
    _axis_action("move_right", KEY_D, JOY_AXIS_LEFT_X, 1.0)
    _axis_action("move_forward", KEY_W, JOY_AXIS_LEFT_Y, -1.0)
    _axis_action("move_back", KEY_S, JOY_AXIS_LEFT_Y, 1.0)
    _button_action("dash", KEY_SPACE, JOY_BUTTON_A)
    _button_action("smash", KEY_X, JOY_BUTTON_X)
    _button_action("mutation", KEY_V, JOY_BUTTON_Y)

static func _axis_action(action:StringName, keycode:Key, axis:JoyAxis, value:float) -> void:
    if not InputMap.has_action(action):
        InputMap.add_action(action)
    if InputMap.action_get_events(action).is_empty():
        var k := InputEventKey.new()
        k.physical_keycode = keycode
        InputMap.action_add_event(action, k)
        var j := InputEventJoypadMotion.new()
        j.axis = axis
        j.axis_value = value
        InputMap.action_add_event(action, j)

static func _button_action(action:StringName, keycode:Key, button:JoyButton) -> void:
    if not InputMap.has_action(action):
        InputMap.add_action(action)
    if InputMap.action_get_events(action).is_empty():
        var k := InputEventKey.new()
        k.physical_keycode = keycode
        InputMap.action_add_event(action, k)
        var j := InputEventJoypadButton.new()
        j.button_index = button
        InputMap.action_add_event(action, j)
