extends Control

signal combat_finished(result: Dictionary)

const PANEL_BG := Color("#0d3028")
const INNER_BG := Color("#081d18")
const GOLD := Color("#d8ae58")
const GOLD_LIGHT := Color("#f1d184")
const TEXT := Color("#e7eadc")
const MUTED := Color("#9cb4a5")
const GREEN := Color("#83c58d")
const RED := Color("#df8777")
const BLUE := Color("#77bde0")
const ENEMY_TURN_DELAY := 0.75

var player: Dictionary = {}
var enemy: Dictionary = {}
var pills: Array[Dictionary] = []
var consumed_pills: Dictionary = {}
var turn_state := "idle"
var combat_over := false
var combat_result := ""
var log_lines: Array[String] = []

var player_name_label: Label
var player_realm_label: Label
var player_hp_bar: ProgressBar
var player_mp_bar: ProgressBar
var player_hp_label: Label
var player_mp_label: Label
var enemy_name_label: Label
var enemy_realm_label: Label
var enemy_hp_bar: ProgressBar
var enemy_mp_bar: ProgressBar
var enemy_hp_label: Label
var enemy_mp_label: Label
var turn_label: Label
var combat_log: RichTextLabel
var combat_panel: PanelContainer
var combat_margin: MarginContainer
var combat_layout: VBoxContainer
var player_avatar: TextureRect
var skill_button: Button
var pill_button: Button
var pill_picker: OptionButton
var retreat_button: Button
var finish_button: Button
var player_action_buttons: Array[Button] = []

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_build_interface()
	resized.connect(_update_layout)
	_update_layout()

func _update_layout() -> void:
	if not is_instance_valid(combat_panel):
		return
	var compact := size.x < 760.0 or size.y < 700.0
	combat_panel.custom_minimum_size = Vector2(maxf(280.0, size.x - 24.0), maxf(320.0, size.y - 24.0)) if compact else Vector2(560.0, 620.0)
	if is_instance_valid(combat_margin):
		var margin_size := 8 if compact else 16
		for side in ["left", "top", "right", "bottom"]:
			combat_margin.add_theme_constant_override("margin_" + side, margin_size)
	if is_instance_valid(combat_layout):
		combat_layout.add_theme_constant_override("separation", 5 if compact else 10)
	if is_instance_valid(player_avatar):
		player_avatar.custom_minimum_size = Vector2(36, 36) if compact else Vector2(56, 56)
	if is_instance_valid(combat_log):
		combat_log.custom_minimum_size.y = maxf(52.0, size.y * 0.12) if compact else 130.0
	for action_button in player_action_buttons:
		action_button.custom_minimum_size.y = 52 if compact else 46
	if is_instance_valid(pill_button):
		pill_button.custom_minimum_size.y = 52 if compact else 46

func start_combat(player_data: Dictionary, enemy_data: Dictionary, available_pills: Array = []) -> void:
	player = player_data.duplicate(true)
	enemy = enemy_data.duplicate(true)
	pills.clear()
	for pill in available_pills:
		if pill is Dictionary and int(pill.get("count", 0)) > 0:
			pills.append(pill.duplicate(true))
	consumed_pills.clear()
	combat_over = false
	combat_result = ""
	turn_state = "player"
	var player_power := maxf(0.0, float(player.get("power", 0.0)))
	var enemy_power := maxf(0.0, float(enemy.get("power", 0.0)))
	player["max_hp"] = maxf(180.0, float(player.get("max_hp", 180.0 + player_power * 0.18)))
	player["max_mp"] = maxf(60.0, float(player.get("max_mp", 60.0 + float(player.get("realm_index", 0)) * 4.0)))
	player["attack"] = maxf(12.0, float(player.get("attack", 16.0 + player_power * 0.035)))
	player["hp"] = player["max_hp"]
	player["mp"] = player["max_mp"]
	enemy["max_hp"] = maxf(140.0, float(enemy.get("max_hp", 140.0 + enemy_power * 0.16)))
	enemy["max_mp"] = maxf(45.0, float(enemy.get("max_mp", 45.0 + float(enemy.get("realm_index", 0)) * 3.0)))
	enemy["attack"] = maxf(10.0, float(enemy.get("attack", 12.0 + enemy_power * 0.03)))
	enemy["hp"] = enemy["max_hp"]
	enemy["mp"] = enemy["max_mp"]
	log_lines.clear()
	_add_log("Trận đấu bắt đầu. Hai bên chắp tay hành lễ.")
	_refresh_interface()

func _build_interface() -> void:
	var dimmer := ColorRect.new()
	dimmer.color = Color(0.015, 0.035, 0.03, 0.88)
	dimmer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dimmer.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(dimmer)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	center.offset_left = 12
	center.offset_top = 12
	center.offset_right = -12
	center.offset_bottom = -12
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(center)

	var panel := PanelContainer.new()
	combat_panel = panel
	panel.custom_minimum_size = Vector2(560, 620)
	panel.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	panel.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	panel.add_theme_stylebox_override("panel", _style(PANEL_BG, GOLD, 2, 8))
	center.add_child(panel)
	var margin := MarginContainer.new()
	combat_margin = margin
	for side in ["left", "top", "right", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 16)
	panel.add_child(margin)
	var layout := VBoxContainer.new()
	combat_layout = layout
	layout.add_theme_constant_override("separation", 10)
	margin.add_child(layout)

	var heading := HBoxContainer.new()
	var title := _label("ĐẠO ĐÀI TỈ THÍ", 20, GOLD_LIGHT)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	heading.add_child(title)
	turn_label = _label("LƯỢT CỦA BẠN", 12, GREEN)
	heading.add_child(turn_label)
	layout.add_child(heading)
	layout.add_child(_separator())

	var fighters := HBoxContainer.new()
	fighters.add_theme_constant_override("separation", 10)
	fighters.add_child(_build_fighter_card(true))
	var versus := _label("VS", 14, GOLD)
	versus.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	fighters.add_child(versus)
	fighters.add_child(_build_fighter_card(false))
	layout.add_child(fighters)

	var log_title := _label("NHẬT KÝ CHIẾN ĐẤU", 11, GOLD)
	layout.add_child(log_title)
	combat_log = RichTextLabel.new()
	combat_log.bbcode_enabled = true
	combat_log.fit_content = false
	combat_log.scroll_active = true
	combat_log.size_flags_vertical = Control.SIZE_EXPAND_FILL
	combat_log.custom_minimum_size.y = 130
	combat_log.add_theme_stylebox_override("normal", _style(INNER_BG, Color("#244136"), 1, 5))
	layout.add_child(combat_log)

	var pill_row := HBoxContainer.new()
	pill_row.add_theme_constant_override("separation", 8)
	pill_picker = OptionButton.new()
	pill_picker.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	pill_picker.custom_minimum_size.y = 42
	pill_row.add_child(pill_picker)
	pill_button = _button("DÙNG ĐAN", BLUE)
	pill_button.pressed.connect(_use_pill)
	pill_row.add_child(pill_button)
	layout.add_child(pill_row)

	var actions := GridContainer.new()
	actions.columns = 2
	actions.add_theme_constant_override("h_separation", 8)
	actions.add_theme_constant_override("v_separation", 8)
	var attack_button := _button("TẤN CÔNG THƯỜNG", GOLD)
	attack_button.pressed.connect(_player_attack)
	player_action_buttons.append(attack_button)
	actions.add_child(attack_button)
	skill_button = _button("VẬN DỤNG PHÁP BẢO", BLUE)
	skill_button.pressed.connect(_player_skill)
	player_action_buttons.append(skill_button)
	actions.add_child(skill_button)
	retreat_button = _button("BỎ CHẠY", MUTED)
	retreat_button.pressed.connect(_retreat)
	player_action_buttons.append(retreat_button)
	actions.add_child(retreat_button)
	finish_button = _button("ĐÓNG KẾT QUẢ", GOLD_LIGHT)
	finish_button.pressed.connect(_emit_result_and_close)
	finish_button.visible = false
	actions.add_child(finish_button)
	layout.add_child(actions)

func _build_fighter_card(is_player: bool) -> Control:
	var panel := PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.add_theme_stylebox_override("panel", _style(INNER_BG, Color("#315343"), 1, 6))
	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 5)
	panel.add_child(content)
	if is_player:
		player_avatar = TextureRect.new()
		player_avatar.custom_minimum_size = Vector2(56, 56)
		player_avatar.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		player_avatar.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		player_avatar.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		if ResourceLoader.exists("res://assets/player_avatar.png"):
			player_avatar.texture = load("res://assets/player_avatar.png")
		content.add_child(player_avatar)
		player_name_label = _label("Đạo hữu", 13, GOLD_LIGHT)
		player_realm_label = _label("Cảnh giới", 10, MUTED)
		player_hp_bar = _bar(RED)
		player_hp_label = _label("HP", 10, TEXT)
		player_mp_bar = _bar(BLUE)
		player_mp_label = _label("MP", 10, TEXT)
		for child in [player_name_label, player_realm_label, player_hp_label, player_hp_bar, player_mp_label, player_mp_bar]:
			content.add_child(child)
	else:
		var avatar_mark := _label("☯", 34, RED)
		avatar_mark.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		content.add_child(avatar_mark)
		enemy_name_label = _label("Đối thủ", 13, GOLD_LIGHT)
		enemy_realm_label = _label("Cảnh giới", 10, MUTED)
		enemy_hp_bar = _bar(RED)
		enemy_hp_label = _label("HP", 10, TEXT)
		enemy_mp_bar = _bar(BLUE)
		enemy_mp_label = _label("MP", 10, TEXT)
		for child in [enemy_name_label, enemy_realm_label, enemy_hp_label, enemy_hp_bar, enemy_mp_label, enemy_mp_bar]:
			content.add_child(child)
	return panel

func _bar(fill_color: Color) -> ProgressBar:
	var bar := ProgressBar.new()
	bar.custom_minimum_size.y = 10
	bar.show_percentage = false
	bar.add_theme_stylebox_override("background", _style(Color("#14251e"), Color("#14251e"), 0, 4))
	bar.add_theme_stylebox_override("fill", _style(fill_color, fill_color, 0, 4))
	return bar

func _player_attack() -> void:
	if not _is_player_turn():
		return
	var damage := _damage_roll(float(player["attack"]) * 1.0, 0.14)
	_apply_damage_to_enemy(damage, "Đạo hữu tung quyền", "đòn thường")
	_finish_player_action()

func _player_skill() -> void:
	if not _is_player_turn():
		return
	const skill_cost := 22.0
	if float(player["mp"]) < skill_cost:
		_add_log("Chân Nguyên không đủ để vận dụng pháp bảo.")
		return
	player["mp"] = float(player["mp"]) - skill_cost
	var damage := _damage_roll(float(player["attack"]) * 2.15, 0.12)
	_apply_damage_to_enemy(damage, "Pháp bảo bộc phát linh quang", "pháp bảo")
	_finish_player_action()

func _use_pill() -> void:
	if not _is_player_turn():
		return
	if pills.is_empty() or pill_picker.item_count == 0:
		_add_log("Túi đan dược không còn linh đan có thể dùng.")
		return
	var pill_index := pill_picker.get_selected_id()
	if pill_index < 0 or pill_index >= pills.size():
		return
	var pill: Dictionary = pills[pill_index]
	var pill_id := str(pill.get("id", ""))
	if int(pill.get("count", 0)) <= 0:
		return
	pill["count"] = int(pill["count"]) - 1
	consumed_pills[pill_id] = int(consumed_pills.get(pill_id, 0)) + 1
	var hp_restored := minf(float(player["max_hp"]) * 0.35, float(player["max_hp"]) - float(player["hp"]))
	var mp_restored := minf(float(player["max_mp"]) * 0.25, float(player["max_mp"]) - float(player["mp"]))
	if hp_restored <= 0.0 and mp_restored <= 0.0:
		_add_log("Khí huyết và Chân Nguyên đang sung mãn, không cần dùng đan.")
		pill["count"] = int(pill["count"]) + 1
		consumed_pills[pill_id] = int(consumed_pills[pill_id]) - 1
		if int(consumed_pills[pill_id]) <= 0:
			consumed_pills.erase(pill_id)
		return
	player["hp"] = float(player["hp"]) + hp_restored
	player["mp"] = float(player["mp"]) + mp_restored
	_add_log("Dùng %s, hồi %.0f HP và %.0f MP." % [str(pill.get("name", "Linh đan")), hp_restored, mp_restored])
	_refresh_interface()
	_finish_player_action()

func _retreat() -> void:
	if not _is_player_turn():
		return
	combat_over = true
	turn_state = "finished"
	_add_log("Đạo hữu chủ động rút lui khỏi đạo đài.")
	_show_result_controls("retreat")

func _apply_damage_to_enemy(damage: float, source: String, attack_name: String) -> void:
	enemy["hp"] = maxf(0.0, float(enemy["hp"]) - damage)
	_add_log("%s dùng %s, gây %.0f sát thương." % [source, attack_name, damage])
	_refresh_interface()
	if float(enemy["hp"]) <= 0.0:
		combat_over = true
		turn_state = "finished"
		_add_log("Đối thủ đã mất sức chiến đấu. Đạo hữu chiến thắng!")
		_show_result_controls("victory")

func _finish_player_action() -> void:
	if combat_over:
		return
	turn_state = "enemy"
	_refresh_interface()
	_enemy_turn()

func _enemy_turn() -> void:
	await get_tree().create_timer(ENEMY_TURN_DELAY).timeout
	if not is_inside_tree() or combat_over:
		return
	var use_skill := float(enemy["mp"]) >= 15.0 and randf() < 0.35
	var damage_multiplier := 1.65 if use_skill else 1.0
	var damage := _damage_roll(float(enemy["attack"]) * damage_multiplier, 0.18)
	if use_skill:
		enemy["mp"] = float(enemy["mp"]) - 15.0
		_add_log("%s thi triển linh thuật, hao 15 MP." % str(enemy.get("name", "Đối thủ")))
	player["hp"] = maxf(0.0, float(player["hp"]) - damage)
	player["mp"] = minf(float(player["max_mp"]), float(player["mp"]) + 4.0)
	_add_log("%s phản công, gây %.0f sát thương." % [str(enemy.get("name", "Đối thủ")), damage])
	if float(player["hp"]) <= 0.0:
		combat_over = true
		turn_state = "finished"
		_add_log("Đạo hữu kiệt sức. Trận đấu kết thúc.")
		_show_result_controls("defeat")
		return
	turn_state = "player"
	_refresh_interface()

func _damage_roll(base_damage: float, variance: float) -> float:
	return maxf(1.0, base_damage * randf_range(1.0 - variance, 1.0 + variance))

func _is_player_turn() -> bool:
	return not combat_over and turn_state == "player"

func _refresh_interface() -> void:
	if not is_instance_valid(player_name_label):
		return
	player_name_label.text = str(player.get("name", "Đạo hữu"))
	player_realm_label.text = str(player.get("realm", "Phàm Nhân"))
	enemy_name_label.text = str(enemy.get("name", "Đối thủ"))
	enemy_realm_label.text = str(enemy.get("realm", "Vô Danh"))
	player_hp_bar.max_value = float(player["max_hp"])
	player_hp_bar.value = float(player["hp"])
	player_mp_bar.max_value = float(player["max_mp"])
	player_mp_bar.value = float(player["mp"])
	enemy_hp_bar.max_value = float(enemy["max_hp"])
	enemy_hp_bar.value = float(enemy["hp"])
	enemy_mp_bar.max_value = float(enemy["max_mp"])
	enemy_mp_bar.value = float(enemy["mp"])
	player_hp_label.text = "HP  %.0f / %.0f" % [float(player["hp"]), float(player["max_hp"])]
	player_mp_label.text = "MP  %.0f / %.0f" % [float(player["mp"]), float(player["max_mp"])]
	enemy_hp_label.text = "HP  %.0f / %.0f" % [float(enemy["hp"]), float(enemy["max_hp"])]
	enemy_mp_label.text = "MP  %.0f / %.0f" % [float(enemy["mp"]), float(enemy["max_mp"])]
	turn_label.text = "LƯỢT CỦA BẠN" if turn_state == "player" else "ĐỐI THỦ ĐANG RA CHIÊU"
	turn_label.add_theme_color_override("font_color", GREEN if turn_state == "player" else RED)
	skill_button.disabled = not _is_player_turn() or float(player["mp"]) < 22.0
	pill_picker.clear()
	for index in range(pills.size()):
		pill_picker.add_item("%s  x%d" % [str(pills[index].get("name", "Linh đan")), int(pills[index].get("count", 0))], index)
		pill_picker.set_item_metadata(index, str(pills[index].get("id", "")))
	pill_picker.disabled = not _is_player_turn() or pills.is_empty()
	pill_button.disabled = not _is_player_turn() or pills.is_empty()
	for action_button in player_action_buttons:
		if action_button == skill_button:
			action_button.disabled = not _is_player_turn() or float(player["mp"]) < 22.0
		else:
			action_button.disabled = not _is_player_turn()
	for child in [skill_button, pill_picker, pill_button, retreat_button]:
		if child is Control:
			child.modulate.a = 0.55 if child.disabled else 1.0
	combat_log.clear()
	for line in log_lines:
		combat_log.append_text(line + "\n")
	combat_log.scroll_to_line(maxi(0, combat_log.get_line_count() - 1))

func _show_result_controls(result_kind: String) -> void:
	combat_result = result_kind
	turn_label.text = {"victory": "CHIẾN THẮNG", "defeat": "THẤT BẠI", "retreat": "ĐÃ RÚT LUI"}.get(result_kind, "KẾT THÚC")
	turn_label.add_theme_color_override("font_color", GOLD_LIGHT if result_kind == "victory" else RED)
	for child in player_action_buttons + [pill_picker, pill_button]:
		child.disabled = true
		child.modulate.a = 0.55
	finish_button.visible = true

func _emit_result_and_close() -> void:
	var payload := {
		"result": combat_result,
		"opponent": enemy.duplicate(true),
		"consumed_pills": consumed_pills.duplicate(true),
		"player_hp_ratio": float(player["hp"]) / maxf(1.0, float(player["max_hp"])),
	}
	combat_finished.emit(payload)
	queue_free()

func _add_log(message: String) -> void:
	log_lines.append(message)
	if log_lines.size() > 40:
		log_lines.pop_front()
	if is_instance_valid(combat_log):
		combat_log.clear()
		for line in log_lines:
			combat_log.append_text(line + "\n")
		combat_log.scroll_to_line(maxi(0, combat_log.get_line_count() - 1))

func _label(text: String, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	return label

func _button(text: String, color: Color) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size.y = 46
	button.add_theme_font_size_override("font_size", 11)
	button.add_theme_color_override("font_color", color)
	button.add_theme_color_override("font_hover_color", GOLD_LIGHT)
	button.add_theme_stylebox_override("normal", _style(Color("#102f27"), Color("#80632f"), 1, 4))
	button.add_theme_stylebox_override("hover", _style(Color("#1b493b"), GOLD, 1, 4))
	button.add_theme_stylebox_override("pressed", _style(Color("#071f1a"), GOLD_LIGHT, 1, 4))
	return button

func _separator() -> HSeparator:
	var separator := HSeparator.new()
	separator.add_theme_color_override("separator", Color("#376c55"))
	return separator

func _style(background: Color, border: Color, border_width: int, radius: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = background
	style.border_color = border
	style.set_border_width_all(border_width)
	style.set_corner_radius_all(radius)
	return style
