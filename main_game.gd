extends Control

const CLICK_EFFECT_SCENE: PackedScene = preload("res://ClickEffect.tscn")
const JSONBIN_API_KEY: String = "$2a$10$dCHnr/WkZS54zRqLDYLqrOInnicPNZK2uYmCmoYc0LQ1NLgxgoUqu"
const AUTH_BIN_ID: String = "6aabc2e3ac6210605ad7ef66"
const JSONBIN_URL: String = "https://api.jsonbin.io/v3/b/%s"
const AUTOSAVE_INTERVAL_SECONDS := 45.0

const JADE := Color("#071f1a")
const JADE_PANEL := Color("#0d3028")
const JADE_LIGHT := Color("#124638")
const GOLD := Color("#d8ae58")
const GOLD_BRIGHT := Color("#f1d184")
const TEXT := Color("#e7eadc")
const MUTED := Color("#9cb4a5")
const SUCCESS := Color("#83c58d")
const DANGER := Color("#df8777")
const STATE_VERSION := 5
const PHASE_NAMES: Array[String] = ["Sơ Kỳ", "Trung Kỳ", "Hậu Kỳ", "Viên Mãn"]
const MAJOR_REALM_SEEDS: Array[String] = [
	"Luyện Khí Kỳ", "Trúc Cơ Kỳ", "Kim Đan Kỳ", "Nguyên Anh Kỳ", "Hóa Thần Kỳ",
	"Luyện Hư Kỳ", "Hợp Thể Kỳ", "Đại Thừa Kỳ", "Độ Kiếp Kỳ", "Chân Tiên Cảnh",
	"Thiên Tiên Cảnh", "Huyền Tiên Cảnh", "Kim Tiên Cảnh", "Thái Ất Cảnh", "Đại La Cảnh",
	"Tiên Vương Cảnh", "Tiên Đế Cảnh", "Thánh Nhân Cảnh", "Thiên Đạo Cảnh", "Hỗn Nguyên Cảnh",
	"Vĩnh Hằng Cảnh", "Hư Vô Cảnh", "Tạo Hóa Cảnh", "Chí Tôn Cảnh", "Siêu Thoát Cảnh",
	]
const GENERATED_REALM_PREFIXES: Array[String] = [
	"Tinh Hà", "Thái Sơ", "Vạn Tượng", "Cửu U", "Thiên Môn", "Hồng Mông", "Hư Không", "Vô Cực",
	"Tịch Diệt", "Luân Hồi", "Bất Hủ", "Nguyên Sơ", "Thần Tàng", "Đạo Nguyên", "Thiên Khải",
	"Vạn Cổ", "Chư Thiên", "Thâm Uyên", "Tinh Quang", "Thái Hư", "Càn Khôn", "Hỗn Độn",
	]
const ITEM_CATEGORIES: Array[String] = ["VŨ KHÍ", "PHÁP BẢO", "ĐAN DƯỢC", "KỲ TRÂN DỊ THẢO", "CÔNG PHÁP BÍ TỊCH"]
const ITEM_RARITIES: Array[String] = ["Phàm Phẩm", "Hoàng Cấp", "Huyền Cấp", "Địa Cấp", "Thiên Cấp", "Thần Cấp"]
const ITEM_RARITY_COLORS: Array[Color] = [Color("#d5d8d2"), Color("#72ce82"), Color("#69a9ee"), Color("#bb82e8"), Color("#eea04f"), Color("#ff625b")]
const ITEM_CATEGORY_ICONS: Array[String] = ["⚔", "✦", "✧", "❈", "☯"]
const ITEM_NAME_ROOTS: Array[String] = ["Thanh Vân", "Xích Diễm", "Huyền Minh", "Tử Tiêu", "Thái Hư", "Càn Khôn", "Vạn Kiếp", "Tinh Hà", "Bất Hủ", "Hỗn Độn", "Thiên Cơ", "Luân Hồi"]
const ITEM_PAGE_SIZE := 36
const SECRET_REALM_COUNT := 50
const SECRET_REALM_NAMES: Array[String] = [
	"Linh Khê Cốc", "Tử Trúc Lâm", "Hàn Nguyệt Động", "Xích Viêm Sơn", "Vạn Thảo Viên",
	"Phong Lôi Đài", "U Minh Hà", "Thiên Cơ Các", "Bạch Cốt Lĩnh", "Thanh Vân Bí Phủ",
	"Huyền Băng Cung", "Kim Ô Sào", "Thái Hư Cổ Lộ", "Lạc Nhật Sa Hải", "Tinh Vẫn Hải",
	"Cửu U Ma Quật", "Vạn Kiếm Mộ", "Hỗn Nguyên Điện", "Địa Tâm Hỏa Uyên", "Thiên Hà Cổ Thành",
	"Luân Hồi Cấm Địa", "Hồng Mông Thạch Lâm", "Vô Tận Kiếm Vực", "Thái Cổ Long Sào", "Chư Thiên Chi Môn",
	"Tịch Diệt Chi Hải", "Càn Khôn Thần Điện", "Tinh Không Cổ Chiến Trường", "Vạn Cổ Dược Viên", "Hư Vô Thiên Khư",
	"Thiên Đạo Đài", "Bất Hủ Tiên Lăng", "Thần Ma Chiến Trường", "Hỗn Độn Khởi Nguyên", "Cửu Thiên Thánh Vực",
	"Vĩnh Hằng Thần Thành", "Tạo Hóa Ngọc Kinh", "Đại Đạo Trường Hà", "Siêu Thoát Chi Môn", "Nguyên Sơ Thần Giới",
	"Chí Tôn Cổ Điện", "Vô Cực Thiên Uyên", "Thâm Không Đạo Tàng", "Quy Khư Chung Mạt", "Thái Sơ Thiên Môn",
	"Hồng Hoang Tổ Địa", "Vạn Đạo Thiên Bi", "Chân Lý Thần Hải", "Đạo Ngoại Chi Cảnh", "Chí Cao Vô Thượng Cảnh",
]

var REALMS: Array[String] = []
var progression_ladder: Array[Dictionary] = []
var major_realm_catalog: Array[Dictionary] = []
var item_catalog: Array[Dictionary] = []
var secret_realm_catalog: Array[Dictionary] = []

const BODY_REALMS: Array[String] = [
	"Bì Nhục Cảnh", "Tôi Cốt Cảnh", "Luyện Cốt Cảnh", "Ngọc Cốt Cảnh",
	"Kim Thân Cảnh", "Kim Cương Thể",
]

const CODEX_ENTRIES := [
	{"id": "weapon_pham_kiem_go", "category": "PHÁP BẢO & THẦN BINH", "name": "Mộc Kiếm Tân Thủ", "grade": "Phàm", "details": "Công kích +2 · Kiếm gỗ nhập môn", "icon": "⚔"},
	{"id": "weapon_linh_phi_kiem", "category": "PHÁP BẢO & THẦN BINH", "name": "Phi Sương Kiếm", "grade": "Linh", "details": "Công kích +18 · Tăng 3% né tránh", "icon": "⚔"},
	{"id": "weapon_tien_thien_dao", "category": "PHÁP BẢO & THẦN BINH", "name": "Tiên Thiên Đạo Binh", "grade": "Tiên", "details": "Công kích +120 · Chưa rõ lai lịch", "icon": "✦"},
	{"id": "beast_linh_ho", "category": "LINH THÚ & TỌA KIẾM", "name": "Linh Hồ Ba Đuôi", "grade": "Linh", "details": "Tốc độ tu luyện +5%", "icon": "◇"},
	{"id": "beast_kiem_phong", "category": "LINH THÚ & TỌA KIẾM", "name": "Kiếm Phong Điểu", "grade": "Tiên", "details": "Tốc độ hành trình +15%", "icon": "◇"},
	{"id": "elixir_tu_khi_pham", "category": "ĐAN DƯỢC THIÊN TÀI ĐỊA BẢO", "name": "Tụ Khí Đan Phàm Phẩm", "grade": "Phàm", "details": "Hấp thu linh khí +10% trong 60 giây", "icon": "✧"},
	{"id": "elixir_truc_co", "category": "ĐAN DƯỢC THIÊN TÀI ĐỊA BẢO", "name": "Trúc Cơ Đan", "grade": "Linh", "details": "Tăng tỷ lệ đột phá cảnh giới", "icon": "✧"},
	{"id": "elixir_hon_don", "category": "ĐAN DƯỢC THIÊN TÀI ĐỊA BẢO", "name": "Hỗn Độn Nguyên Đan", "grade": "Thần", "details": "Bí phương thất truyền của thượng giới", "icon": "✧"},
	{"id": "skin_pham_y", "category": "NGOẠI TRANG / SKIN", "name": "Đạo Bào Thanh Vân", "grade": "Phàm", "details": "Ngoại trang khởi đầu", "icon": "衣"},
	{"id": "skin_tien_vu", "category": "NGOẠI TRANG / SKIN", "name": "Vũ Y Phi Tiên", "grade": "Tiên", "details": "Ngoại trang giới hạn sự kiện", "icon": "衣"},
]

@onready var http_request: HTTPRequest = %HTTPRequest

var cultivation := {"state_version": STATE_VERSION, "realm_index": 0, "realm_name": "Luyện Khí Kỳ - Sơ Kỳ - Tầng 1", "cultivation": 0.0, "cultivation_need": 100.0, "spirit": 0.0, "spirit_per_second": 1.0, "body_mode": false, "backlash_seconds": 0.0}
var body_cultivation := {"realm_index": 0, "realm_name": BODY_REALMS[0], "power": 0.0, "power_need": 100.0, "blood": 0.0, "blood_per_second": 1.0}
var inventory := {"herbs": {"Thanh Linh Thảo": 0, "Tử Vân Hoa": 0, "Hỏa Linh Quả": 0}, "elixirs": [{"id": "elixir_tu_khi_pham", "name": "Tụ Khí Đan Phàm Phẩm", "description": "Tăng 10% hiệu quả hấp thu trong 60 giây", "count": 1, "effect": "absorb"}]}
var materials := {"Linh Khí": [0, 100], "Thanh Linh Thảo": [0, 0], "Tử Vân Hoa": [0, 0]}
var elixirs: Array = inventory["elixirs"]
var codex_unlocked_ids: Array = ["elixir_tu_khi_pham"]
var owned_item_ids: Array = ["elixir_tu_khi_pham"]
var item_inventory: Dictionary = {"elixir_tu_khi_pham": 1}
var equipment: Dictionary = {"VŨ KHÍ": "", "PHÁP BẢO": "", "TRANG SỨC": ""}
var spirit_stones: int = 0
var combat_power: int = 100
var secret_realm_clears: Array = []
var leaderboard_entries: Array = []
var leaderboard_loaded := false
var leaderboard_loading := false
var arena_challenges_today := 0
var arena_last_day := ""
var cultivation_bar: ProgressBar
var realm_label: Label
var cultivation_value_label: Label
var spirit_label: Label
var status_label: Label
var breakthrough_button: Button
var elixir_list: VBoxContainer
var notification_label: Label
var cloud_status_label: Label
var absorb_bonus := 1.0
var breakthrough_bonus := 0.0
var backlash_label: Label
var material_value_labels: Dictionary = {}
var center_content: VBoxContainer
var formation_active := false
var left_realm_label: Label
var left_bar: ProgressBar
var left_value_label: Label
var left_status_label: Label
var left_panel_container: VBoxContainer
var left_collect_button: Button
var left_action_button: Button
var left_title_label: Label
var left_subtitle_mat_label: Label
var left_energy_title_label: Label
var left_material_rows: Array[Control] = []
var active_center_tab := "TU LUYỆN"
var item_codex_page := 0
var item_codex_grid: GridContainer
var item_codex_page_label: Label
var popup_overlay: Control
var popup_body: VBoxContainer
var popup_title: Label
var leaderboard_status_label: Label
var arena_target_label: Label
var arena_status_label: Label
var main_margin: MarginContainer
var main_columns: BoxContainer
var main_scroll: ScrollContainer
var responsive_left_panel: Control
var responsive_center_panel: Control
var responsive_right_panel: Control
var feature_popup_panel: PanelContainer
var authentication_panel: PanelContainer
var auth_overlay: Control
var auth_username_input: LineEdit
var auth_password_input: LineEdit
var auth_error_label: Label
var auth_login_tab: Button
var auth_register_tab: Button
var auth_submit_button: Button
var auth_mode := "login"
var auth_request_action := ""
var auth_registry: Array = []
var current_username := ""
var authenticated_account: Dictionary = {}
var is_authenticated := false
var autosave_elapsed := 0.0
var pending_leaderboard_fetch := false
var pending_auth_username := ""
var pending_auth_password := ""
var last_click_frame := -1
var last_click_position := Vector2.INF
var cloud_request_kind := ""

func _initialize_progression_ladder() -> void:
	if not progression_ladder.is_empty():
		return
	var major_count := 120
	for major_index in range(major_count):
		var major_name: String
		if major_index < MAJOR_REALM_SEEDS.size():
			major_name = MAJOR_REALM_SEEDS[major_index]
		else:
			var prefix := GENERATED_REALM_PREFIXES[(major_index - MAJOR_REALM_SEEDS.size()) % GENERATED_REALM_PREFIXES.size()]
			major_name = prefix + " Cảnh Thứ " + str(major_index + 1)
		var major_entry := {"index": major_index, "name": major_name, "phases": []}
		major_realm_catalog.append(major_entry)
		for phase_index in range(PHASE_NAMES.size()):
			var phase_entry := {"name": PHASE_NAMES[phase_index], "levels": []}
			major_entry["phases"].append(phase_entry)
			for layer in range(10):
				var level_index := progression_ladder.size()
				var level_name := major_name + " - " + PHASE_NAMES[phase_index] + " - Tầng " + str(layer + 1)
				if level_index == 0:
					level_name = "Luyện Khí Kỳ - Tầng 1"
				var level := {"index": level_index, "major_index": major_index, "phase_index": phase_index, "layer": layer + 1, "major_name": major_name, "phase_name": PHASE_NAMES[phase_index], "name": level_name, "cultivation_need": _cultivation_need_for_level(level_index)}
				progression_ladder.append(level)
				REALMS.append(level_name)
				phase_entry["levels"].append(level)

func _cultivation_need_for_level(level_index: int) -> float:
	var major_index := level_index / 40
	# A level-one requirement of 1,000 grows every layer and gains a 3x major-realm multiplier.
	var growth := pow(1.24, float(level_index)) * pow(3.0, float(major_index))
	return snappedf(1000.0 * growth, 1.0)

func _current_progression_level() -> Dictionary:
	var index := clampi(int(cultivation.get("realm_index", 0)), 0, progression_ladder.size() - 1)
	return progression_ladder[index]

func _normalize_progression_state() -> void:
	var current_level := _current_progression_level()
	cultivation["realm_index"] = current_level["index"]
	cultivation["realm_name"] = current_level["name"]
	cultivation["cultivation_need"] = current_level["cultivation_need"]

func _initialize_item_pool() -> void:
	if not item_catalog.is_empty():
		return
	var item_index := 0
	for category_index in range(ITEM_CATEGORIES.size()):
		for rarity_index in range(ITEM_RARITIES.size()):
			for variant in range(24):
				var root := ITEM_NAME_ROOTS[(variant + rarity_index * 2 + category_index) % ITEM_NAME_ROOTS.size()]
				var item_id := "item_%03d_%02d_%02d" % [category_index, rarity_index, variant]
				var source: String = ["Đả tọa", "Rèn thể", "Đánh quái", "Mở hộp quà"][item_index % 4]
				var item := {"id": item_id, "category": ITEM_CATEGORIES[category_index], "rarity": ITEM_RARITIES[rarity_index], "rarity_index": rarity_index, "name": ITEM_RARITIES[rarity_index] + " " + root + " " + ITEM_CATEGORIES[category_index].capitalize() + " " + str(variant + 1), "icon": ITEM_CATEGORY_ICONS[category_index], "details": "Cấp thuộc tính %d · Có thể nhận qua %s" % [(rarity_index + 1) * (variant + 1), source], "source": source, "power": (rarity_index + 1) * (variant + 1)}
				item_catalog.append(item)
				item_index += 1
	var starter := {"id": "elixir_tu_khi_pham", "category": "ĐAN DƯỢC", "rarity": "Phàm Phẩm", "rarity_index": 0, "name": "Tụ Khí Đan Phàm Phẩm", "icon": "✧", "details": "Hấp thu linh khí +10% trong 60 giây", "source": "Đả tọa / Mở hộp quà", "power": 10}
	item_catalog.push_front(starter)
	_initialize_secret_realm_catalog()

func _initialize_secret_realm_catalog() -> void:
	if not secret_realm_catalog.is_empty():
		return
	for index in range(SECRET_REALM_COUNT):
		secret_realm_catalog.append({
			"index": index,
			"name": SECRET_REALM_NAMES[index],
			"difficulty": index + 1,
			"stone_min": 10 + index * 12,
			"stone_max": 40 + index * 40,
			"drop_chance": minf(0.45 + float(index) * 0.008, 0.85),
		})

func _max_secret_realm_rarity(difficulty: int) -> int:
	if difficulty >= 48:
		return 5
	if difficulty >= 39:
		return 4
	if difficulty >= 26:
		return 3
	if difficulty >= 11:
		return 2
	return 1

func _rarity_drop_weight(rarity_index: int, max_rarity: int) -> float:
	var distance := max_rarity - rarity_index
	return pow(3.0, float(distance))

func _pick_secret_realm_item(max_rarity: int) -> Dictionary:
	var candidates: Array[Dictionary] = []
	var total_weight := 0.0
	for item in item_catalog:
		if int(item["rarity_index"]) <= max_rarity:
			candidates.append(item)
			total_weight += _rarity_drop_weight(int(item["rarity_index"]), max_rarity)
	if candidates.is_empty():
		return {}
	var roll := randf() * total_weight
	for item in candidates:
		roll -= _rarity_drop_weight(int(item["rarity_index"]), max_rarity)
		if roll <= 0.0:
			return item
	return candidates.back()

func explore_secret_realm(realm_index: int) -> Dictionary:
	_initialize_secret_realm_catalog()
	if realm_index < 0 or realm_index >= secret_realm_catalog.size():
		return {"success": false, "message": "Bí cảnh không tồn tại."}
	var realm: Dictionary = secret_realm_catalog[realm_index]
	var required_index := _secret_realm_required_progression(int(realm["difficulty"]))
	if int(cultivation["realm_index"]) < required_index:
		var locked_result := {"success": false, "message": "Chưa đủ cảnh giới để mở khóa bí cảnh này.", "required_realm": REALMS[required_index]}
		_show_notification("Bí cảnh bị khóa\nCần: " + REALMS[required_index], DANGER)
		return locked_result
	var stone_reward := randi_range(int(realm["stone_min"]), int(realm["stone_max"]))
	var drops: Array[Dictionary] = []
	if randf() <= float(realm["drop_chance"]):
		var max_rarity := _max_secret_realm_rarity(int(realm["difficulty"]))
		var item := _pick_secret_realm_item(max_rarity)
		if not item.is_empty():
			drops.append(item)
			var item_id: String = item["id"]
			item_inventory[item_id] = int(item_inventory.get(item_id, 0)) + 1
			if item_id not in owned_item_ids:
				owned_item_ids.append(item_id)
			if item_id not in codex_unlocked_ids:
				codex_unlocked_ids.append(item_id)
	spirit_stones += stone_reward
	if realm_index not in secret_realm_clears:
		secret_realm_clears.append(realm_index)
	var result := {"success": true, "realm_name": realm["name"], "spirit_stones": stone_reward, "items": drops}
	_show_secret_realm_result(result)
	if active_center_tab == "BÍ CẢNH" and is_instance_valid(popup_body):
		_render_popup_tab("BÍ CẢNH")
	return result

func _show_secret_realm_result(result: Dictionary) -> void:
	var lines: Array[String] = ["BÍ CẢNH · " + str(result["realm_name"]), "Vượt qua thành công", "Linh Thạch: +" + _format_number(result["spirit_stones"])]
	var items: Array = result["items"]
	if items.is_empty():
		lines.append("Vật phẩm: Không rơi vật phẩm lần này")
	else:
		lines.append("Vật phẩm nhận được:")
		for item in items:
			lines.append("%s %s [%s]" % [item["icon"], item["name"], item["rarity"]])
	_show_notification("\n".join(lines), GOLD_BRIGHT)

func _award_random_item(source: String) -> void:
	if item_catalog.is_empty():
		return
	var candidates: Array[Dictionary] = []
	for item in item_catalog:
		if item["source"].contains(source) or source == "Đánh quái" or source == "Mở hộp quà":
			candidates.append(item)
	if candidates.is_empty():
		return
	var item: Dictionary = candidates[randi() % candidates.size()]
	var item_id: String = item["id"]
	item_inventory[item_id] = int(item_inventory.get(item_id, 0)) + 1
	if item_id not in owned_item_ids:
		owned_item_ids.append(item_id)
	if item_id not in codex_unlocked_ids:
		codex_unlocked_ids.append(item_id)
	_show_notification("Nhận được " + item["icon"] + " " + item["name"], ITEM_RARITY_COLORS[item["rarity_index"]])

func reward_from_monster() -> void:
	_award_random_item("Đánh quái")

func open_gift_box() -> void:
	_award_random_item("Mở hộp quà")

func _ready() -> void:
	_initialize_progression_ladder()
	_initialize_item_pool()
	_normalize_progression_state()
	http_request.request_completed.connect(_on_cloud_request_completed)
	_build_interface()
	_build_auth_gate()
	resized.connect(_update_responsive_layout)
	_update_responsive_layout()
	_update_display()

func _process(delta: float) -> void:
	if cultivation["body_mode"]:
		body_cultivation["power"] += body_cultivation["blood_per_second"] * delta
		body_cultivation["blood"] += body_cultivation["blood_per_second"] * delta
	else:
		if cultivation["backlash_seconds"] > 0.0:
			cultivation["backlash_seconds"] = maxf(0.0, cultivation["backlash_seconds"] - delta)
		var backlash_multiplier := 0.5 if cultivation["backlash_seconds"] > 0.0 else 1.0
		cultivation["cultivation"] += cultivation["spirit_per_second"] * delta * absorb_bonus * backlash_multiplier
		cultivation["spirit"] += cultivation["spirit_per_second"] * delta
	if is_authenticated:
		autosave_elapsed += delta
		if autosave_elapsed >= AUTOSAVE_INTERVAL_SECONDS and cloud_request_kind == "" and auth_request_action == "":
			autosave_elapsed = 0.0
			save_game_to_cloud()
	_update_display()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		_spawn_click_effect(event.position)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		var same_event := last_click_frame == Engine.get_process_frames() and last_click_position.distance_squared_to(event.position) < 0.01
		if not same_event:
			_spawn_click_effect(event.position)

func _spawn_click_effect(screen_position: Vector2) -> void:
	last_click_frame = Engine.get_process_frames()
	last_click_position = screen_position
	var effect := CLICK_EFFECT_SCENE.instantiate() as Node2D
	if effect == null:
		return
	effect.position = screen_position
	add_child(effect)

func _exit_tree() -> void:
	if is_authenticated:
		save_game_to_cloud()

func _build_interface() -> void:
	var background := ColorRect.new()
	background.color = JADE
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background)
	main_margin = MarginContainer.new()
	main_margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(main_margin)
	var root := VBoxContainer.new()
	root.add_theme_constant_override("separation", 16)
	main_margin.add_child(root)
	root.add_child(_build_header())
	main_scroll = ScrollContainer.new()
	main_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	main_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	main_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	main_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	main_scroll.clip_contents = true
	root.add_child(main_scroll)
	main_columns = BoxContainer.new()
	main_columns.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	main_columns.size_flags_vertical = Control.SIZE_EXPAND_FILL
	main_columns.clip_contents = true
	main_columns.add_theme_constant_override("separation", 14)
	main_scroll.add_child(main_columns)
	responsive_left_panel = _build_cultivation_panel()
	responsive_center_panel = _build_avatar_panel()
	responsive_right_panel = _build_elixir_panel()
	main_columns.add_child(responsive_left_panel)
	main_columns.add_child(responsive_center_panel)
	main_columns.add_child(responsive_right_panel)
	_build_popup_overlay()

func _update_responsive_layout() -> void:
	var compact := size.x < 900.0
	if is_instance_valid(main_margin):
		var horizontal_margin := 12 if compact else 34
		main_margin.add_theme_constant_override("margin_left", horizontal_margin)
		main_margin.add_theme_constant_override("margin_right", horizontal_margin)
		main_margin.add_theme_constant_override("margin_top", 12 if compact else 26)
		main_margin.add_theme_constant_override("margin_bottom", 12 if compact else 24)
	if is_instance_valid(main_columns):
		main_columns.vertical = compact
		main_columns.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		main_columns.size_flags_vertical = Control.SIZE_EXPAND_FILL
	if is_instance_valid(responsive_left_panel):
		responsive_left_panel.custom_minimum_size.x = 0 if compact else 340
		responsive_left_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL if compact else Control.SIZE_SHRINK_BEGIN
	if is_instance_valid(responsive_center_panel):
		responsive_center_panel.custom_minimum_size.x = 0
		responsive_center_panel.custom_minimum_size.y = 520 if compact else 620
		responsive_center_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	if is_instance_valid(responsive_right_panel):
		responsive_right_panel.custom_minimum_size.x = 0 if compact else 340
		responsive_right_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL if compact else Control.SIZE_SHRINK_END
	if is_instance_valid(feature_popup_panel):
		var popup_width: float = minf(1000.0, maxf(320.0, size.x - 24.0))
		var popup_height: float = minf(680.0, maxf(420.0, size.y - 24.0))
		feature_popup_panel.offset_left = -popup_width * 0.5
		feature_popup_panel.offset_top = -popup_height * 0.5
		feature_popup_panel.offset_right = popup_width * 0.5
		feature_popup_panel.offset_bottom = popup_height * 0.5
	if is_instance_valid(authentication_panel):
		var auth_width: float = minf(600.0, maxf(320.0, size.x - 24.0))
		var auth_height: float = minf(490.0, maxf(420.0, size.y - 24.0))
		authentication_panel.offset_left = -auth_width * 0.5
		authentication_panel.offset_top = -auth_height * 0.5
		authentication_panel.offset_right = auth_width * 0.5
		authentication_panel.offset_bottom = auth_height * 0.5

func _build_auth_gate() -> void:
	auth_overlay = Control.new()
	auth_overlay.name = "AuthenticationGate"
	auth_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	auth_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	auth_overlay.z_index = 100
	add_child(auth_overlay)

	var dimmer := ColorRect.new()
	dimmer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dimmer.color = Color(0.01, 0.04, 0.03, 0.96)
	dimmer.mouse_filter = Control.MOUSE_FILTER_STOP
	auth_overlay.add_child(dimmer)

	authentication_panel = PanelContainer.new()
	var panel := authentication_panel
	panel.anchor_left = 0.5
	panel.anchor_top = 0.5
	panel.anchor_right = 0.5
	panel.anchor_bottom = 0.5
	panel.offset_left = -300
	panel.offset_top = -245
	panel.offset_right = 300
	panel.offset_bottom = 245
	panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
	panel.grow_vertical = Control.GROW_DIRECTION_BOTH
	panel.clip_contents = true
	panel.add_theme_stylebox_override("panel", _style(JADE_PANEL, 12, GOLD, 2))
	auth_overlay.add_child(panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 28)
	margin.add_theme_constant_override("margin_top", 26)
	margin.add_theme_constant_override("margin_right", 28)
	margin.add_theme_constant_override("margin_bottom", 26)
	panel.add_child(margin)
	var layout := VBoxContainer.new()
	layout.add_theme_constant_override("separation", 12)
	margin.add_child(layout)

	var title := _label("CỔNG THIÊN ĐẠO", 24, GOLD_BRIGHT)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	layout.add_child(title)
	var subtitle := _label("Đăng nhập để đồng bộ hành trình tu tiên", 11, MUTED)
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	layout.add_child(subtitle)

	var modes := HBoxContainer.new()
	modes.add_theme_constant_override("separation", 6)
	auth_login_tab = _button("ĐĂNG NHẬP", GOLD, -1)
	auth_login_tab.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	auth_login_tab.pressed.connect(_set_auth_mode.bind("login"))
	modes.add_child(auth_login_tab)
	auth_register_tab = _button("TẠO TÀI KHOẢN", MUTED, -1)
	auth_register_tab.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	auth_register_tab.pressed.connect(_set_auth_mode.bind("register"))
	modes.add_child(auth_register_tab)
	layout.add_child(modes)

	auth_username_input = LineEdit.new()
	auth_username_input.placeholder_text = "Tên đăng nhập"
	auth_username_input.custom_minimum_size.y = 42
	auth_username_input.max_length = 32
	layout.add_child(auth_username_input)
	auth_password_input = LineEdit.new()
	auth_password_input.placeholder_text = "Mật khẩu"
	auth_password_input.secret = true
	auth_password_input.custom_minimum_size.y = 42
	auth_password_input.max_length = 128
	auth_password_input.text_submitted.connect(func(_text: String): _submit_auth())
	layout.add_child(auth_password_input)

	auth_error_label = _label("", 11, DANGER)
	auth_error_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	auth_error_label.custom_minimum_size.y = 34
	layout.add_child(auth_error_label)
	auth_submit_button = _button("ĐĂNG NHẬP", GOLD_BRIGHT, -1)
	auth_submit_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	auth_submit_button.pressed.connect(_submit_auth)
	layout.add_child(auth_submit_button)
	_set_auth_mode("login")

func _set_auth_mode(mode: String) -> void:
	auth_mode = mode
	if not is_instance_valid(auth_error_label):
		return
	auth_error_label.text = ""
	auth_login_tab.add_theme_color_override("font_color", GOLD if mode == "login" else MUTED)
	auth_register_tab.add_theme_color_override("font_color", GOLD if mode == "register" else MUTED)
	auth_submit_button.text = "ĐĂNG NHẬP" if mode == "login" else "TẠO TÀI KHOẢN"

func _submit_auth() -> void:
	var username := auth_username_input.text.strip_edges()
	var password := auth_password_input.text
	if username.length() < 3:
		auth_error_label.text = "Tên đăng nhập cần ít nhất 3 ký tự."
		return
	if password.length() < 3:
		auth_error_label.text = "Mật khẩu cần ít nhất 3 ký tự."
		return
	if AUTH_BIN_ID.is_empty():
		auth_error_label.text = "Chưa cấu hình AUTH_BIN_ID cho JSONBin."
		return
	auth_submit_button.disabled = true
	auth_error_label.text = "Đang kết nối JSONBin..."
	pending_auth_username = username
	pending_auth_password = password
	auth_request_action = "register_lookup" if auth_mode == "register" else "login_lookup"
	var error := http_request.request(JSONBIN_URL % AUTH_BIN_ID + "/latest", _cloud_headers(), HTTPClient.METHOD_GET)
	if error != OK:
		auth_submit_button.disabled = false
		auth_error_label.text = "Không thể kết nối máy chủ tài khoản."
		auth_request_action = ""

func _auth_registry_payload(users: Array) -> String:
	return JSON.stringify({"users": _normalized_users_for_cloud(users)})

func _normalized_users_for_cloud(users: Array) -> Array:
	var normalized: Array = []
	for raw_user in users:
		if not raw_user is Dictionary:
			continue
		var user: Dictionary = raw_user.duplicate(true)
		var plaintext_password := str(user.get("password", ""))
		var stored_hash := str(user.get("password_hash", ""))
		user.erase("password")
		if stored_hash.is_empty() and not plaintext_password.is_empty():
			stored_hash = _password_hash(plaintext_password)
		user["password_hash"] = stored_hash
		user["username"] = str(user.get("username", "")).strip_edges()
		user["realm"] = str(user.get("realm", "Luyện Khí Kỳ"))
		user["tu_vi"] = float(user.get("tu_vi", 0.0))
		user["linh_thach"] = int(user.get("linh_thach", 100))
		user["luc_chien"] = int(user.get("luc_chien", 100))
		user["leaderboard_public"] = bool(user.get("leaderboard_public", true))
		normalized.append(user)
	return normalized

func _finish_authentication(username: String, account: Dictionary = {}) -> void:
	current_username = username
	authenticated_account = account.duplicate(true)
	is_authenticated = true
	_hydrate_state_from_account(account)
	auth_request_action = ""
	pending_auth_username = ""
	pending_auth_password = ""
	auth_overlay.visible = false
	auth_submit_button.disabled = false
	load_game_from_cloud()
	_sync_current_account_profile()
	_show_notification("Đăng nhập thành công · " + username, SUCCESS)

func _hydrate_state_from_account(account: Dictionary) -> void:
	if account.is_empty():
		return
	var saved_realm := str(account.get("realm", account.get("realm_name", ""))).strip_edges()
	var saved_tu_vi := float(account.get("tu_vi", 0.0))
	var saved_spirit_stones := int(account.get("linh_thach", 0))
	var saved_power := int(account.get("luc_chien", 0))
	if not saved_realm.is_empty():
		var matched_index := -1
		for index in range(progression_ladder.size()):
			var level_name := str(progression_ladder[index].get("name", ""))
			if level_name == saved_realm or level_name.begins_with(saved_realm + " -"):
				matched_index = index
				break
		if matched_index >= 0:
			cultivation["realm_index"] = matched_index
			cultivation["realm_name"] = progression_ladder[matched_index]["name"]
			cultivation["cultivation_need"] = progression_ladder[matched_index]["cultivation_need"]
	if account.has("tu_vi"):
		cultivation["cultivation"] = maxf(0.0, saved_tu_vi)
	if account.has("linh_thach"):
		spirit_stones = maxi(0, saved_spirit_stones)
	if account.has("luc_chien"):
		combat_power = maxi(0, saved_power)
	if account.has("equipment") and account["equipment"] is Dictionary:
		equipment = account["equipment"].duplicate(true)
	if account.has("item_inventory") and account["item_inventory"] is Dictionary:
		item_inventory = account["item_inventory"].duplicate(true)
	if account.has("owned_item_ids") and account["owned_item_ids"] is Array:
		owned_item_ids = account["owned_item_ids"].duplicate()
	_normalize_progression_state()

func _build_popup_overlay() -> void:
	popup_overlay = Control.new()
	popup_overlay.name = "CenterFeaturePopup"
	popup_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	popup_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	popup_overlay.z_index = 50
	popup_overlay.visible = false
	add_child(popup_overlay)

	var dimmer := ColorRect.new()
	dimmer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dimmer.color = Color(0.0, 0.0, 0.0, 0.78)
	dimmer.mouse_filter = Control.MOUSE_FILTER_STOP
	dimmer.gui_input.connect(_on_popup_dimmer_input)
	popup_overlay.add_child(dimmer)

	feature_popup_panel = PanelContainer.new()
	var popup := feature_popup_panel
	popup.name = "FeaturePopupPanel"
	popup.anchor_left = 0.5
	popup.anchor_top = 0.5
	popup.anchor_right = 0.5
	popup.anchor_bottom = 0.5
	popup.offset_left = -500
	popup.offset_top = -340
	popup.offset_right = 500
	popup.offset_bottom = 340
	popup.grow_horizontal = Control.GROW_DIRECTION_BOTH
	popup.grow_vertical = Control.GROW_DIRECTION_BOTH
	popup.clip_contents = true
	popup.add_theme_stylebox_override("panel", _style(Color("#0b2922"), 12, GOLD, 2))
	popup_overlay.add_child(popup)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 20)
	margin.add_theme_constant_override("margin_top", 18)
	margin.add_theme_constant_override("margin_right", 20)
	margin.add_theme_constant_override("margin_bottom", 20)
	popup.add_child(margin)
	var layout := VBoxContainer.new()
	layout.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	layout.size_flags_vertical = Control.SIZE_EXPAND_FILL
	layout.add_theme_constant_override("separation", 10)
	margin.add_child(layout)

	var header := HBoxContainer.new()
	header.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	popup_title = _label("CHỨC NĂNG", 18, GOLD_BRIGHT)
	popup_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(popup_title)
	var close_button := _button("ĐÓNG [X]", GOLD, 110)
	close_button.pressed.connect(_close_center_popup)
	header.add_child(close_button)
	layout.add_child(header)
	layout.add_child(_rule())
	popup_body = VBoxContainer.new()
	popup_body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	popup_body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	popup_body.clip_contents = true
	layout.add_child(popup_body)

func _build_header() -> Control:
	var header := HBoxContainer.new()
	header.custom_minimum_size.y = 64
	var title := _label("乾 坤  ·  TU TIÊN", 25, GOLD_BRIGHT)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title)
	var save_button := _button("LƯU MÂY", GOLD, 116)
	save_button.pressed.connect(save_game_to_cloud)
	header.add_child(save_button)
	var load_button := _button("TẢI MÂY", MUTED, 116)
	load_button.pressed.connect(load_game_from_cloud)
	header.add_child(load_button)
	cloud_status_label = _label("●  Đang tại thế gian", 12, SUCCESS)
	cloud_status_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	cloud_status_label.custom_minimum_size.x = 150
	header.add_child(cloud_status_label)
	return header

func _build_cultivation_panel() -> Control:
	var panel := _panel(340)
	left_panel_container = panel.get_child(0).get_child(0) as VBoxContainer
	left_panel_container.add_child(_section_tabs(["LUYỆN KHÍ", "LUYỆN THỂ"], _on_cultivation_tab))
	left_title_label = _label("CẢNH GIỚI HIỆN TẠI", 11, MUTED)
	left_panel_container.add_child(left_title_label)
	left_realm_label = _label("", 23, GOLD_BRIGHT)
	left_realm_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	left_panel_container.add_child(left_realm_label)
	left_bar = ProgressBar.new()
	left_bar.custom_minimum_size.y = 16
	left_bar.show_percentage = false
	left_bar.add_theme_stylebox_override("background", _style(JADE, 8, JADE_LIGHT))
	left_bar.add_theme_stylebox_override("fill", _style(GOLD, 8, GOLD))
	left_panel_container.add_child(left_bar)
	left_value_label = _label("", 12, TEXT)
	left_panel_container.add_child(left_value_label)
	left_status_label = _label("", 12, SUCCESS)
	left_panel_container.add_child(left_status_label)
	realm_label = left_realm_label
	cultivation_bar = left_bar
	cultivation_value_label = left_value_label
	status_label = left_status_label
	left_panel_container.add_child(_rule())
	left_subtitle_mat_label = _label("ĐIỀU KIỆN ĐỘT PHÁ", 11, GOLD)
	left_panel_container.add_child(left_subtitle_mat_label)
	backlash_label = _label("", 11, DANGER)
	left_panel_container.add_child(backlash_label)
	for material_name in materials:
		var material_row := _material_row(material_name)
		left_material_rows.append(material_row)
		left_panel_container.add_child(material_row)
	left_panel_container.add_child(_rule())
	left_energy_title_label = _label("LINH KHÍ TÍCH LŨY", 11, MUTED)
	left_panel_container.add_child(left_energy_title_label)
	spirit_label = _label("", 20, GOLD_BRIGHT)
	left_panel_container.add_child(spirit_label)
	left_panel_container.add_child(_label("Tự động hấp thu khi đả tọa", 11, MUTED))
	var actions := HBoxContainer.new()
	actions.add_theme_constant_override("separation", 8)
	left_collect_button = _button("NHẬN LINH KHÍ", GOLD, 150)
	left_collect_button.pressed.connect(_collect_current_energy)
	actions.add_child(left_collect_button)
	left_action_button = _button("✦  ĐỘT PHÁ", GOLD_BRIGHT, 130)
	left_action_button.pressed.connect(_attempt_current_breakthrough)
	breakthrough_button = left_action_button
	actions.add_child(left_action_button)
	left_panel_container.add_child(actions)
	left_panel_container.add_child(_label("Tỷ lệ thay đổi theo cảnh giới · Thất bại mất 20-35% tu vi", 10, MUTED))
	return panel

func _build_avatar_panel() -> Control:
	var panel := _panel(0)
	panel.custom_minimum_size.y = 620
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	panel.clip_contents = true
	var content := panel.get_child(0).get_child(0) as VBoxContainer
	content.add_theme_constant_override("separation", 10)
	content.add_child(_section_tabs(["TU LUYỆN", "QUANG HOÀN", "TRẬN PHÁP", "NHÂN VẬT", "ĐỒ GIÁM", "TÚI ĐỒ", "BÍ CẢNH", "BẢNG XẾP HẠNG"], _on_center_tab))
	center_content = VBoxContainer.new()
	center_content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	center_content.size_flags_vertical = Control.SIZE_EXPAND_FILL
	center_content.add_theme_constant_override("separation", 10)
	content.add_child(center_content)
	_render_center_tab("TU LUYỆN")
	return panel

func _render_center_tab(tab_name: String) -> void:
	active_center_tab = tab_name
	for child in center_content.get_children():
		child.queue_free()
	var view: Control
	match tab_name:
		"TU LUYỆN":
			view = _build_training_view()
		"QUANG HOÀN":
			view = _build_aura_view()
		"TRẬN PHÁP":
			view = _build_formation_view()
		"NHÂN VẬT":
			view = _build_character_view()
		"ĐỒ GIÁM":
			view = _build_codex_view()
		"TÚI ĐỒ":
			view = _build_inventory_view()
		"BÍ CẢNH":
			view = _build_secret_realm_view()
		"BẢNG XẾP HẠNG":
			view = _build_leaderboard_view()
	view.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	view.size_flags_vertical = Control.SIZE_EXPAND_FILL
	view.clip_contents = true
	center_content.add_child(view)

func _build_training_view() -> Control:
	var view := VBoxContainer.new()
	view.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var caption := _label("ĐẢ TỌA · TÂM PHÁP VÔ TƯỚNG", 11, MUTED)
	caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	view.add_child(caption)
	var stage := PanelContainer.new()
	stage.size_flags_vertical = Control.SIZE_EXPAND_FILL
	stage.add_theme_stylebox_override("panel", _style(Color("#092720"), 10, Color("#1b5946"), 1))
	var stage_content := VBoxContainer.new()
	stage_content.alignment = BoxContainer.ALIGNMENT_CENTER
	stage_content.add_theme_constant_override("separation", 10)
	stage.add_child(stage_content)
	var avatar := TextureRect.new()
	avatar.custom_minimum_size = Vector2(210, 190)
	avatar.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	avatar.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	stage_content.add_child(avatar)
	if ResourceLoader.exists("res://assets/player_avatar.png"):
		avatar.texture = load("res://assets/player_avatar.png")
	else:
		var placeholder := _label("✧\n\nplayer_avatar.png\n\nChờ chân dung đạo hữu", 16, GOLD)
		placeholder.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		placeholder.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		stage_content.add_child(placeholder)
	view.add_child(stage)
	var slots := HBoxContainer.new()
	slots.alignment = BoxContainer.ALIGNMENT_CENTER
	for slot_name in ["PHÁP BẢO", "LINH THÚ", "ĐAN ĐIỀN"]:
		var slot := _label("◇\n" + slot_name, 11, MUTED)
		slot.custom_minimum_size = Vector2(112, 54)
		slot.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		slot.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		slots.add_child(slot)
	view.add_child(slots)
	return view

func _build_aura_view() -> Control:
	var view := _center_view("QUANG HOÀN · PHI THĂNG BUFF")
	for aura in ["Tụ Linh Sơ Cấp", "Hộ Thể Phàm Nhân", "Thiên Đạo Chúc Phúc"]:
		var row := PanelContainer.new()
		row.custom_minimum_size.y = 58
		row.add_theme_stylebox_override("panel", _style(Color("#0b2922"), 5, Color("#28624e"), 1))
		var line := HBoxContainer.new()
		line.add_theme_constant_override("separation", 12)
		row.add_child(line)
		line.add_child(_label("✦", 20, GOLD))
		var detail := VBoxContainer.new()
		detail.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		detail.add_child(_label(aura, 13, GOLD_BRIGHT))
		detail.add_child(_label("Chưa sở hữu · Thu thập qua nhiệm vụ", 10, MUTED))
		line.add_child(detail)
		line.add_child(_label("KHÓA", 10, MUTED))
		view.add_child(row)
	return view

func _build_formation_view() -> Control:
	var view := _center_view("TRẬN PHÁP · HỘ TÔNG")
	var diagram := GridContainer.new()
	diagram.columns = 3
	diagram.size_flags_vertical = Control.SIZE_EXPAND_FILL
	for index in range(9):
		var flag := _label("⚑" if index in [1, 3, 4, 5, 7] else "·", 28, GOLD if index in [1, 3, 4, 5, 7] else MUTED)
		flag.custom_minimum_size = Vector2(72, 58)
		flag.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		flag.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		diagram.add_child(flag)
	view.add_child(diagram)
	var state := _label("Trận kỳ đang nghỉ · Tăng 25% tốc độ hấp thu khi kích hoạt", 11, MUTED)
	state.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	view.add_child(state)
	var activate := _button("KÍCH HOẠT CỜ TRẬN", GOLD, 190)
	activate.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	activate.pressed.connect(_toggle_formation.bind(state, activate))
	view.add_child(activate)
	return view

func _build_character_view() -> Control:
	var view := _center_view("NHÂN VẬT · PHÀM NHÂN")
	var stats := {"Căn cốt": "10", "Ngộ tính": "10", "Sinh mệnh": "100", "Thể phách": "10", "Độ may mắn": "5"}
	for stat_name in stats:
		var row := HBoxContainer.new()
		row.custom_minimum_size.y = 34
		row.add_child(_label(stat_name, 13, TEXT))
		var value := _label(stats[stat_name], 13, GOLD_BRIGHT)
		value.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		value.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		row.add_child(value)
		view.add_child(row)
	return view

func _build_inventory_view() -> Control:
	var view := VBoxContainer.new()
	view.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	view.size_flags_vertical = Control.SIZE_EXPAND_FILL
	view.add_theme_constant_override("separation", 8)
	view.add_child(_label("TÚI ĐỒ · TRANG BỊ", 15, GOLD_BRIGHT))
	view.add_child(_label("Trang bị tăng trực tiếp Lực Chiến. Phân cấp: Phàm Phẩm → Hoàng Cấp → Thiên Cấp → Thần Khí.", 10, MUTED))
	view.add_child(_rule())
	var slots := HBoxContainer.new()
	slots.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	slots.add_theme_constant_override("separation", 8)
	for slot_name in equipment.keys():
		var slot_panel := PanelContainer.new()
		slot_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		slot_panel.custom_minimum_size.y = 74
		slot_panel.add_theme_stylebox_override("panel", _style(Color("#102f27"), 6, GOLD, 1))
		var slot_content := VBoxContainer.new()
		slot_content.alignment = BoxContainer.ALIGNMENT_CENTER
		slot_panel.add_child(slot_content)
		slot_content.add_child(_label(slot_name, 10, GOLD))
		var equipped_id: String = str(equipment.get(slot_name, ""))
		var equipped := _find_item_by_id(equipped_id)
		slot_content.add_child(_label(str(equipped.get("name", "Trống")), 10, TEXT))
		slot_content.add_child(_label("+" + _format_number(float(equipped.get("power", 0))) + " Lực Chiến", 9, SUCCESS))
		slots.add_child(slot_panel)
	view.add_child(slots)
	view.add_child(_label("Lực Chiến trang bị: +" + _format_number(float(_equipment_power())), 11, GOLD_BRIGHT))
	var scroll := ScrollContainer.new()
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.clip_contents = true
	view.add_child(scroll)
	var list := VBoxContainer.new()
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	list.add_theme_constant_override("separation", 6)
	scroll.add_child(list)
	var owned_count := 0
	for item in item_catalog:
		if int(item_inventory.get(item["id"], 0)) <= 0:
			continue
		owned_count += 1
		var row := HBoxContainer.new()
		row.custom_minimum_size.y = 48
		var detail := _label("%s  %s\n%s · Sở hữu x%d" % [item["icon"], item["name"], item["rarity"], int(item_inventory[item["id"]])], 10, ITEM_RARITY_COLORS[item["rarity_index"]])
		detail.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(detail)
		if item["category"] in ["VŨ KHÍ", "PHÁP BẢO"]:
			var equip := _button("TRANG BỊ", GOLD, 86)
			equip.pressed.connect(_equip_item.bind(item))
			row.add_child(equip)
		list.add_child(row)
	if owned_count == 0:
		list.add_child(_label("Túi đồ đang trống.", 12, MUTED))
	return view

func _find_item_by_id(item_id: String) -> Dictionary:
	for item in item_catalog:
		if str(item.get("id", "")) == item_id:
			return item
	return {}

func _equipment_slot_for_item(item: Dictionary) -> String:
	if item.get("category", "") == "VŨ KHÍ":
		return "VŨ KHÍ"
	return "PHÁP BẢO"

func _equipment_power() -> int:
	var total := 0
	for item_id in equipment.values():
		total += int(_find_item_by_id(str(item_id)).get("power", 0))
	return total

func _equip_item(item: Dictionary) -> void:
	var slot := _equipment_slot_for_item(item)
	equipment[slot] = str(item["id"])
	combat_power = maxi(combat_power, _base_combat_power() + _equipment_power())
	_show_notification("Đã trang bị " + str(item["name"]) + " · Lực Chiến +" + _format_number(float(item["power"])), SUCCESS)
	if active_center_tab == "TÚI ĐỒ":
		_render_popup_tab("TÚI ĐỒ")

func _base_combat_power() -> int:
	return int(cultivation.get("realm_index", 0)) * 1000 + int(body_cultivation.get("realm_index", 0)) * 250 + int(spirit_stones / 10)

func _build_leaderboard_view() -> Control:
	_prepare_arena_day()
	var view := VBoxContainer.new()
	view.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	view.size_flags_vertical = Control.SIZE_EXPAND_FILL
	view.add_theme_constant_override("separation", 8)
	var heading := HBoxContainer.new()
	var title := _label("BXH TU TIÊN · THIÊN HẠ TRANH PHONG", 15, GOLD_BRIGHT)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	heading.add_child(title)
	leaderboard_status_label = _label("Đang đồng bộ mây..." if leaderboard_loading else ("Đã đồng bộ" if leaderboard_loaded else "Chưa có dữ liệu"), 10, MUTED)
	heading.add_child(leaderboard_status_label)
	var refresh := _button("ĐỒNG BỘ", GOLD, 92)
	refresh.pressed.connect(fetch_leaderboard_from_cloud)
	heading.add_child(refresh)
	view.add_child(heading)
	view.add_child(_label("Chọn một đạo hữu trong BXH để mở lượt tỉ thí hôm nay.", 10, MUTED))
	view.add_child(_rule())

	var split := HBoxContainer.new()
	split.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	split.size_flags_vertical = Control.SIZE_EXPAND_FILL
	split.add_theme_constant_override("separation", 12)
	view.add_child(split)

	var ranking_panel := PanelContainer.new()
	ranking_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	ranking_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	ranking_panel.size_flags_stretch_ratio = 1.4
	ranking_panel.clip_contents = true
	ranking_panel.add_theme_stylebox_override("panel", _style(Color("#0d3028"), 8, Color("#28624e"), 1))
	split.add_child(ranking_panel)
	var ranking_content := VBoxContainer.new()
	ranking_content.add_theme_constant_override("separation", 7)
	ranking_panel.add_child(ranking_content)
	ranking_content.add_child(_label("BẢNG XẾP HẠNG · TOP CAO THỦ", 12, GOLD))
	var ranking_scroll := ScrollContainer.new()
	ranking_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	ranking_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	ranking_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	ranking_scroll.clip_contents = true
	ranking_content.add_child(ranking_scroll)
	var ranking_list := VBoxContainer.new()
	ranking_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	ranking_list.add_theme_constant_override("separation", 6)
	ranking_scroll.add_child(ranking_list)
	if leaderboard_entries.is_empty():
		var empty_label := _label("Chưa có cao thủ nào xuất sơn.", 13, MUTED)
		empty_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		ranking_list.add_child(empty_label)
	else:
		for rank in leaderboard_entries.size():
			var entry: Dictionary = leaderboard_entries[rank]
			var is_current_player := str(entry.get("name", "")).strip_edges() == current_username.strip_edges()
			ranking_list.add_child(_leaderboard_row(entry, rank, is_current_player))

	var arena_panel := PanelContainer.new()
	arena_panel.custom_minimum_size.x = 260
	arena_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	arena_panel.clip_contents = true
	arena_panel.add_theme_stylebox_override("panel", _style(Color("#102f27"), 8, GOLD, 1))
	split.add_child(arena_panel)
	var arena_content := VBoxContainer.new()
	arena_content.add_theme_constant_override("separation", 10)
	arena_panel.add_child(arena_content)
	arena_content.add_child(_label("KHU VỰC TỈ THÍ", 14, GOLD_BRIGHT))
	arena_content.add_child(_label("Mỗi ngày 3 lượt · Thắng nhận Linh Thạch và danh hiệu.", 10, MUTED))
	arena_content.add_child(_rule())
	arena_target_label = _label("Chưa chọn đối thủ", 14, TEXT)
	arena_target_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	arena_content.add_child(arena_target_label)
	arena_status_label = _label("Chọn TỈ THÍ trong bảng xếp hạng.", 11, MUTED)
	arena_status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	arena_content.add_child(arena_status_label)
	var daily := _label("Lượt hôm nay: %d / 3" % arena_challenges_today, 12, GOLD)
	daily.name = "ArenaDailyCounter"
	arena_content.add_child(daily)
	arena_content.add_spacer(false)
	arena_content.add_child(_label("Thưởng cơ bản: 100 - 500 Linh Thạch\nTỉ lệ thắng dựa trên lực chiến và cảnh giới.", 10, MUTED))
	if not leaderboard_loaded and not leaderboard_loading:
		fetch_leaderboard_from_cloud()
	return view

func _leaderboard_row(entry: Dictionary, rank: int, is_current_player: bool = false) -> Control:
	var row := PanelContainer.new()
	row.custom_minimum_size.y = 68
	row.add_theme_stylebox_override("panel", _style(Color("#102f27"), 5, Color("#28624e"), 1))
	var line := HBoxContainer.new()
	line.add_theme_constant_override("separation", 8)
	row.add_child(line)
	var rank_label := _label("#%02d" % (rank + 1), 15, GOLD if rank < 3 else MUTED)
	rank_label.custom_minimum_size.x = 42
	rank_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	line.add_child(rank_label)
	var details := VBoxContainer.new()
	details.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	details.alignment = BoxContainer.ALIGNMENT_CENTER
	details.add_child(_label(str(entry.get("name", "Vô Danh")), 12, GOLD_BRIGHT))
	details.add_child(_label("%s · %s · Lực chiến %s" % [str(entry.get("qi_realm", "Phàm Nhân")), str(entry.get("body_realm", "Bì Nhục Cảnh")), _format_number(int(entry.get("power", 0)))], 10, MUTED))
	line.add_child(details)
	var challenge := _button("CỦA BẠN" if is_current_player else "TỈ THÍ", MUTED if is_current_player else GOLD, 76)
	challenge.disabled = is_current_player
	if not is_current_player:
		challenge.pressed.connect(_challenge_opponent.bind(entry))
	line.add_child(challenge)
	return row

func _prepare_arena_day() -> void:
	var today := Time.get_date_string_from_system()
	if arena_last_day != today:
		arena_last_day = today
		arena_challenges_today = 0

func _challenge_opponent(opponent: Dictionary) -> void:
	if str(opponent.get("name", "")).strip_edges() == current_username:
		_show_notification("Không thể tỉ thí với chính mình", DANGER)
		return
	_prepare_arena_day()
	if arena_challenges_today >= 3:
		_show_notification("Đã hết 3 lượt tỉ thí hôm nay", DANGER)
		return
	arena_challenges_today += 1
	var player_power := int(cultivation["realm_index"]) * 1000 + int(body_cultivation["realm_index"]) * 250
	var opponent_power := int(opponent.get("power", 0))
	var chance := clampf(0.35 + float(player_power - opponent_power) / maxf(1.0, float(opponent_power)) * 0.35, 0.1, 0.9)
	var victory := randf() <= chance
	var reward := 100 + randi_range(0, 400)
	if victory:
		spirit_stones += reward
		_show_notification("Tỉ thí thắng · +%s Linh Thạch" % _format_number(reward), SUCCESS)
	else:
		_show_notification("Tỉ thí thất bại · Hãy tiếp tục tu luyện", DANGER)
	if is_instance_valid(popup_body) and active_center_tab == "BẢNG XẾP HẠNG":
		_render_popup_tab("BẢNG XẾP HẠNG")
	_update_display()

func _build_secret_realm_view() -> Control:
	var view := VBoxContainer.new()
	view.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	view.size_flags_vertical = Control.SIZE_EXPAND_FILL
	view.add_theme_constant_override("separation", 8)
	view.add_child(_label("BÍ CẢNH · 50 THỬ THÁCH", 13, GOLD_BRIGHT))
	view.add_child(_label("Vượt qua để nhận Linh Thạch và vật phẩm. Không cộng tu vi.", 10, MUTED))
	view.add_child(_rule())

	var scroll_frame := PanelContainer.new()
	scroll_frame.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll_frame.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll_frame.custom_minimum_size = Vector2(0, 400)
	scroll_frame.clip_contents = true
	scroll_frame.add_theme_stylebox_override("panel", _style(Color("#071f1a"), 8, Color("#1d5348"), 1))

	var scroll := ScrollContainer.new()
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.custom_minimum_size = Vector2(0, 400)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	scroll.clip_contents = true
	scroll.set_anchors_preset(Control.PRESET_FULL_RECT)
	scroll.offset_left = 8
	scroll.offset_top = 8
	scroll.offset_right = -8
	scroll.offset_bottom = -8
	scroll_frame.add_child(scroll)

	var list := VBoxContainer.new()
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	list.size_flags_vertical = Control.SIZE_EXPAND_FILL
	list.add_theme_constant_override("separation", 7)
	scroll.add_child(list)
	for realm in secret_realm_catalog:
		list.add_child(_secret_realm_row(realm))
	view.add_child(scroll_frame)
	return view

func _secret_realm_row(realm: Dictionary) -> Control:
	var difficulty: int = realm["difficulty"]
	var required_index := _secret_realm_required_progression(difficulty)
	var unlocked: bool = int(cultivation["realm_index"]) >= required_index
	var cleared: bool = int(realm["index"]) in secret_realm_clears
	var row := PanelContainer.new()
	row.custom_minimum_size.y = 66
	row.add_theme_stylebox_override("panel", _style(Color("#102f27") if unlocked else Color("#081914"), 5, GOLD if unlocked else Color("#214536"), 1))
	var line := HBoxContainer.new()
	line.add_theme_constant_override("separation", 9)
	row.add_child(line)
	var number := _label("%02d" % difficulty, 12, GOLD if unlocked else MUTED)
	number.custom_minimum_size.x = 30
	number.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	line.add_child(number)
	var detail := VBoxContainer.new()
	detail.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	detail.alignment = BoxContainer.ALIGNMENT_CENTER
	detail.add_child(_label(realm["name"], 13, GOLD_BRIGHT if unlocked else Color("#506057")))
	var requirement_text := "Mở khóa từ: " + REALMS[required_index]
	var reward_text := "Linh Thạch " + _format_number(realm["stone_min"]) + "-" + _format_number(realm["stone_max"])
	detail.add_child(_label(requirement_text + " · " + reward_text, 10, MUTED))
	line.add_child(detail)
	var action := _button("ĐÃ VƯỢT" if cleared else ("THÁM HIỂM" if unlocked else "KHÓA"), SUCCESS if cleared else GOLD, 94)
	action.disabled = not unlocked or cleared
	if unlocked and not cleared:
		action.pressed.connect(_explore_secret_realm.bind(int(realm["index"])))
	line.add_child(action)
	return row

func _secret_realm_required_progression(difficulty: int) -> int:
	return clampi((difficulty - 1) * 40, 0, progression_ladder.size() - 1)

func _explore_secret_realm(realm_index: int) -> void:
	explore_secret_realm(realm_index)

func _build_codex_view() -> Control:
	var view := VBoxContainer.new()
	view.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	view.size_flags_vertical = Control.SIZE_EXPAND_FILL
	view.clip_contents = true
	var heading := HBoxContainer.new()
	heading.add_child(_label("ĐỒ GIÁM · VẠN VẬT SƯU TẦM", 13, GOLD_BRIGHT))
	var collected := _label(str(codex_unlocked_ids.size()) + " / " + str(CODEX_ENTRIES.size()) + " đã thu thập", 11, MUTED)
	collected.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	collected.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	heading.add_child(collected)
	view.add_child(heading)
	view.add_child(_rule())
	var scroll := ScrollContainer.new()
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.clip_contents = true
	view.add_child(scroll)
	var catalog := VBoxContainer.new()
	catalog.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	catalog.add_theme_constant_override("separation", 9)
	scroll.add_child(catalog)
	for category in ["PHÁP BẢO & THẦN BINH", "LINH THÚ & TỌA KIẾM", "ĐAN DƯỢC THIÊN TÀI ĐỊA BẢO", "NGOẠI TRANG / SKIN"]:
		catalog.add_child(_label(category, 11, GOLD))
		var grid := GridContainer.new()
		grid.columns = 2
		grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		for entry in CODEX_ENTRIES:
			if entry["category"] == category:
				grid.add_child(_codex_card(entry))
		catalog.add_child(grid)
	catalog.add_child(_build_item_codex_section())
	catalog.add_child(_rule())
	catalog.add_child(_label("LỘ TRÌNH PHI THĂNG · 120 ĐẠI CẢNH GIỚI · 4.800 CẤP", 11, GOLD))
	catalog.add_child(_label("Cảnh giới đã đạt sáng rõ; cảnh giới phía trước được phong ấn để theo dõi mục tiêu.", 10, MUTED))
	for major_entry in major_realm_catalog:
		catalog.add_child(_codex_major_realm(major_entry))
	return view

func _build_item_codex_section() -> Control:
	var section := VBoxContainer.new()
	section.add_theme_constant_override("separation", 6)
	var title := _label("KHO VẠN VẬT · " + str(item_catalog.size()) + " VẬT PHẨM", 11, GOLD)
	section.add_child(title)
	section.add_child(_label("Đủ bộ sưu tầm bằng đả tọa, rèn thể, đánh quái và mở hộp quà; không yêu cầu nạp.", 10, MUTED))
	item_codex_grid = GridContainer.new()
	item_codex_grid.columns = 2
	item_codex_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	section.add_child(item_codex_grid)
	var navigation := HBoxContainer.new()
	navigation.alignment = BoxContainer.ALIGNMENT_CENTER
	var previous := _button("‹", MUTED, 34)
	previous.pressed.connect(_change_item_codex_page.bind(-1))
	navigation.add_child(previous)
	item_codex_page_label = _label("", 11, GOLD_BRIGHT)
	item_codex_page_label.custom_minimum_size.x = 100
	item_codex_page_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	navigation.add_child(item_codex_page_label)
	var next := _button("›", GOLD, 34)
	next.pressed.connect(_change_item_codex_page.bind(1))
	navigation.add_child(next)
	section.add_child(navigation)
	_refresh_item_codex_grid()
	return section

func _refresh_item_codex_grid() -> void:
	if not is_instance_valid(item_codex_grid):
		return
	for child in item_codex_grid.get_children():
		child.queue_free()
	var page_count := maxi(1, ceili(float(item_catalog.size()) / ITEM_PAGE_SIZE))
	item_codex_page = clampi(item_codex_page, 0, page_count - 1)
	var start_index := item_codex_page * ITEM_PAGE_SIZE
	var end_index := mini(start_index + ITEM_PAGE_SIZE, item_catalog.size())
	for index in range(start_index, end_index):
		item_codex_grid.add_child(_item_codex_card(item_catalog[index]))
	if is_instance_valid(item_codex_page_label):
		item_codex_page_label.text = str(item_codex_page + 1) + " / " + str(page_count)

func _change_item_codex_page(step: int) -> void:
	var page_count := maxi(1, ceili(float(item_catalog.size()) / ITEM_PAGE_SIZE))
	item_codex_page = clampi(item_codex_page + step, 0, page_count - 1)
	_refresh_item_codex_grid()

func _item_codex_card(item: Dictionary) -> Button:
	var owned: bool = item["id"] in owned_item_ids or item["id"] in codex_unlocked_ids
	var rarity_color: Color = ITEM_RARITY_COLORS[item["rarity_index"]]
	var card := Button.new()
	card.custom_minimum_size = Vector2(175, 70)
	card.alignment = HORIZONTAL_ALIGNMENT_LEFT
	card.add_theme_font_size_override("font_size", 10)
	card.add_theme_color_override("font_color", rarity_color if owned else Color("#506057"))
	card.add_theme_color_override("font_hover_color", TEXT if owned else MUTED)
	card.text = item["icon"] + "  " + item["name"] + "\n" + item["rarity"] + " · " + ("Sở hữu x" + str(item_inventory.get(item["id"], 1)) if owned else "???") if owned else "?  ???\n" + item["category"]
	card.tooltip_text = item["details"] + "\nNguồn: " + item["source"] if owned else "Chưa thu thập · Nguồn: " + item["source"]
	card.add_theme_stylebox_override("normal", _style(Color("#102f27") if owned else Color("#081914"), 5, rarity_color if owned else Color("#214536"), 1))
	card.add_theme_stylebox_override("hover", _style(Color("#1b493b"), 5, rarity_color, 1))
	card.pressed.connect(_show_item_detail.bind(item, owned))
	return card

func _show_item_detail(item: Dictionary, owned: bool) -> void:
	if owned:
		_show_notification(item["name"] + " · " + item["rarity"] + " · " + item["details"], ITEM_RARITY_COLORS[item["rarity_index"]])
	else:
		_show_notification("??? · Chưa thu thập · Nguồn: " + item["source"], MUTED)

func _codex_major_realm(major_entry: Dictionary) -> Control:
	var major_panel := PanelContainer.new()
	major_panel.add_theme_stylebox_override("panel", _style(Color("#0b2922"), 5, Color("#28624e"), 1))
	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 3)
	major_panel.add_child(content)
	var major_title := _label("Đại cảnh giới " + str(major_entry["index"] + 1) + " · " + major_entry["name"], 12, GOLD_BRIGHT)
	content.add_child(major_title)
	var current_index: int = int(cultivation.get("realm_index", 0))
	for phase in major_entry["phases"]:
		var phase_row := HBoxContainer.new()
		phase_row.add_theme_constant_override("separation", 3)
		var phase_title := _label(str(phase["name"]), 10, MUTED)
		phase_title.custom_minimum_size.x = 70
		phase_row.add_child(phase_title)
		var layer_summary := RichTextLabel.new()
		layer_summary.bbcode_enabled = true
		layer_summary.fit_content = true
		layer_summary.scroll_active = false
		layer_summary.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var tooltip_lines: Array[String] = []
		for level in phase["levels"]:
			var reached: bool = int(level["index"]) <= current_index
			var marker_color := "#83c58d" if reached else "#42665a"
			layer_summary.append_text("[color=" + marker_color + "]●[/color] ")
			tooltip_lines.append(str(level["name"]) + " · " + ("Đã đạt" if reached else "Chưa đạt"))
		layer_summary.tooltip_text = "\n".join(tooltip_lines)
		phase_row.add_child(layer_summary)
		content.add_child(phase_row)
	return major_panel

func _codex_card(entry: Dictionary) -> Button:
	var unlocked: bool = entry["id"] in codex_unlocked_ids
	var card := Button.new()
	card.custom_minimum_size = Vector2(145, 82)
	card.alignment = HORIZONTAL_ALIGNMENT_LEFT
	card.text = (entry["icon"] + "  " + entry["name"] + "\n" + entry["grade"] + " phẩm · " + ("Đã thu thập" if unlocked else "Chưa thu thập")) if unlocked else "?\nChưa thu thập"
	card.tooltip_text = entry["details"] if unlocked else "Thu thập vật phẩm này để mở khóa thông tin"
	card.add_theme_font_size_override("font_size", 11 if unlocked else 13)
	card.add_theme_color_override("font_color", GOLD_BRIGHT if unlocked else MUTED)
	card.add_theme_color_override("font_hover_color", TEXT if unlocked else GOLD)
	card.add_theme_stylebox_override("normal", _style(Color("#102f27") if unlocked else Color("#081914"), 5, GOLD if unlocked else Color("#214536"), 1))
	card.add_theme_stylebox_override("hover", _style(Color("#1b493b"), 5, GOLD_BRIGHT, 1))
	card.pressed.connect(_show_codex_detail.bind(entry, unlocked))
	return card

func _show_codex_detail(entry: Dictionary, unlocked: bool) -> void:
	if unlocked:
		_show_notification(entry["name"] + " · " + entry["grade"] + " phẩm · " + entry["details"], SUCCESS)
	else:
		_show_notification("Chưa thu thập: " + entry["name"], MUTED)

func _center_view(title: String) -> VBoxContainer:
	var view := VBoxContainer.new()
	view.size_flags_vertical = Control.SIZE_EXPAND_FILL
	view.add_child(_label(title, 13, GOLD_BRIGHT))
	view.add_child(_rule())
	return view

func _calculate_qi_speed_for_realm(realm_index: int) -> float:
	var index := maxi(realm_index, 0)
	var breakthrough_multiplier: float = 1.0 + maxf(0.0, float(index) * 0.70)
	var stage_multiplier: float = 10.0 + clampf(float(index) * 0.80, 0.0, 5.0)
	var high_realm_bonus: float = 1.0 + floor(float(index) / 8.0) * 0.75
	return snappedf(1.0 * breakthrough_multiplier * stage_multiplier * high_realm_bonus, 0.1)

func _calculate_body_speed_for_realm(realm_index: int) -> float:
	var index := maxi(realm_index, 0)
	var breakthrough_multiplier: float = 1.0 + maxf(0.0, float(index) * 0.75)
	var stage_multiplier: float = 10.0 + clampf(float(index) * 0.90, 0.0, 5.0)
	var body_bonus: float = 1.0 + floor(float(index) / 6.0) * 0.60
	return snappedf(1.0 * breakthrough_multiplier * stage_multiplier * body_bonus, 0.1)

func _recalculate_cultivation_rates() -> void:
	var qi_speed := _calculate_qi_speed_for_realm(int(cultivation.get("realm_index", 0)))
	var body_speed := _calculate_body_speed_for_realm(int(body_cultivation.get("realm_index", 0)))
	var formation_multiplier := 1.25 if formation_active else 1.0
	cultivation["spirit_per_second"] = snappedf(qi_speed * formation_multiplier, 0.1)
	body_cultivation["blood_per_second"] = snappedf(body_speed * formation_multiplier, 0.1)

func _toggle_formation(state: Label, button: Button) -> void:
	formation_active = not formation_active
	_recalculate_cultivation_rates()
	if formation_active:
		state.text = "Trận kỳ đang hoạt động · Hấp thu +25%"
		state.add_theme_color_override("font_color", SUCCESS)
		button.text = "TẮT TRẬN PHÁP"
	else:
		state.text = "Trận kỳ đang nghỉ · Tăng 25% tốc độ hấp thu khi kích hoạt"
		state.add_theme_color_override("font_color", MUTED)
		button.text = "KÍCH HOẠT CỜ TRẬN"

func _build_elixir_panel() -> Control:
	var panel := _panel(340)
	var content := panel.get_child(0).get_child(0) as VBoxContainer
	content.add_child(_label("ĐAN DƯỢC", 25, GOLD_BRIGHT))
	content.add_child(_label("Linh đan tùy thân · 01 / 24", 11, MUTED))
	content.add_child(_rule())
	elixir_list = VBoxContainer.new()
	elixir_list.size_flags_vertical = Control.SIZE_EXPAND_FILL
	elixir_list.add_theme_constant_override("separation", 9)
	content.add_child(elixir_list)
	for elixir in elixirs:
		_add_elixir_row(elixir)
	var pages := HBoxContainer.new()
	pages.alignment = BoxContainer.ALIGNMENT_CENTER
	var previous := _button("‹", MUTED, 34)
	previous.pressed.connect(func(): _show_notification("Đã ở trang đầu tiên"))
	pages.add_child(previous)
	var page := _label("  1 / 6  ", 13, GOLD_BRIGHT)
	page.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	page.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	pages.add_child(page)
	var next := _button("›", GOLD, 34)
	next.pressed.connect(func(): _show_notification("Đan dược quý hiếm đang được phong ấn"))
	pages.add_child(next)
	content.add_child(pages)
	return panel

func _add_elixir_row(elixir: Dictionary) -> void:
	var row := PanelContainer.new()
	row.custom_minimum_size.y = 82
	row.add_theme_stylebox_override("panel", _style(Color("#0b2922"), 5, Color("#28624e"), 1))
	var layout := HBoxContainer.new()
	layout.add_theme_constant_override("separation", 10)
	row.add_child(layout)
	var icon := _label("✧", 25, GOLD)
	icon.custom_minimum_size.x = 38
	icon.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	layout.add_child(icon)
	var details := VBoxContainer.new()
	details.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	details.alignment = BoxContainer.ALIGNMENT_CENTER
	details.add_child(_label(elixir["name"], 13, GOLD_BRIGHT))
	var description := _label(elixir["description"], 10, MUTED)
	description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	details.add_child(description)
	layout.add_child(details)
	var count := _label("x" + str(elixir["count"]), 12, TEXT)
	count.custom_minimum_size.x = 28
	count.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	layout.add_child(count)
	var use := _button("SỬ DỤNG", GOLD, 78)
	use.pressed.connect(_use_elixir.bind(elixir, count, use))
	layout.add_child(use)
	elixir_list.add_child(row)

func _panel(width: float) -> PanelContainer:
	var panel := PanelContainer.new()
	if width > 0:
		panel.custom_minimum_size.x = width
		panel.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	panel.add_theme_stylebox_override("panel", _style(JADE_PANEL, 8, Color("#9b783d"), 1))
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_top", 16)
	margin.add_theme_constant_override("margin_right", 16)
	margin.add_theme_constant_override("margin_bottom", 14)
	panel.add_child(margin)
	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 8)
	margin.add_child(content)
	return panel

func _section_tabs(names: Array, callback: Callable) -> Control:
	var scroll := ScrollContainer.new()
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.custom_minimum_size.y = 36
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.clip_contents = true
	var tabs := HBoxContainer.new()
	tabs.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	tabs.add_theme_constant_override("separation", 4)
	for tab_name in names:
		var tab := _button(tab_name, GOLD if tab_name == names[0] else MUTED, -1)
		tab.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		tab.add_theme_font_size_override("font_size", 10)
		tab.pressed.connect(callback.bind(tab_name))
		tabs.add_child(tab)
	scroll.add_child(tabs)
	return scroll

func _material_row(material_name: String) -> Control:
	var row := HBoxContainer.new()
	var name_label := _label(material_name, 12, TEXT)
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(name_label)
	var values: Array = materials[material_name]
	var material_text := str(values[0]) + " / " + str(values[1])
	if values[1] == 0:
		material_text = "Kho: " + str(values[0])
	var value_label := _label(material_text, 11, SUCCESS if values[1] == 0 or values[0] >= values[1] else MUTED)
	material_value_labels[material_name] = value_label
	row.add_child(value_label)
	return row

func _label(text: String, size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", maxi(size, 11))
	label.add_theme_color_override("font_color", color)
	return label

func _button(text: String, color: Color, width: float) -> Button:
	var button := Button.new()
	button.text = text
	if width > 0:
		button.custom_minimum_size.x = width
	button.custom_minimum_size.y = 44
	button.add_theme_font_size_override("font_size", 12)
	button.add_theme_color_override("font_color", color)
	button.add_theme_color_override("font_hover_color", GOLD_BRIGHT)
	button.add_theme_stylebox_override("normal", _style(Color("#102f27"), 4, Color("#80632f"), 1))
	button.add_theme_stylebox_override("hover", _style(Color("#1b493b"), 4, GOLD, 1))
	button.add_theme_stylebox_override("pressed", _style(Color("#071f1a"), 4, GOLD_BRIGHT, 1))
	return button

func _style(color: Color, radius: int, border: Color, border_width: int = 0) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.border_color = border
	style.set_border_width_all(border_width)
	style.set_corner_radius_all(radius)
	return style

func _rule() -> HSeparator:
	var rule := HSeparator.new()
	rule.add_theme_constant_override("separation", 12)
	rule.add_theme_color_override("separator", Color("#376c55"))
	return rule

func _update_display() -> void:
	if not is_instance_valid(realm_label):
		return
	if cultivation["body_mode"]:
		_update_body_display()
	else:
		_update_qi_display()

func _update_qi_display() -> void:
	var current := cultivation["cultivation"] as float
	var needed := cultivation["cultivation_need"] as float
	materials["Linh Khí"] = [int(current), int(needed)]
	left_title_label.text = "CẢNH GIỚI LUYỆN KHÍ"
	left_subtitle_mat_label.text = "ĐIỀU KIỆN ĐỘT PHÁ"
	left_energy_title_label.text = "LINH KHÍ TÍCH LŨY"
	left_collect_button.text = "NHẬN LINH KHÍ"
	left_action_button.text = "✦  ĐỘT PHÁ"
	spirit_label.text = _format_number(cultivation["spirit"]) + "  /  +" + _format_number(cultivation["spirit_per_second"]) + "/s"
	for material_row in left_material_rows:
		material_row.visible = true
	for material_name in material_value_labels:
		var values: Array = materials[material_name]
		var material_text := str(values[0]) + " / " + str(values[1])
		if values[1] == 0:
			material_text = "Kho: " + str(values[0])
		material_value_labels[material_name].text = material_text
		material_value_labels[material_name].add_theme_color_override("font_color", SUCCESS if values[1] == 0 or values[0] >= values[1] else MUTED)
	left_bar.value = minf(current / needed * 100.0, 100.0)
	left_realm_label.text = cultivation["realm_name"]
	left_value_label.text = _format_number(current) + "  /  " + _format_number(needed)
	status_label.text = "Đã đủ Linh Khí để đột phá" if current >= needed else "Đang tích lũy Linh Khí..."
	status_label.add_theme_color_override("font_color", SUCCESS if current >= needed else MUTED)
	if cultivation["backlash_seconds"] > 0.0:
		backlash_label.text = "Phản phệ: hấp thu giảm 50% · " + str(ceili(cultivation["backlash_seconds"])) + " giây"
	else:
		backlash_label.text = ""
	left_status_label.text = status_label.text
	left_status_label.add_theme_color_override("font_color", status_label.get_theme_color("font_color"))
	left_action_button.disabled = current < needed

func _update_body_display() -> void:
	var current := body_cultivation["power"] as float
	var needed := body_cultivation["power_need"] as float
	left_title_label.text = "CẢNH GIỚI LUYỆN THỂ"
	left_realm_label.text = body_cultivation["realm_name"]
	left_bar.value = minf(current / needed * 100.0, 100.0)
	left_value_label.text = "Thể phách: " + _format_number(current) + "  /  " + _format_number(needed)
	left_subtitle_mat_label.text = "CHỈ SỐ THỂ PHÁCH"
	left_energy_title_label.text = "KHÍ HUYẾT"
	left_status_label.text = "Đủ lực lượng để đột phá" if current >= needed else "Đang tôi luyện thân thể..."
	left_status_label.add_theme_color_override("font_color", SUCCESS if current >= needed else MUTED)
	left_collect_button.text = "RÈN THỂ"
	left_action_button.text = "✦  ĐỘT PHÁ LƯỢNG THỂ"
	left_action_button.disabled = current < needed
	spirit_label.text = "Khí huyết: " + _format_number(body_cultivation["blood"]) + "  /  +" + _format_number(body_cultivation["blood_per_second"]) + "/s"
	for material_row in left_material_rows:
		material_row.visible = false
	backlash_label.text = "Độ cứng cốt: " + _format_number(body_cultivation["power"] * 0.5)

func _format_number(value: float) -> String:
	var raw := str(int(value))
	var formatted := ""
	while raw.length() > 3:
		formatted = "." + raw.substr(raw.length() - 3) + formatted
		raw = raw.substr(0, raw.length() - 3)
	return raw + formatted

func _collect_spirit() -> void:
	var collected := 5.0 * absorb_bonus
	cultivation["spirit"] += collected
	cultivation["cultivation"] += collected
	_show_notification("Đã nhận " + _format_number(collected) + " Linh Khí")

func _collect_current_energy() -> void:
	if cultivation["body_mode"]:
		var trained_power := 5.0
		body_cultivation["blood"] += trained_power
		body_cultivation["power"] += trained_power
		_show_notification("Đã rèn thể, khí huyết tăng " + _format_number(trained_power), SUCCESS)
	else:
		_collect_spirit()

func _attempt_breakthrough() -> void:
	if cultivation["cultivation"] < cultivation["cultivation_need"]:
		_show_notification("Tu vi hoặc tài nguyên chưa đủ", DANGER)
		return
	var realm_index: int = cultivation["realm_index"]
	var success_chance := _breakthrough_chance(realm_index)
	if randf() <= success_chance:
		if realm_index < progression_ladder.size() - 1:
			var next_index := realm_index + 1
			var next_level: Dictionary = progression_ladder[next_index]
			cultivation["realm_index"] = next_index
			cultivation["realm_name"] = next_level["name"]
			cultivation["cultivation"] = 0.0
			cultivation["cultivation_need"] = next_level["cultivation_need"]
			_recalculate_cultivation_rates()
			_show_notification("Đột phá thành công! Đã đạt " + next_level["name"] + " · Tốc độ tu luyện tăng " + str(_format_number(cultivation["spirit_per_second"])) + "/s", SUCCESS)
		else:
			_show_notification("Đã chạm đỉnh hệ thống tu vi hiện tại", SUCCESS)
	else:
		var loss_ratio := randf_range(0.20, 0.35)
		cultivation["cultivation"] *= 1.0 - loss_ratio
		cultivation["backlash_seconds"] = 30.0
		_show_notification("Đột phá thất bại, mất " + str(roundi(loss_ratio * 100.0)) + "% tu vi. Phản phệ giáng lâm.", DANGER)
	_update_display()

func _attempt_current_breakthrough() -> void:
	if cultivation["body_mode"]:
		_attempt_body_breakthrough()
	else:
		_attempt_breakthrough()

func _attempt_body_breakthrough() -> void:
	var current := body_cultivation["power"] as float
	var needed := body_cultivation["power_need"] as float
	if current < needed:
		_show_notification("Thể phách chưa đủ để đột phá", DANGER)
		return
	var realm_index: int = body_cultivation["realm_index"]
	var success_chance := clampf(0.72 - float(realm_index) * 0.06, 0.32, 0.72)
	if randf() <= success_chance:
		if realm_index < BODY_REALMS.size() - 1:
			var next_index := realm_index + 1
			body_cultivation["realm_index"] = next_index
			body_cultivation["realm_name"] = BODY_REALMS[next_index]
			body_cultivation["power"] = 0.0
			body_cultivation["power_need"] = snappedf(needed * minf(2.0 + float(next_index) * 0.08, 2.5), 1.0)
			_recalculate_cultivation_rates()
			_show_notification("Lượng thể đột phá thành công: " + BODY_REALMS[next_index] + " · Tốc độ rèn thể tăng " + str(_format_number(body_cultivation["blood_per_second"])) + "/s", SUCCESS)
		else:
			_show_notification("Thân thể đã đạt Kim Cương Thể", SUCCESS)
	else:
		var loss_ratio := randf_range(0.20, 0.35)
		body_cultivation["power"] *= 1.0 - loss_ratio
		body_cultivation["blood"] *= 0.85
		_show_notification("Luyện thể thất bại, mất " + str(roundi(loss_ratio * 100.0)) + "% thể phách và khí huyết.", DANGER)
	_update_display()

func _breakthrough_chance(realm_index: int) -> float:
	return clampf(0.68 - float(realm_index) * 0.02 + breakthrough_bonus, 0.20, 0.70)

func _next_cultivation_need(previous_need: float, next_index: int) -> float:
	var multiplier := minf(2.0 + float(next_index) * 0.025, 2.5)
	return snappedf(previous_need * multiplier, 1.0)

func _use_elixir(elixir: Dictionary, count_label: Label, button: Button) -> void:
	if elixir["count"] <= 0:
		_show_notification("Đan dược đã dùng hết", DANGER)
		return
	elixir["count"] -= 1
	var elixir_id: String = elixir.get("id", "")
	_register_codex_unlock(elixir_id)
	if elixir_id != "":
		item_inventory[elixir_id] = elixir["count"]
	count_label.text = "x" + str(elixir["count"])
	button.disabled = elixir["count"] == 0
	match elixir["effect"]:
		"absorb":
			absorb_bonus += 0.08
			_show_notification("Chân Nguyên Đan phát huy: hấp thu +8%", SUCCESS)
		"breakthrough":
			breakthrough_bonus += 0.12
			_show_notification("Trúc Cơ Đan phát huy: đột phá +12%", SUCCESS)
		"spirit":
			cultivation["spirit"] += 10000000.0
			_show_notification("Linh khí dâng trào: +10.000.000", SUCCESS)
		"shield":
			_show_notification("Huyền Ngọc bảo hộ đã sẵn sàng", SUCCESS)

func _register_codex_unlock(entry_id: String) -> void:
	if entry_id != "" and entry_id not in codex_unlocked_ids:
		codex_unlocked_ids.append(entry_id)

func _on_cultivation_tab(tab_name: String) -> void:
	cultivation["body_mode"] = tab_name == "LUYỆN THỂ"
	if is_instance_valid(center_content) and active_center_tab == "TU LUYỆN":
		_render_center_tab("TU LUYỆN")
	_update_display()
	_show_notification("Đã chuyển sang " + tab_name)

func _on_center_tab(tab_name: String) -> void:
	if not is_instance_valid(center_content):
		return
	if tab_name == "TU LUYỆN":
		_close_center_popup()
		_render_center_tab("TU LUYỆN")
	else:
		_open_center_popup(tab_name)
	_show_notification("Đã mở tab " + tab_name)

func _open_center_popup(tab_name: String) -> void:
	if not is_instance_valid(popup_overlay) or not is_instance_valid(popup_body):
		return
	active_center_tab = tab_name
	popup_title.text = tab_name
	_render_popup_tab(tab_name)
	popup_overlay.visible = true

func _render_popup_tab(tab_name: String) -> void:
	if not is_instance_valid(popup_body):
		return
	for child in popup_body.get_children():
		child.queue_free()
	var view: Control
	match tab_name:
		"QUANG HOÀN":
			view = _build_aura_view()
		"TRẬN PHÁP":
			view = _build_formation_view()
		"NHÂN VẬT":
			view = _build_character_view()
		"ĐỒ GIÁM":
			view = _build_codex_view()
		"TÚI ĐỒ":
			view = _build_inventory_view()
		"BÍ CẢNH":
			view = _build_secret_realm_view()
		"BẢNG XẾP HẠNG":
			view = _build_leaderboard_view()
		_:
			view = _build_training_view()
	view.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	view.size_flags_vertical = Control.SIZE_EXPAND_FILL
	view.clip_contents = true
	popup_body.add_child(view)

func _close_center_popup() -> void:
	if is_instance_valid(popup_overlay):
		popup_overlay.visible = false
	active_center_tab = "TU LUYỆN"

func _on_popup_dimmer_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_close_center_popup()

func _show_notification(message: String, color: Color = GOLD_BRIGHT) -> void:
	if is_instance_valid(notification_label):
		notification_label.queue_free()
	notification_label = _label(message, 13, color)
	notification_label.custom_minimum_size = Vector2(520, 0)
	notification_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	notification_label.set_anchors_preset(Control.PRESET_CENTER_TOP)
	notification_label.position.y = 90
	notification_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(notification_label)
	await get_tree().create_timer(2.2).timeout
	if is_instance_valid(notification_label):
		notification_label.queue_free()

func _cloud_headers() -> PackedStringArray:
	return PackedStringArray(["Content-Type: application/json", "X-Master-Key: " + JSONBIN_API_KEY, "X-Bin-Private: false"])

func fetch_leaderboard_from_cloud() -> void:
	if auth_request_action != "" or cloud_request_kind != "":
		pending_leaderboard_fetch = true
		leaderboard_loading = true
		if is_instance_valid(leaderboard_status_label):
			leaderboard_status_label.text = "Đang chờ đồng bộ tài khoản..."
		return
	leaderboard_entries.clear()
	leaderboard_loaded = false
	if AUTH_BIN_ID.is_empty():
		leaderboard_loading = false
		if is_instance_valid(leaderboard_status_label):
			leaderboard_status_label.text = "Chưa cấu hình máy chủ"
		_show_notification("Chưa cấu hình AUTH_BIN_ID cho BXH online", DANGER)
		return
	auth_request_action = "leaderboard_lookup"
	leaderboard_loading = true
	if is_instance_valid(leaderboard_status_label):
		leaderboard_status_label.text = "Đang đồng bộ..."
	var error := http_request.request(JSONBIN_URL % AUTH_BIN_ID + "/latest", _cloud_headers(), HTTPClient.METHOD_GET)
	if error != OK:
		auth_request_action = ""
		leaderboard_loading = false
		_show_notification("Không thể tải BXH online", DANGER)

func save_game_to_cloud() -> void:
	if not is_authenticated:
		return
	autosave_elapsed = 0.0
	cloud_status_label.text = "●  Đang lưu..."
	if auth_request_action != "" or cloud_request_kind != "":
		cloud_status_label.text = "●  Đang chờ đồng bộ hiện tại..."
		return
	_sync_current_account_profile()
	if auth_request_action == "":
		cloud_status_label.text = "●  Lưu cục bộ"
	else:
		cloud_status_label.text = "●  Đang đồng bộ tài khoản..."

func load_game_from_cloud() -> void:
	if not is_authenticated:
		return
	_hydrate_state_from_account(authenticated_account)
	cloud_status_label.text = "●  Đã nạp tiến trình tài khoản"

func _on_cloud_request_completed(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	if auth_request_action != "":
		_handle_auth_request_completed(result, response_code, body)
		return
	var completed_request := cloud_request_kind
	cloud_request_kind = ""
	if result != HTTPRequest.RESULT_SUCCESS or response_code < 200 or response_code >= 300:
		cloud_status_label.text = "●  Ngoại tuyến"
		if (completed_request == "load" or completed_request == "save") and is_authenticated:
			if completed_request == "load" and not authenticated_account.is_empty():
				_hydrate_state_from_account(authenticated_account)
			_sync_current_account_profile()
		_fetch_pending_leaderboard()
		return
	var parsed = JSON.parse_string(body.get_string_from_utf8())
	if parsed is Dictionary and parsed.has("record"):
		var record: Dictionary = parsed["record"]
		var saved_version := int(record.get("schema_version", 0))
		if saved_version < 2 or saved_version > STATE_VERSION:
			cloud_status_label.text = "●  Bản lưu cũ bị bỏ qua"
			_show_notification("Bản lưu cũ không tương thích, giữ trạng thái sạch", DANGER)
			return
		if record.has("cultivation"):
			var saved_username := str(record.get("account_username", ""))
			if saved_username != "" and saved_username != current_username:
				cloud_status_label.text = "●  Bản lưu khác tài khoản"
				_show_notification("Bản lưu thuộc tài khoản khác, giữ trạng thái hiện tại", DANGER)
				return
			cultivation = record["cultivation"]
		_normalize_progression_state()
		if record.has("body_cultivation"):
			body_cultivation = record["body_cultivation"]
		if record.has("inventory"):
			inventory = record["inventory"]
			elixirs = inventory.get("elixirs", [])
			_rebuild_elixir_list()
		codex_unlocked_ids = record.get("codex_unlocked_ids", ["elixir_tu_khi_pham"])
		owned_item_ids = record.get("owned_item_ids", codex_unlocked_ids)
		item_inventory = record.get("item_inventory", {"elixir_tu_khi_pham": 1})
		spirit_stones = int(record.get("spirit_stones", 0))
		secret_realm_clears = record.get("secret_realm_clears", [])
		arena_challenges_today = int(record.get("arena_challenges_today", 0))
		arena_last_day = str(record.get("arena_last_day", ""))
		_prepare_arena_day()
		_update_display()
	cloud_status_label.text = "●  Đã đồng bộ"
	if completed_request == "save" or completed_request == "load":
		if completed_request == "load" and not authenticated_account.is_empty():
			_hydrate_state_from_account(authenticated_account)
		_sync_current_account_profile()
	if completed_request == "load":
		_fetch_pending_leaderboard()

func _current_leaderboard_profile() -> Dictionary:
	var calculated_power := _base_combat_power() + _equipment_power()
	combat_power = maxi(combat_power, calculated_power)
	return {
		"name": current_username,
		"qi_realm": str(cultivation.get("realm_name", "Phàm Nhân")),
		"body_realm": str(body_cultivation.get("realm_name", "Bì Nhục Cảnh")),
		"power": combat_power,
		"tu_vi": int(cultivation.get("cultivation", 0.0)),
		"linh_thach": spirit_stones,
		"luc_chien": combat_power,
		"equipment": equipment.duplicate(true),
		"item_inventory": item_inventory.duplicate(true),
		"owned_item_ids": owned_item_ids.duplicate(),
		"title": "Đạo Hữu"
	}

func _leaderboard_profile_from_user(user: Dictionary) -> Dictionary:
	var name := str(user.get("username", ""))
	if name.is_empty():
		return {}
	return {
		"name": name,
		"qi_realm": str(user.get("realm", user.get("qi_realm", "Luyện Khí Kỳ"))),
		"body_realm": str(user.get("body_realm", "Bì Nhục Cảnh")),
		"power": int(user.get("luc_chien", user.get("power", 0))),
		"stones": int(user.get("linh_thach", 0)),
		"title": str(user.get("title", "Đạo Hữu"))
	}

func _auth_password_matches(user: Dictionary, password: String) -> bool:
	if user.has("password_hash"):
		return str(user.get("password_hash", "")).strip_edges().to_lower() == _password_hash(password)
	return str(user.get("password", "")).strip_edges() == password.strip_edges()

func _password_hash(password: String) -> String:
	return password.strip_edges().sha256_text()

func _extract_users_from_json(parsed: Variant) -> Array:
	var source: Variant = parsed
	if parsed is Dictionary and parsed.has("record"):
		source = parsed["record"]
	if source is Dictionary and source.has("can_khon_data"):
		source = source["can_khon_data"]
	if source is Dictionary:
		var users_value: Variant = source.get("users", source.get("accounts", []))
		if users_value is Array:
			return users_value
		if source.has("username"):
			return [source]
		return []
	if source is Array:
		return source
	return []

func _sync_current_account_profile() -> void:
	if not is_authenticated or AUTH_BIN_ID.is_empty() or current_username.is_empty() or auth_request_action != "" or cloud_request_kind != "":
		return
	auth_request_action = "profile_lookup"
	var error := http_request.request(JSONBIN_URL % AUTH_BIN_ID + "/latest", _cloud_headers(), HTTPClient.METHOD_GET)
	if error != OK:
		auth_request_action = ""

func _fetch_pending_leaderboard() -> void:
	if not pending_leaderboard_fetch:
		return
	pending_leaderboard_fetch = false
	fetch_leaderboard_from_cloud()

func _auth_registry_with_profile(users: Array) -> String:
	return JSON.stringify({"users": _normalized_users_for_cloud(users)})

func _handle_auth_request_completed(result: int, response_code: int, body: PackedByteArray) -> void:
	var action := auth_request_action
	if action == "register_write":
		auth_request_action = ""
		auth_submit_button.disabled = false
		if result == HTTPRequest.RESULT_SUCCESS and response_code >= 200 and response_code < 300:
			_finish_authentication(pending_auth_username)
		else:
			auth_error_label.text = "Không thể lưu tài khoản lên JSONBin."
		return
	if action == "profile_write":
		auth_request_action = ""
		return

	if result != HTTPRequest.RESULT_SUCCESS or response_code < 200 or response_code >= 300:
		auth_request_action = ""
		if action == "profile_lookup":
			return
		if action == "leaderboard_lookup":
			leaderboard_loading = false
			leaderboard_entries.clear()
			if is_instance_valid(leaderboard_status_label):
				leaderboard_status_label.text = "Chưa có dữ liệu"
			if active_center_tab == "BẢNG XẾP HẠNG":
				_render_popup_tab("BẢNG XẾP HẠNG")
			return
		auth_submit_button.disabled = false
		auth_error_label.text = "Không thể đọc dữ liệu tài khoản từ JSONBin."
		return

	var parsed = JSON.parse_string(body.get_string_from_utf8())
	var users: Array = _extract_users_from_json(parsed)

	if action == "leaderboard_lookup":
		auth_request_action = ""
		leaderboard_loading = false
		leaderboard_entries.clear()
		for user in users:
			if user is Dictionary:
				var profile: Dictionary = _leaderboard_profile_from_user(user)
				if not profile.is_empty():
					leaderboard_entries.append(profile)
		var current_profile := _current_leaderboard_profile()
		var has_current_profile := false
		for entry in leaderboard_entries:
			if str(entry.get("name", "")).strip_edges() == current_username.strip_edges():
				has_current_profile = true
				break
		if not has_current_profile and not current_profile.get("name", "").is_empty():
			leaderboard_entries.append(current_profile)
		leaderboard_entries.sort_custom(func(left: Dictionary, right: Dictionary): return int(left.get("power", 0)) > int(right.get("power", 0)))
		leaderboard_loaded = true
		if is_instance_valid(leaderboard_status_label):
			leaderboard_status_label.text = "Đã đồng bộ JSONBin"
		if active_center_tab == "BẢNG XẾP HẠNG":
			_render_popup_tab("BẢNG XẾP HẠNG")
		return

	var username := pending_auth_username if not pending_auth_username.is_empty() else auth_username_input.text.strip_edges()
	var password := pending_auth_password if not pending_auth_password.is_empty() else auth_password_input.text.strip_edges()
	var found_user: Dictionary = {}
	for user in users:
		if user is Dictionary and str(user.get("username", "")).strip_edges() == username:
			if action == "login_lookup" and _auth_password_matches(user, password):
				found_user = user
				break
			if action != "login_lookup":
				found_user = user
				break

	if action == "login_lookup":
		auth_request_action = ""
		auth_submit_button.disabled = false
		if found_user.is_empty():
			auth_error_label.text = "Tên đăng nhập hoặc mật khẩu không chính xác."
			return
		_finish_authentication(username, found_user)
		return

	if action == "register_lookup":
		if not found_user.is_empty():
			auth_request_action = ""
			auth_submit_button.disabled = false
			auth_error_label.text = "Tên đăng nhập đã tồn tại."
			return
		users.append({
			"username": username,
			"password_hash": _password_hash(password),
			"realm": "Luyện Khí Kỳ",
			"tu_vi": 0,
			"linh_thach": 100,
			"luc_chien": 100,
			"created_at": Time.get_datetime_string_from_system(),
			"leaderboard_public": true
		})
		auth_request_action = "register_write"
		var error := http_request.request(JSONBIN_URL % AUTH_BIN_ID, _cloud_headers(), HTTPClient.METHOD_PUT, _auth_registry_payload(users))
		if error != OK:
			auth_request_action = ""
			auth_submit_button.disabled = false
			auth_error_label.text = "Không thể lưu tài khoản lên JSONBin."
		return

	if action == "profile_lookup":
		var updated := false
		for user in users:
			if user is Dictionary and str(user.get("username", "")).strip_edges() == current_username.strip_edges():
				var profile := _current_leaderboard_profile()
				user["leaderboard_public"] = true
				user["realm"] = profile["qi_realm"]
				user["tu_vi"] = profile["tu_vi"]
				user["linh_thach"] = profile["linh_thach"]
				user["luc_chien"] = profile["luc_chien"]
				user["equipment"] = profile["equipment"]
				user["item_inventory"] = profile["item_inventory"]
				user["owned_item_ids"] = profile["owned_item_ids"]
				updated = true
				break
		if updated:
			auth_request_action = "profile_write"
			var profile_error := http_request.request(JSONBIN_URL % AUTH_BIN_ID, _cloud_headers(), HTTPClient.METHOD_PUT, _auth_registry_with_profile(users))
			if profile_error != OK:
				auth_request_action = ""
		else:
			auth_request_action = ""
		return

func _rebuild_elixir_list() -> void:
	if not is_instance_valid(elixir_list):
		return
	for child in elixir_list.get_children():
		child.queue_free()
	for elixir in elixirs:
		_add_elixir_row(elixir)
