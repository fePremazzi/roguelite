@tool
extends EditorPlugin

var scale_button: Button
var timer: Timer

func _enter_tree() -> void:
	scale_button = Button.new()
	scale_button.text = "Distribute Keyframes"
	scale_button.tooltip_text = "Scale animation keyframes to a specific duration"
	scale_button.connect("pressed", Callable(self, "_on_scale_button_pressed"))
	
	timer = Timer.new()
	add_child(timer)
	timer.wait_time = 1.0
	timer.one_shot = false
	timer.connect("timeout", Callable(self, "_try_add_button"))
	timer.start()

func _exit_tree() -> void:
	if scale_button and is_instance_valid(scale_button) and scale_button.get_parent():
		scale_button.get_parent().remove_child(scale_button)
	scale_button.queue_free()
	
	if timer and is_instance_valid(timer):
		timer.stop()
		timer.queue_free()
	

func _try_add_button() -> void:
	if scale_button.get_parent():
		return
	
	var found_panel = false
	var base_control = get_editor_interface().get_base_control()
	
	var animation_panels = _find_animation_panels(base_control)
	for panel in animation_panels:
		var toolbar = _find_toolbar(panel)
		if toolbar:
			toolbar.add_child(scale_button)
			found_panel = true
			timer.stop()
			break
	
	if not found_panel:
		var editor_overlay = get_editor_interface().get_base_control().get_viewport()
		if editor_overlay:
			var panel = Panel.new()
			panel.position = Vector2(100, 100)
			panel.custom_minimum_size = Vector2(120, 40)
			
			var h_box = HBoxContainer.new()
			h_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			h_box.size_flags_vertical = Control.SIZE_EXPAND_FILL
			panel.add_child(h_box)
			
			h_box.add_child(scale_button)
			editor_overlay.add_child(panel)
			timer.stop()

func _find_animation_panels(node: Node) -> Array:
	var result = []
	
	var node_class = node.get_class()
	var node_name = ""
	if node.has_method("get_name"):
		node_name = node.get_name()
	
	if "Animation" in node_class or "animation" in node_class.to_lower() or "Animation" in node_name or "animation" in node_name.to_lower():
		result.append(node)
	
	for child in node.get_children():
		var child_results = _find_animation_panels(child)
		for item in child_results:
			result.append(item)
	
	return result

func _find_toolbar(node: Node) -> Node:
	if node is HBoxContainer:
		for child in node.get_children():
			if child is Button:
				return node
	
	for child in node.get_children():
		var toolbar = _find_toolbar(child)
		if toolbar:
			return toolbar
	
	return null

func _on_scale_button_pressed() -> void:
	var animation = _get_current_animation()
	if not animation:
		_show_error_dialog("No animation is currently open in the editor")
		return
	
	var dialog = _create_scale_dialog(animation)

	dialog.popup_centered(Vector2(400, 400))

func _get_current_animation() -> Animation:
	var editor = get_editor_interface()
	if editor.has_method("get_edited_scene_root"):
		var scene = editor.get_edited_scene_root()
		if scene:

			var animation_players = _find_animation_players(scene)
			for player in animation_players:
				if player.is_playing() or not player.assigned_animation.is_empty():
					return player.get_animation(player.assigned_animation)

	var selection = get_editor_interface().get_selection()
	if selection:
		var selected_nodes = selection.get_selected_nodes()
		for node in selected_nodes:
			if node is AnimationPlayer and not node.assigned_animation.is_empty():
				return node.get_animation(node.assigned_animation)
	
	var scene = get_editor_interface().get_edited_scene_root()
	if scene:
		var animation_players = _find_animation_players(scene)
		if animation_players.size() > 0:
			var player = animation_players[0]
			if not player.assigned_animation.is_empty():
				return player.get_animation(player.assigned_animation)
	
	return _find_open_animation_in_editor()

func _find_animation_players(node: Node) -> Array:
	var result = []
	
	if node is AnimationPlayer:
		result.append(node)
	
	for child in node.get_children():
		var child_results = _find_animation_players(child)
		for player in child_results:
			result.append(player)
	
	return result

func _find_open_animation_in_editor() -> Animation:
	var base_control = get_editor_interface().get_base_control()
	var all_controls = _get_all_controls(base_control)
	
	for control in all_controls:
		for property in control.get_property_list():
			var property_name = property.name
			if property_name == "animation" or property_name == "current_animation":
				var potential_animation = control.get(property_name)
				if potential_animation is Animation:
					return potential_animation
	
	var scene = get_editor_interface().get_edited_scene_root()
	if scene:
		var animation_players = _find_animation_players(scene)
		for player in animation_players:
			if player.is_playing():
				return player.get_animation(player.assigned_animation)
	
	return null

func _get_all_controls(node: Node) -> Array:
	var result = []
	
	if node is Control:
		result.append(node)
	
	for child in node.get_children():
		var child_controls = _get_all_controls(child)
		for control in child_controls:
			result.append(control)
	
	return result

func _create_scale_dialog(animation: Animation) -> ConfirmationDialog:
	var dialog = ConfirmationDialog.new()
	dialog.title = "Distribute Animation Keyframes"
	
	var vbox = VBoxContainer.new()
	dialog.add_child(vbox)
	
	var current_length_label = Label.new()
	current_length_label.text = "Current animation length: " + str(animation.length) + " seconds"
	vbox.add_child(current_length_label)
	
	var hbox = HBoxContainer.new()
	vbox.add_child(hbox)
	
	var target_label = Label.new()
	target_label.text = "Target length (seconds): "
	hbox.add_child(target_label)
	
	var target_input = SpinBox.new()
	target_input.min_value = 0.1
	target_input.max_value = 600.0
	target_input.step = 0.1
	target_input.value = animation.length
	hbox.add_child(target_input)
	
	var tracks_label = Label.new()
	tracks_label.text = "Select tracks to distribute:"
	vbox.add_child(tracks_label)
	
	var selection_buttons_hbox = HBoxContainer.new()
	vbox.add_child(selection_buttons_hbox)
	
	var select_all_button = Button.new()
	select_all_button.text = "Select All"
	selection_buttons_hbox.add_child(select_all_button)
	
	var deselect_all_button = Button.new()
	deselect_all_button.text = "Deselect All"
	selection_buttons_hbox.add_child(deselect_all_button)
	
	var scroll = ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.custom_minimum_size = Vector2(0, 200)
	vbox.add_child(scroll)
	
	var track_list = VBoxContainer.new()
	scroll.add_child(track_list)
	track_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	var track_checkboxes = []
	for i in range(animation.get_track_count()):
		var checkbox = CheckBox.new()
		var track_path = animation.track_get_path(i)
		checkbox.text = str(track_path)
		checkbox.name = "track_" + str(i)
		
		checkbox.button_pressed = true
		track_list.add_child(checkbox)
		track_checkboxes.append(checkbox)
	
	var adjust_duration_checkbox = CheckBox.new()
	adjust_duration_checkbox.text = "Adjust animation duration"
	adjust_duration_checkbox.button_pressed = false
	vbox.add_child(adjust_duration_checkbox)
	
	select_all_button.connect("pressed", Callable(self, "_select_all_tracks").bind(track_checkboxes))
	deselect_all_button.connect("pressed", Callable(self, "_deselect_all_tracks").bind(track_checkboxes))
	
	get_editor_interface().get_base_control().add_child(dialog)
	
	dialog.connect("confirmed", Callable(self, "_distribute_keyframes").bind(
		animation, 
		target_input, 
		track_checkboxes,
		adjust_duration_checkbox
	))
	
	return dialog

func _select_all_tracks(track_checkboxes: Array) -> void:
	for checkbox in track_checkboxes:
		checkbox.button_pressed = true

func _deselect_all_tracks(track_checkboxes: Array) -> void:
	for checkbox in track_checkboxes:
		checkbox.button_pressed = false

func _distribute_keyframes(animation: Animation, target_input: SpinBox, 
	track_checkboxes: Array, adjust_duration_checkbox: CheckBox) -> void:
	
	var target_length = target_input.value
	var original_length = animation.length
	
	if is_zero_approx(target_length):
		_show_error_dialog("Invalid duration")
		return
	
	for i in range(track_checkboxes.size()):
		var checkbox = track_checkboxes[i]
		if checkbox.button_pressed:
			var track_idx = i
			var track_path = animation.track_get_path(track_idx)
			
			var key_count = animation.track_get_key_count(track_idx)
			
			if key_count <= 1:
				continue
			
			var key_data = []
			for key_idx in range(key_count):
				key_data.append({
					"time": animation.track_get_key_time(track_idx, key_idx),
					"value": animation.track_get_key_value(track_idx, key_idx),
					"transition": animation.track_get_key_transition(track_idx, key_idx)
				})
			
			key_data.sort_custom(Callable(self, "_sort_keys_by_time"))
			
			while animation.track_get_key_count(track_idx) > 0:
				animation.track_remove_key(track_idx, 0)
			
			var interval = target_length / (key_count - 1) if key_count > 1 else 0
			
			for j in range(key_count):
				var new_time = 0.0 if key_count == 1 else j * interval
				animation.track_insert_key(
					track_idx, 
					new_time,
					key_data[j]["value"],
					key_data[j]["transition"]
				)
	
	if adjust_duration_checkbox.button_pressed:
		animation.length = target_length

	var success_message = "Keyframes evenly distributed"
	if adjust_duration_checkbox.button_pressed:
		success_message += " and duration set to " + str(target_length) + " seconds"
	
	_show_success_dialog(success_message)

func _scale_animation(animation: Animation, target_input: SpinBox) -> void:
	var target_length = target_input.value
	var original_length = animation.length
	
	if is_zero_approx(original_length) or is_zero_approx(target_length):
		_show_error_dialog("Invalid animation length")
		return

	for track_idx in range(animation.get_track_count()):
		var key_count = animation.track_get_key_count(track_idx)
		
		if key_count <= 1:
			continue
		
		var key_data = []
		for key_idx in range(key_count):
			key_data.append({
				"time": animation.track_get_key_time(track_idx, key_idx),
				"value": animation.track_get_key_value(track_idx, key_idx),
				"transition": animation.track_get_key_transition(track_idx, key_idx)
			})
		
		key_data.sort_custom(Callable(self, "_sort_keys_by_time"))
		
		while animation.track_get_key_count(track_idx) > 0:
			animation.track_remove_key(track_idx, 0)
		
		var interval = target_length / (key_count - 1) if key_count > 1 else 0
		
		for i in range(key_count):
			var new_time = 0.0 if key_count == 1 else i * interval
			animation.track_insert_key(
				track_idx, 
				new_time,
				key_data[i]["value"],
				key_data[i]["transition"]
			)
	
	animation.length = target_length
	
	_show_success_dialog("Keyframes evenly distributed over " + str(target_length) + " seconds")

func _sort_keys_by_time(a, b):
	return a["time"] < b["time"]

func _show_error_dialog(message: String) -> void:
	var dialog = AcceptDialog.new()
	dialog.dialog_text = message
	dialog.title = "Error"
	dialog.popup_centered()
	get_editor_interface().get_base_control().add_child(dialog)
	dialog.connect("confirmed", Callable(dialog, "queue_free"))

func _show_success_dialog(message: String) -> void:
	var dialog = AcceptDialog.new()
	dialog.dialog_text = message
	dialog.title = "Success"
	dialog.popup_centered()
	get_editor_interface().get_base_control().add_child(dialog)
	dialog.connect("confirmed", Callable(dialog, "queue_free"))