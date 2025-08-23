@tool
extends EditorPlugin

const GOTO_REGION_DIALOG_SCENE = preload("res://addons/goto_region/ui/goto_region_dialog.tscn")
## This contains the path to the editor setting to "show the preview".
const ES_SHOW_PREVIEW := &"text_editor/goto_region/show_preview"
## This contains the path to the editor setting that indicates the anount of preview lines.
const ES_PREVIEW_LINE_COUNT := &"text_editor/goto_region/preview_line_count"
## This contains the path to the editor settings that indiacte the shortcut to open the dialog menu
const ES_OPEN_DIALOG_SHORTCUT := &"text_editor/goto_region/open_dialog_shortcut"

# Goto Region Dialog Command Name
const COMMAND_PALETTE_GRD_COMMAND_NAME := "Go to region"
# Goto Region Dialog Key Name
const COMMAND_PALETTE_GRD_KEY_NAME := "go_to_region/open_menu"

var goto_region_dialog: ConfirmationDialog
var goto_region_shortcut: Shortcut:
	get:
		return EditorInterface.get_editor_settings().get(ES_OPEN_DIALOG_SHORTCUT)


#region Pluin

func _enter_tree() -> void:
	_add_editor_settings()

	goto_region_shortcut = EditorInterface.get_editor_settings().get(ES_OPEN_DIALOG_SHORTCUT)

	var version := get_plugin_version()
	print_rich("[code]Goto region v%s (%s)." %[version, goto_region_shortcut.get_as_text()])

	goto_region_dialog = GOTO_REGION_DIALOG_SCENE.instantiate()
	goto_region_dialog.plugin = self
	goto_region_dialog.hide()
	EditorInterface.get_script_editor().add_child(goto_region_dialog)

	# Add a command to the command palette
	EditorInterface.get_command_palette().add_command(
		COMMAND_PALETTE_GRD_COMMAND_NAME, COMMAND_PALETTE_GRD_KEY_NAME,
		open_goto_region_dialog
		)



func _exit_tree() -> void:
	# Remove the dialog
	if is_instance_valid(goto_region_dialog):
		goto_region_dialog.queue_free()

	# Remove the command from the command palette
	EditorInterface.get_command_palette().remove_command(COMMAND_PALETTE_GRD_KEY_NAME)

#endregion


func open_goto_region_dialog() -> void:
	var script_editor := EditorInterface.get_script_editor()
	var current := script_editor.get_current_editor()
	if current and is_instance_of(current.get_base_editor(), CodeEdit):
		if current.get_base_editor().has_focus():
			goto_region_dialog.popup_centered(goto_region_dialog.size)


func _add_editor_settings() -> void:
	var settings := EditorInterface.get_editor_settings()
	settings.settings_changed.connect(_on_editor_settings_changed)

	settings.add_property_info({
		"name": ES_SHOW_PREVIEW,
		"type": TYPE_BOOL,
	})

	settings.add_property_info({
		"name": ES_PREVIEW_LINE_COUNT,
		"type": TYPE_INT,
		"hint": PROPERTY_HINT_RANGE,
		"hint_string": "0,100,1,or_greater"
	})

	settings.add_property_info({
		"name": ES_OPEN_DIALOG_SHORTCUT,
		"type": TYPE_OBJECT,
		"hint": PROPERTY_HINT_RESOURCE_TYPE,
		"hint_string": "Shortcut"
	})

	if not settings.has_setting(ES_SHOW_PREVIEW):
		settings.set(ES_SHOW_PREVIEW, false)
	settings.set_initial_value(ES_SHOW_PREVIEW, true, false)

	if not settings.has_setting(ES_PREVIEW_LINE_COUNT):
		settings.set(ES_PREVIEW_LINE_COUNT, 8)
	settings.set_initial_value(ES_PREVIEW_LINE_COUNT, 8, false)

	var default_shortcut = _get_default_open_dialog_shortcut()
	if not settings.has_setting(ES_OPEN_DIALOG_SHORTCUT):
		settings.set(ES_OPEN_DIALOG_SHORTCUT, default_shortcut)
	settings.set_initial_value(ES_OPEN_DIALOG_SHORTCUT, default_shortcut, false)



func _shortcut_input(event: InputEvent) -> void:
	if goto_region_shortcut.matches_event(event):
		open_goto_region_dialog()
		get_viewport().set_input_as_handled()


func _get_default_open_dialog_shortcut() -> Shortcut:
	var shortcut := Shortcut.new()
	var default_event := InputEventKey.new()
	default_event.keycode = KEY_G
	default_event.ctrl_pressed = true
	default_event.alt_pressed = true
	shortcut.events = [default_event]
	return shortcut


func _on_editor_settings_changed() -> void:
	var settings := EditorInterface.get_editor_settings()
	var changed := settings.get_changed_settings()

	if changed.has(ES_SHOW_PREVIEW):
		goto_region_dialog.should_show_preview = settings.get(ES_SHOW_PREVIEW)
	elif changed.has(ES_PREVIEW_LINE_COUNT):
		goto_region_dialog.update_preview()
