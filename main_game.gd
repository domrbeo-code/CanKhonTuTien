extends Control

const CLICK_EFFECT_SCENE: PackedScene = preload("res://ClickEffect.tscn")
const COMBAT_SCENE: PackedScene = preload("res://CombatManager.tscn")
const SUPABASE_URL: String = "https://sqwwbhkprdaqaxoowhoa.supabase.co"
const SUPABASE_KEY: String = "sb_publishable_3pEvMPBZxV6DRtFougHaHA_W90b2eL_"
const SUPABASE_AUTH_URL: String = SUPABASE_URL + "/auth/v1"
const SUPABASE_REST_URL: String = SUPABASE_URL + "/rest/v1"
const SUPABASE_REALTIME_URL: String = "wss://sqwwbhkprdaqaxoowhoa.supabase.co/realtime/v1/websocket?apikey=" + SUPABASE_KEY + "&vsn=1.0.0"
const AUTOSAVE_INTERVAL_SECONDS := 45.0
const ARENA_MAX_CHALLENGES := 3
const ARENA_RECOVERY_SECONDS := 300
const UI_REFRESH_INTERVAL_SECONDS := 0.1
const OFFLINE_CHECKPOINT_INTERVAL_SECONDS := 60.0
const OFFLINE_MAX_SECONDS := 28800.0
const OFFLINE_EFFICIENCY := 0.35
const COLLECT_COOLDOWN_SECONDS := 2.5
const CLOUD_REQUEST_COOLDOWN_SECONDS := 2.5
const TOUCH_SCROLL_DRAG_THRESHOLD := 10.0
const SPIRIT_STONE_VALUES: Dictionary = {"Hạ phẩm": 5000.0, "Trung phẩm": 100000.0, "Thượng phẩm": 2000000.0, "Cực phẩm": 40000000.0}
const ELIXIR_TIERS: Array[Dictionary] = [
	{"name": "Phàm Phẩm", "rarity_index": 0, "multiplier": 1.0},
	{"name": "Linh Phẩm", "rarity_index": 1, "multiplier": 10.0},
	{"name": "Địa Phẩm", "rarity_index": 3, "multiplier": 100.0},
	{"name": "Thiên Phẩm", "rarity_index": 4, "multiplier": 1000.0},
	{"name": "Thần Phẩm", "rarity_index": 5, "multiplier": 10000.0},
]
const ELIXIR_EFFECTS: Array[Dictionary] = [
	{"id": "absorb", "name": "Tụ Linh", "description": "Tốc độ hấp thu linh khí +%.0f%% vĩnh viễn", "base_value": 0.02, "step_value": 0.03},
	{"id": "breakthrough", "name": "Phá Cảnh", "description": "Tỷ lệ đột phá +%.0f%% vĩnh viễn", "base_value": 0.02, "step_value": 0.03},
	{"id": "spirit", "name": "Tăng Tu", "description": "Nhận ngay %s tu vi và linh khí", "base_value": 10000.0, "step_value": 10.0},
	{"id": "body", "name": "Luyện Thể", "description": "Thể phách và khí huyết +%s", "base_value": 100.0, "step_value": 10.0},
]
const ELIXIR_NAME_ROOTS: Array[String] = ["Thanh Vân", "Xích Diễm", "Huyền Minh", "Tử Tiêu", "Thái Hư", "Càn Khôn", "Vạn Kiếp", "Tinh Hà", "Bất Hủ", "Hỗn Độn", "Thiên Cơ", "Luân Hồi"]
var ELIXIR_DEFINITIONS: Array[Dictionary] = []
var elixir_definition_by_id: Dictionary = {}

const JADE := Color("#071f1a")
const JADE_PANEL := Color("#0d3028")
const JADE_LIGHT := Color("#124638")
const GOLD := Color("#d8ae58")
const GOLD_BRIGHT := Color("#f1d184")
const TEXT := Color("#e7eadc")
const MUTED := Color("#9cb4a5")
const SUCCESS := Color("#83c58d")
const DANGER := Color("#df8777")
const STATE_VERSION := 6
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
	{"id": "elixir_hon_don", "category": "ĐAN DƯỢC THIÊN TÀI ĐỊA BẢO", "name": "Hỗn Độn Nguyên Đan", "grade": "Thần", "details": "Nhận 10.000.000 tu vi và linh khí", "icon": "✧"},
	{"id": "skin_pham_y", "category": "NGOẠI TRANG / SKIN", "name": "Đạo Bào Thanh Vân", "grade": "Phàm", "details": "Ngoại trang khởi đầu", "icon": "衣"},
	{"id": "skin_tien_vu", "category": "NGOẠI TRANG / SKIN", "name": "Vũ Y Phi Tiên", "grade": "Tiên", "details": "Ngoại trang giới hạn sự kiện", "icon": "衣"},
]

@onready var http_request: HTTPRequest = %HTTPRequest

var cultivation := {"state_version": STATE_VERSION, "realm_index": 0, "realm_name": "Luyện Khí Kỳ - Sơ Kỳ - Tầng 1", "cultivation": 0.0, "cultivation_need": 100.0, "spirit": 0.0, "spirit_per_second": 1.0, "body_mode": false, "backlash_seconds": 0.0}
var body_cultivation := {"realm_index": 0, "realm_name": BODY_REALMS[0], "power": 0.0, "power_need": 100.0, "blood": 0.0, "blood_per_second": 1.0}
var inventory := {"herbs": {"Thanh Linh Thảo": 0, "Tử Vân Hoa": 0, "Hỏa Linh Quả": 0}, "elixirs": [{"id": "elixir_tu_khi_pham", "name": "Tụ Khí Đan Phàm Phẩm", "description": "Tăng 10% hiệu quả hấp thu trong 60 giây", "count": 1, "effect": "absorb"}]}
var spirit_stone_inventory: Dictionary = {"Trung phẩm": 0, "Thượng phẩm": 0, "Cực phẩm": 0}
var cultivation_method_ids: Array[String] = []
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
var arena_recovery_unix := 0
var arena_daily_label: Label
var arena_recovery_elapsed := 0.0
var cultivation_bar: ProgressBar
var realm_label: Label
var cultivation_value_label: Label
var spirit_label: Label
var status_label: Label
var breakthrough_button: Button
var elixir_list: VBoxContainer
var notification_label: Label
var cloud_status_label: Label
var header_title_label: Label
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
var main_root: VBoxContainer
var main_content_row: BoxContainer
var main_columns: BoxContainer
var main_scroll: ScrollContainer
var global_log_panel: PanelContainer
var global_log_scroll: ScrollContainer
var global_log_view: RichTextLabel
var world_chat_input: LineEdit
var world_chat_send_button: Button
var global_log_lines: Array[String] = []
var touch_scroll_container: ScrollContainer
var touch_scroll_index := -1
var touch_scroll_start_position := Vector2.ZERO
var touch_scroll_last_position := Vector2.ZERO
var touch_scroll_dragging := false
var touch_scroll_velocity := 0.0
var touch_scroll_horizontal := false
var mobile_navigation: HBoxContainer
var mobile_navigation_buttons: Array[Button] = []
var mobile_active_section := "cultivation"
var touch_mode_active := false
var section_transition_tween: Tween
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
var supabase_access_token := ""
var supabase_refresh_token := ""
var supabase_user_id := ""
var supabase_token_lifetime := 3600.0
var supabase_token_elapsed := 0.0
var supabase_request_queue: Array[Dictionary] = []
var supabase_active_request: Dictionary = {}
var supabase_ref_counter := 0
var world_chat_socket := WebSocketPeer.new()
var world_chat_socket_joined := false
var world_chat_heartbeat_elapsed := 0.0
var world_chat_reconnect_elapsed := 0.0
var world_chat_message_pending := ""
var world_chat_seen_ids: Array[int] = []
var current_username := ""
var authenticated_account: Dictionary = {}
var is_authenticated := false
var autosave_elapsed := 0.0
var pending_auth_username := ""
var pending_auth_password := ""
var last_click_frame := -1
var last_click_position := Vector2.INF
var collect_cooldown_remaining := 0.0
var cloud_request_cooldown_remaining := 0.0
var ui_refresh_elapsed := 0.0
var progress_tween: Tween
var popup_tween: Tween
var popup_closing := false
var active_combat: Control
var offline_checkpoint_elapsed := 0.0
var breakthrough_timing_bonus := 0.0
var breakthrough_minigame_active := false
var breakthrough_meter_value := 0.0
var breakthrough_meter_direction := 1.0
var breakthrough_overlay: Control
var breakthrough_panel: PanelContainer
var breakthrough_meter_track: Control
var breakthrough_meter_marker: ColorRect
var breakthrough_chance_label: Label
var breakthrough_minigame_tween: Tween
var tribulation_active := false
var offline_reward_summary := ""

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
	var major_index := floori(float(level_index) / 40.0)
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
	_initialize_elixir_catalog()
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
	for elixir in ELIXIR_DEFINITIONS:
		item_catalog.push_front({"id": elixir["id"], "category": "ĐAN DƯỢC", "rarity": ITEM_RARITIES[elixir["rarity_index"]], "rarity_index": elixir["rarity_index"], "name": elixir["name"], "icon": "✧", "details": elixir["description"], "source": elixir["source"], "power": (int(elixir["rarity_index"]) + 1) * 10})
	_initialize_secret_realm_catalog()
	_ensure_elixir_entries()

func _initialize_elixir_catalog() -> void:
	if not ELIXIR_DEFINITIONS.is_empty():
		return
	var legacy_definitions: Array[Dictionary] = [
		{"id": "elixir_tu_khi_pham", "name": "Tụ Khí Đan Phàm Phẩm", "rarity_index": 0, "effect": "absorb", "effect_value": 0.08, "description": "Tốc độ hấp thu linh khí +8% vĩnh viễn", "source": "Đả tọa / Bí cảnh"},
		{"id": "elixir_truc_co", "name": "Trúc Cơ Đan", "rarity_index": 2, "effect": "breakthrough", "effect_value": 0.12, "description": "Tỷ lệ đột phá +12% vĩnh viễn", "source": "Bí cảnh / Sự kiện"},
		{"id": "elixir_hon_don", "name": "Hỗn Độn Nguyên Đan", "rarity_index": 5, "effect": "spirit", "effect_value": 10000000.0, "description": "Nhận ngay 10.000.000 tu vi và linh khí", "source": "Bí cảnh cấp cao"},
	]
	for definition in legacy_definitions:
		_register_elixir_definition(definition)
	for tier_index in range(ELIXIR_TIERS.size()):
		var tier: Dictionary = ELIXIR_TIERS[tier_index]
		for effect_template in ELIXIR_EFFECTS:
			for variant in range(ELIXIR_NAME_ROOTS.size()):
				var effect_id := str(effect_template["id"])
				var tier_multiplier := float(tier["multiplier"])
				var effect_value: float
				var description: String
				if effect_id in ["absorb", "breakthrough"]:
					effect_value = float(effect_template["base_value"]) + float(effect_template["step_value"]) * float(tier_index)
					description = str(effect_template["description"]) % [effect_value * 100.0]
				elif effect_id == "spirit":
					effect_value = float(effect_template["base_value"]) * tier_multiplier
					description = str(effect_template["description"]) % _format_number(effect_value)
				else:
					effect_value = float(effect_template["base_value"]) * tier_multiplier
					description = str(effect_template["description"]) % _format_number(effect_value)
				var name := "%s %s %s Đan" % [str(tier["name"]), ELIXIR_NAME_ROOTS[variant], str(effect_template["name"])]
				_register_elixir_definition({
					"id": "elixir_%s_%d_%02d" % [effect_id, tier_index, variant],
					"name": name,
					"rarity_index": int(tier["rarity_index"]),
					"effect": effect_id,
					"effect_value": effect_value,
					"description": description,
					"source": "Phần thưởng / Bí cảnh",
				})

func _register_elixir_definition(definition: Dictionary) -> void:
	var item_id := str(definition.get("id", ""))
	if item_id.is_empty() or elixir_definition_by_id.has(item_id):
		return
	ELIXIR_DEFINITIONS.append(definition.duplicate(true))
	elixir_definition_by_id[item_id] = ELIXIR_DEFINITIONS.back()

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
	var bonus_stones: Dictionary = {}
	if int(realm["difficulty"]) >= 11 and randf() < 0.30:
		spirit_stone_inventory["Trung phẩm"] = int(spirit_stone_inventory.get("Trung phẩm", 0)) + 1
		bonus_stones["Trung phẩm"] = 1
	if int(realm["difficulty"]) >= 26 and randf() < 0.20:
		spirit_stone_inventory["Thượng phẩm"] = int(spirit_stone_inventory.get("Thượng phẩm", 0)) + 1
		bonus_stones["Thượng phẩm"] = 1
	if int(realm["difficulty"]) >= 39 and randf() < 0.10:
		spirit_stone_inventory["Cực phẩm"] = int(spirit_stone_inventory.get("Cực phẩm", 0)) + 1
		bonus_stones["Cực phẩm"] = 1
	var drops: Array[Dictionary] = []
	if randf() <= float(realm["drop_chance"]):
		var max_rarity := _max_secret_realm_rarity(int(realm["difficulty"]))
		var item := _pick_secret_realm_item(max_rarity)
		if not item.is_empty():
			drops.append(item)
			var item_id: String = item["id"]
			item_inventory[item_id] = int(item_inventory.get(item_id, 0)) + 1
			_sync_elixir_counts_from_inventory()
			_rebuild_elixir_list()
			if item_id not in owned_item_ids:
				owned_item_ids.append(item_id)
			if item_id not in codex_unlocked_ids:
				codex_unlocked_ids.append(item_id)
	spirit_stones += stone_reward
	if realm_index not in secret_realm_clears:
		secret_realm_clears.append(realm_index)
	var result := {"success": true, "realm_name": realm["name"], "spirit_stones": stone_reward, "bonus_stones": bonus_stones, "items": drops}
	_show_secret_realm_result(result)
	if active_center_tab == "BÍ CẢNH" and is_instance_valid(popup_body):
		_render_popup_tab("BÍ CẢNH")
	return result

func _show_secret_realm_result(result: Dictionary) -> void:
	var lines: Array[String] = ["BÍ CẢNH · " + str(result["realm_name"]), "Vượt qua thành công", "Linh Thạch: +" + _format_number(result["spirit_stones"])]
	for grade in result.get("bonus_stones", {}):
		lines.append("Linh thạch %s: +%d" % [grade, int(result["bonus_stones"][grade])])
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
	_sync_elixir_counts_from_inventory()
	_rebuild_elixir_list()
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
	_recalculate_cultivation_rates()
	http_request.request_completed.connect(_on_supabase_request_completed)
	_build_interface()
	_build_auth_gate()
	resized.connect(_update_responsive_layout)
	_update_responsive_layout()
	_set_mobile_section(mobile_active_section)
	_update_display()
	append_global_log("Càn Khôn Tu Tiên · Kết nối thế giới tu tiên")

func _process(delta: float) -> void:
	_update_touch_scroll_inertia(delta)
	collect_cooldown_remaining = maxf(0.0, collect_cooldown_remaining - delta)
	cloud_request_cooldown_remaining = maxf(0.0, cloud_request_cooldown_remaining - delta)
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
		if autosave_elapsed >= AUTOSAVE_INTERVAL_SECONDS and supabase_request_queue.is_empty() and supabase_active_request.is_empty() and cloud_request_cooldown_remaining <= 0.0:
			autosave_elapsed = 0.0
			save_game()
		supabase_token_elapsed += delta
		if not supabase_refresh_token.is_empty() and supabase_token_elapsed >= supabase_token_lifetime - 120.0:
			_refresh_supabase_session()
		_poll_world_chat_realtime(delta)
		offline_checkpoint_elapsed += delta
		if offline_checkpoint_elapsed >= OFFLINE_CHECKPOINT_INTERVAL_SECONDS:
			offline_checkpoint_elapsed = fmod(offline_checkpoint_elapsed, OFFLINE_CHECKPOINT_INTERVAL_SECONDS)
			_write_offline_checkpoint()
	if breakthrough_minigame_active:
		_update_breakthrough_minigame(delta)
	arena_recovery_elapsed += delta
	if arena_recovery_elapsed >= 1.0:
		arena_recovery_elapsed = fmod(arena_recovery_elapsed, 1.0)
		_prepare_arena_day()
	ui_refresh_elapsed += delta
	if ui_refresh_elapsed >= UI_REFRESH_INTERVAL_SECONDS:
		ui_refresh_elapsed = fmod(ui_refresh_elapsed, UI_REFRESH_INTERVAL_SECONDS)
		_update_display()

func _input(event: InputEvent) -> void:
	_handle_touch_scroll_event(event)
	if breakthrough_minigame_active and event is InputEventKey and event.pressed and not event.is_echo():
		if event.keycode in [KEY_SPACE, KEY_ENTER, KEY_KP_ENTER]:
			_resolve_breakthrough_minigame()
			get_viewport().set_input_as_handled()
			return
		if event.keycode == KEY_ESCAPE:
			_cancel_breakthrough_minigame()
			get_viewport().set_input_as_handled()
			return
	if event is InputEventMouseButton and event.pressed:
		_spawn_click_effect(event.position)

func _handle_touch_scroll_event(event: InputEvent) -> void:
	if not touch_mode_active or breakthrough_minigame_active or is_instance_valid(active_combat):
		return
	if is_instance_valid(auth_overlay) and auth_overlay.visible:
		return
	if event is InputEventScreenTouch:
		if event.pressed:
			touch_scroll_index = event.index
			var scroll_root: Node = popup_overlay if is_instance_valid(popup_overlay) and popup_overlay.visible else self
			touch_scroll_container = _find_deepest_scroll_container(scroll_root, event.position, null, INF)
			touch_scroll_start_position = event.position
			touch_scroll_last_position = event.position
			touch_scroll_dragging = false
			touch_scroll_velocity = 0.0
			touch_scroll_horizontal = false
		else:
			var completed_drag: bool = event.index == touch_scroll_index and touch_scroll_dragging
			if completed_drag:
				get_viewport().set_input_as_handled()
			touch_scroll_index = -1
			touch_scroll_dragging = false
			if not completed_drag or absf(touch_scroll_velocity) < 35.0:
				touch_scroll_container = null
				touch_scroll_velocity = 0.0
	elif event is InputEventScreenDrag and event.index == touch_scroll_index and is_instance_valid(touch_scroll_container):
		if not touch_scroll_dragging and event.position.distance_to(touch_scroll_start_position) >= TOUCH_SCROLL_DRAG_THRESHOLD:
			touch_scroll_dragging = true
			var drag_vector: Vector2 = event.position - touch_scroll_start_position
			var vertical_bar := touch_scroll_container.get_v_scroll_bar()
			var horizontal_bar := touch_scroll_container.get_h_scroll_bar()
			var can_scroll_vertical := vertical_bar.max_value > vertical_bar.page + 1.0
			var can_scroll_horizontal := horizontal_bar.max_value > horizontal_bar.page + 1.0
			touch_scroll_horizontal = can_scroll_horizontal and (not can_scroll_vertical or absf(drag_vector.x) > absf(drag_vector.y))
		if touch_scroll_dragging:
			if touch_scroll_horizontal:
				var horizontal_delta = event.position.x - touch_scroll_last_position.x
				var horizontal_scrollbar := touch_scroll_container.get_h_scroll_bar()
				var horizontal_max := maxf(0.0, horizontal_scrollbar.max_value - horizontal_scrollbar.page)
				touch_scroll_container.scroll_horizontal = clampi(roundi(float(touch_scroll_container.scroll_horizontal) - horizontal_delta), 0, roundi(horizontal_max))
				touch_scroll_velocity = -event.velocity.x
			else:
				var vertical_delta = event.position.y - touch_scroll_last_position.y
				var vertical_scrollbar := touch_scroll_container.get_v_scroll_bar()
				var vertical_max := maxf(0.0, vertical_scrollbar.max_value - vertical_scrollbar.page)
				touch_scroll_container.scroll_vertical = clampi(roundi(float(touch_scroll_container.scroll_vertical) - vertical_delta), 0, roundi(vertical_max))
				touch_scroll_velocity = -event.velocity.y
			touch_scroll_last_position = event.position
			get_viewport().set_input_as_handled()

func _update_touch_scroll_inertia(delta: float) -> void:
	if not touch_mode_active or touch_scroll_dragging or not is_instance_valid(touch_scroll_container):
		return
	if breakthrough_minigame_active or is_instance_valid(active_combat) or (is_instance_valid(auth_overlay) and auth_overlay.visible):
		touch_scroll_container = null
		touch_scroll_velocity = 0.0
		return
	if absf(touch_scroll_velocity) < 35.0:
		touch_scroll_container = null
		touch_scroll_velocity = 0.0
		return
	var scrollbar: ScrollBar = touch_scroll_container.get_h_scroll_bar() if touch_scroll_horizontal else touch_scroll_container.get_v_scroll_bar()
	var current_scroll := float(touch_scroll_container.scroll_horizontal) if touch_scroll_horizontal else float(touch_scroll_container.scroll_vertical)
	var max_scroll := maxf(0.0, scrollbar.max_value - scrollbar.page)
	var next_scroll := clampf(current_scroll + touch_scroll_velocity * delta, 0.0, max_scroll)
	if is_equal_approx(next_scroll, current_scroll):
		touch_scroll_velocity = 0.0
	else:
		if touch_scroll_horizontal:
			touch_scroll_container.scroll_horizontal = roundi(next_scroll)
		else:
			touch_scroll_container.scroll_vertical = roundi(next_scroll)
		touch_scroll_velocity = move_toward(touch_scroll_velocity, 0.0, 1800.0 * delta)

func _find_deepest_scroll_container(node: Node, screen_position: Vector2, current_best: ScrollContainer, current_area: float) -> ScrollContainer:
	if node is Control and not node.is_visible_in_tree():
		return current_best
	var best := current_best
	var best_area := current_area
	if node is ScrollContainer:
		var scroll := node as ScrollContainer
		var rect := scroll.get_global_rect()
		var scrollbar := scroll.get_v_scroll_bar()
		var horizontal_bar := scroll.get_h_scroll_bar()
		var has_scroll_range := scrollbar.max_value > scrollbar.page + 1.0 or horizontal_bar.max_value > horizontal_bar.page + 1.0
		if rect.has_point(screen_position) and has_scroll_range and rect.get_area() < best_area:
			best = scroll
			best_area = rect.get_area()
	for child in node.get_children():
		best = _find_deepest_scroll_container(child, screen_position, best, best_area)
		if is_instance_valid(best):
			best_area = best.get_global_rect().get_area()
	return best

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
		_write_offline_checkpoint()
	if world_chat_socket.get_ready_state() != WebSocketPeer.STATE_CLOSED:
		world_chat_socket.close()

func _offline_checkpoint_path(username: String) -> String:
	var account_key := supabase_user_id if not supabase_user_id.is_empty() else username.strip_edges().to_lower()
	return "user://offline_%s.cfg" % account_key.sha256_text()

func _write_offline_checkpoint() -> void:
	if not is_authenticated or current_username.is_empty():
		return
	var track := "body" if bool(cultivation.get("body_mode", false)) else "qi"
	var effective_rate: float
	if track == "body":
		effective_rate = float(body_cultivation.get("blood_per_second", 0.0))
	else:
		var backlash_factor := 0.5 if float(cultivation.get("backlash_seconds", 0.0)) > 0.0 else 1.0
		effective_rate = float(cultivation.get("spirit_per_second", 0.0)) * absorb_bonus * backlash_factor
	var checkpoint := ConfigFile.new()
	checkpoint.set_value("offline", "saved_unix", Time.get_unix_time_from_system())
	checkpoint.set_value("offline", "username", current_username.strip_edges().to_lower())
	checkpoint.set_value("offline", "track", track)
	checkpoint.set_value("offline", "rate_per_second", effective_rate)
	var error := checkpoint.save(_offline_checkpoint_path(current_username))
	if error == OK:
		offline_checkpoint_elapsed = 0.0

func _apply_offline_reward(username: String) -> void:
	offline_reward_summary = ""
	var checkpoint := ConfigFile.new()
	var load_error := checkpoint.load(_offline_checkpoint_path(username))
	if load_error != OK:
		_write_offline_checkpoint()
		return
	var saved_username := str(checkpoint.get_value("offline", "username", ""))
	if saved_username != username.strip_edges().to_lower():
		_write_offline_checkpoint()
		return
	var saved_unix := int(checkpoint.get_value("offline", "saved_unix", 0))
	var elapsed := clampf(float(Time.get_unix_time_from_system() - saved_unix), 0.0, OFFLINE_MAX_SECONDS)
	var track := str(checkpoint.get_value("offline", "track", "qi"))
	var rate := maxf(0.0, float(checkpoint.get_value("offline", "rate_per_second", 0.0)))
	var gained := 0.0
	if elapsed > 0.0 and rate > 0.0:
		if track == "body":
			var current := float(body_cultivation.get("power", 0.0))
			var need := float(body_cultivation.get("power_need", 0.0))
			gained = minf(rate * elapsed * OFFLINE_EFFICIENCY, minf(need * 0.25, maxf(0.0, need - current)))
			body_cultivation["power"] = current + gained
			body_cultivation["blood"] = float(body_cultivation.get("blood", 0.0)) + gained
		else:
			var current := float(cultivation.get("cultivation", 0.0))
			var need := float(cultivation.get("cultivation_need", 0.0))
			gained = minf(rate * elapsed * OFFLINE_EFFICIENCY, minf(need * 0.25, maxf(0.0, need - current)))
			cultivation["cultivation"] = current + gained
			cultivation["spirit"] = float(cultivation.get("spirit", 0.0)) + gained
	if gained > 0.0:
		var elapsed_minutes := int(elapsed / 60.0)
		var resource_name := "thể phách" if track == "body" else "tu vi"
		offline_reward_summary = "\nĐả tọa ủy thác %d phút · %s +%s" % [elapsed_minutes, resource_name, _format_number(gained)]
		authenticated_account["tu_vi"] = float(cultivation.get("cultivation", 0.0))
		authenticated_account["body_cultivation"] = body_cultivation.duplicate(true)
		_update_display()
	_write_offline_checkpoint()

func _build_interface() -> void:
	var background := ColorRect.new()
	background.color = JADE
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background)
	main_margin = MarginContainer.new()
	main_margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(main_margin)
	main_root = VBoxContainer.new()
	main_root.add_theme_constant_override("separation", 16)
	main_margin.add_child(main_root)
	main_root.add_child(_build_header())
	mobile_navigation = _build_mobile_navigation()
	main_root.add_child(mobile_navigation)
	main_content_row = BoxContainer.new()
	main_content_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	main_content_row.size_flags_vertical = Control.SIZE_EXPAND_FILL
	main_content_row.add_theme_constant_override("separation", 10)
	main_root.add_child(main_content_row)
	main_scroll = ScrollContainer.new()
	main_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	main_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	main_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	main_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	main_scroll.clip_contents = true
	main_content_row.add_child(main_scroll)
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
	global_log_panel = _build_global_log_panel()
	main_content_row.add_child(global_log_panel)
	_build_popup_overlay()

func _build_global_log_panel() -> PanelContainer:
	var panel := PanelContainer.new()
	panel.name = "GlobalEventChatPanel"
	panel.custom_minimum_size.x = 260
	panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	panel.clip_contents = true
	panel.add_theme_stylebox_override("panel", _style(Color("#0b2922"), 8, Color("#80632f"), 1))
	var margin := MarginContainer.new()
	for side in ["left", "top", "right", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 10)
	panel.add_child(margin)
	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 7)
	margin.add_child(content)
	var heading := HBoxContainer.new()
	var title := _label("THẾ GIỚI · SỰ KIỆN", 13, GOLD_BRIGHT)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	heading.add_child(title)
	heading.add_child(_label("● LIVE", 9, SUCCESS))
	content.add_child(heading)
	content.add_child(_rule())
	global_log_scroll = ScrollContainer.new()
	global_log_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	global_log_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	global_log_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	global_log_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	global_log_scroll.clip_contents = true
	content.add_child(global_log_scroll)
	global_log_view = RichTextLabel.new()
	global_log_view.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	global_log_view.fit_content = true
	global_log_view.scroll_active = false
	global_log_view.bbcode_enabled = false
	global_log_view.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	global_log_view.add_theme_font_size_override("normal_font_size", 11)
	global_log_view.add_theme_color_override("default_color", TEXT)
	global_log_scroll.add_child(global_log_view)
	var chat_row := HBoxContainer.new()
	chat_row.add_theme_constant_override("separation", 6)
	content.add_child(chat_row)
	world_chat_input = LineEdit.new()
	world_chat_input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	world_chat_input.custom_minimum_size.y = 42
	world_chat_input.max_length = 240
	world_chat_input.placeholder_text = "Gửi lời đến thế giới..."
	world_chat_input.text_submitted.connect(_send_world_chat)
	chat_row.add_child(world_chat_input)
	world_chat_send_button = _button("GỬI", GOLD, 62)
	world_chat_send_button.pressed.connect(_send_world_chat.bind(""))
	chat_row.add_child(world_chat_send_button)
	for line in global_log_lines:
		global_log_view.append_text(line + "\n")
	global_log_scroll.call_deferred("set", "scroll_vertical", global_log_scroll.get_v_scroll_bar().max_value)
	return panel

func append_global_log(text: String) -> void:
	var clean_text := text.strip_edges()
	if clean_text.is_empty():
		return
	for entry in clean_text.split("\n", false):
		var clean_entry := entry.strip_edges()
		if not clean_entry.is_empty():
			global_log_lines.append("[%s] %s" % [Time.get_time_string_from_system(), clean_entry])
	while global_log_lines.size() > 40:
		global_log_lines.pop_front()
	if not is_instance_valid(global_log_view):
		return
	global_log_view.clear()
	for line in global_log_lines:
		global_log_view.append_text(line + "\n")
	global_log_view.scroll_to_line(maxi(0, global_log_view.get_line_count() - 1))
	global_log_scroll.call_deferred("set", "scroll_vertical", global_log_scroll.get_v_scroll_bar().max_value)

func _send_world_chat(_submitted_text: String = "") -> void:
	if not is_instance_valid(world_chat_input) or not is_instance_valid(world_chat_send_button):
		return
	var message := world_chat_input.text.strip_edges()
	if message.is_empty():
		return
	if not is_authenticated or supabase_user_id.is_empty():
		_show_notification("Đăng nhập Supabase để gửi tin nhắn thế giới.", DANGER)
		return
	message = message.substr(0, 240)
	world_chat_input.clear()
	world_chat_input.editable = false
	world_chat_send_button.disabled = true
	await get_tree().create_timer(0.65).timeout
	if not is_inside_tree() or not is_instance_valid(world_chat_input):
		return
	world_chat_message_pending = "[Thế Giới] %s: %s" % [current_username, message]
	var payload := {"user_id": supabase_user_id, "username": current_username, "message": message}
	var extra := PackedStringArray(["Prefer: return=minimal"])
	_enqueue_supabase_request("world_chat_send", SUPABASE_REST_URL + "/world_chat", HTTPClient.METHOD_POST, JSON.stringify(payload), true, extra)

func _build_mobile_navigation() -> HBoxContainer:
	var navigation := HBoxContainer.new()
	navigation.add_theme_constant_override("separation", 6)
	navigation.custom_minimum_size.y = 52
	var sections: Array[Dictionary] = [
		{"id": "cultivation", "label": "TU LUYỆN"},
		{"id": "character", "label": "ĐẠO HỮU"},
		{"id": "elixirs", "label": "ĐAN DƯỢC"},
	]
	for section in sections:
		var button := _button(str(section["label"]), GOLD, -1)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.add_theme_font_size_override("font_size", 11)
		button.set_meta("responsive_base_font_size", 11)
		button.pressed.connect(_set_mobile_section.bind(str(section["id"])))
		mobile_navigation_buttons.append(button)
		navigation.add_child(button)
	return navigation

func _set_mobile_section(section_id: String) -> void:
	if section_id not in ["cultivation", "character", "elixirs"]:
		return
	var changed := mobile_active_section != section_id
	mobile_active_section = section_id
	_apply_mobile_section_visibility(changed)
	for index in range(mobile_navigation_buttons.size()):
		var selected := str(["cultivation", "character", "elixirs"][index]) == mobile_active_section
		mobile_navigation_buttons[index].add_theme_color_override("font_color", GOLD_BRIGHT if selected else MUTED)

func _apply_mobile_section_visibility(animate: bool) -> void:
	var panels: Dictionary = {
		"cultivation": responsive_left_panel,
		"character": responsive_center_panel,
		"elixirs": responsive_right_panel,
	}
	var selected_panel: Control
	for section_id in panels:
		var panel: Control = panels[section_id]
		var should_show: bool = not touch_mode_active or section_id == mobile_active_section
		panel.visible = should_show
		if should_show:
			selected_panel = panel
	if animate and touch_mode_active and is_instance_valid(selected_panel):
		if section_transition_tween != null and section_transition_tween.is_running():
			section_transition_tween.kill()
		selected_panel.modulate.a = 0.0
		selected_panel.pivot_offset = selected_panel.size * 0.5
		selected_panel.scale = Vector2(0.98, 0.98)
		section_transition_tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		section_transition_tween.set_parallel(true)
		section_transition_tween.tween_property(selected_panel, "modulate:a", 1.0, 0.18)
		section_transition_tween.tween_property(selected_panel, "scale", Vector2.ONE, 0.18)

func _update_responsive_layout() -> void:
	var compact := size.x < 900.0 or OS.has_feature("mobile") or OS.has_feature("android") or OS.has_feature("ios")
	var side_dock := size.x >= 1400.0 and not compact
	if touch_mode_active != compact:
		touch_mode_active = compact
		_set_touch_sizing(main_root, touch_mode_active)
		_set_touch_sizing(popup_overlay, touch_mode_active)
		_set_touch_sizing(auth_overlay, touch_mode_active)
	if is_instance_valid(mobile_navigation):
		mobile_navigation.visible = compact
	if is_instance_valid(main_root):
		main_root.add_theme_constant_override("separation", 12 if compact else 16)
	if is_instance_valid(header_title_label):
		header_title_label.add_theme_font_size_override("font_size", 18 if compact else 25)
	if is_instance_valid(cloud_status_label):
		cloud_status_label.custom_minimum_size.x = 112 if compact else 145
		cloud_status_label.add_theme_font_size_override("font_size", 10 if compact else 12)
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
		main_columns.add_theme_constant_override("separation", 14)
	if is_instance_valid(main_content_row):
		main_content_row.vertical = not side_dock
		main_content_row.add_theme_constant_override("separation", 12 if compact else 10)
	if is_instance_valid(main_scroll):
		main_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		main_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	if is_instance_valid(global_log_panel):
		global_log_panel.custom_minimum_size.x = 0 if not side_dock else 260
		global_log_panel.custom_minimum_size.y = 220 if not side_dock else 0
		global_log_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL if not side_dock else Control.SIZE_SHRINK_END
		global_log_panel.size_flags_vertical = Control.SIZE_SHRINK_CENTER if not side_dock else Control.SIZE_EXPAND_FILL
	if is_instance_valid(responsive_left_panel):
		responsive_left_panel.custom_minimum_size.x = 0 if compact else (300 if side_dock else 340)
		responsive_left_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL if compact else Control.SIZE_SHRINK_BEGIN
	if is_instance_valid(left_collect_button):
		left_collect_button.custom_minimum_size.x = 120 if compact else (128 if side_dock else 150)
	if is_instance_valid(left_action_button):
		left_action_button.custom_minimum_size.x = 120 if compact else 130
	if is_instance_valid(responsive_center_panel):
		responsive_center_panel.custom_minimum_size.x = 0
		responsive_center_panel.custom_minimum_size.y = 520 if compact else 620
		responsive_center_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	if is_instance_valid(responsive_right_panel):
		responsive_right_panel.custom_minimum_size.x = 0 if compact else (280 if side_dock else 340)
		responsive_right_panel.custom_minimum_size.y = 560 if compact else 0
		responsive_right_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL if compact else Control.SIZE_SHRINK_END
	if is_instance_valid(main_columns):
		_apply_mobile_section_visibility(false)
	if is_instance_valid(feature_popup_panel):
		var popup_width: float = minf(1000.0, maxf(280.0 if compact else 320.0, size.x - (16.0 if compact else 24.0)))
		var popup_height: float = minf(680.0, maxf(300.0 if compact else 420.0, size.y - (24.0 if compact else 24.0)))
		feature_popup_panel.offset_left = -popup_width * 0.5
		feature_popup_panel.offset_top = -popup_height * 0.5
		feature_popup_panel.offset_right = popup_width * 0.5
		feature_popup_panel.offset_bottom = popup_height * 0.5
		feature_popup_panel.pivot_offset = Vector2(popup_width, popup_height) * 0.5
	if is_instance_valid(authentication_panel):
		var auth_width: float = minf(600.0, maxf(280.0 if compact else 320.0, size.x - (16.0 if compact else 24.0)))
		var auth_height: float = minf(490.0, maxf(360.0 if compact else 420.0, size.y - 24.0))
		authentication_panel.offset_left = -auth_width * 0.5
		authentication_panel.offset_top = -auth_height * 0.5
		authentication_panel.offset_right = auth_width * 0.5
		authentication_panel.offset_bottom = auth_height * 0.5
	if is_instance_valid(breakthrough_panel):
		var minigame_width: float = minf(520.0, maxf(280.0 if compact else 360.0, size.x - (16.0 if compact else 48.0)))
		var minigame_height: float = minf(360.0, maxf(270.0 if compact else 300.0, size.y - 32.0))
		breakthrough_panel.offset_left = -minigame_width * 0.5
		breakthrough_panel.offset_top = -minigame_height * 0.5
		breakthrough_panel.offset_right = minigame_width * 0.5
		breakthrough_panel.offset_bottom = minigame_height * 0.5

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
	auth_username_input.placeholder_text = "Email Supabase"
	auth_username_input.custom_minimum_size.y = 42
	auth_username_input.max_length = 254
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
	var email := auth_username_input.text.strip_edges().to_lower()
	var password := auth_password_input.text
	if not _is_valid_email(email):
		auth_error_label.text = "Hãy nhập địa chỉ email hợp lệ."
		return
	if password.length() < 6:
		auth_error_label.text = "Mật khẩu cần ít nhất 6 ký tự."
		return
	auth_submit_button.disabled = true
	auth_error_label.text = "Đang kết nối Supabase Auth..."
	pending_auth_username = email
	pending_auth_password = password
	var action := "signup" if auth_mode == "register" else "login"
	var endpoint := "/signup" if action == "signup" else "/token?grant_type=password"
	var body := {"email": email, "password": password}
	if action == "signup":
		body["data"] = {"display_name": email.get_slice("@", 0)}
	_enqueue_supabase_request(action, SUPABASE_AUTH_URL + endpoint, HTTPClient.METHOD_POST, JSON.stringify(body), false)

func _is_valid_email(email: String) -> bool:
	var parts := email.split("@", false)
	return parts.size() == 2 and parts[0].length() >= 1 and parts[1].contains(".") and not parts[1].begins_with(".") and not parts[1].ends_with(".")

func _finish_authentication(email: String, auth_data: Dictionary) -> void:
	var user: Dictionary = auth_data.get("user", {})
	var metadata: Dictionary = user.get("user_metadata", {})
	var user_id := str(user.get("id", ""))
	var access_token := str(auth_data.get("access_token", ""))
	if user_id.is_empty() or access_token.is_empty():
		auth_error_label.text = "Supabase không trả về phiên đăng nhập hợp lệ."
		auth_submit_button.disabled = false
		return
	supabase_user_id = user_id
	supabase_access_token = access_token
	supabase_refresh_token = str(auth_data.get("refresh_token", ""))
	supabase_token_lifetime = float(auth_data.get("expires_in", 3600.0))
	supabase_token_elapsed = 0.0
	current_username = str(metadata.get("display_name", email.get_slice("@", 0)))
	authenticated_account = {"id": supabase_user_id, "email": email, "username": current_username}
	is_authenticated = true
	pending_auth_username = ""
	pending_auth_password = ""
	auth_overlay.visible = false
	auth_submit_button.disabled = false
	_connect_world_chat_realtime()
	load_game()
	_show_notification("Đăng nhập Supabase thành công · " + current_username, SUCCESS)

func _hydrate_state_from_account(account: Dictionary) -> void:
	if account.is_empty():
		return
	var has_full_cultivation := account.has("cultivation") and account["cultivation"] is Dictionary
	if has_full_cultivation:
		cultivation = account["cultivation"].duplicate(true)
	var saved_realm := str(account.get("realm", account.get("realm_name", account.get("qi_realm", "")))).strip_edges()
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
	if account.has("tu_vi") and not has_full_cultivation:
		cultivation["cultivation"] = maxf(0.0, saved_tu_vi)
	absorb_bonus = maxf(1.0, float(account.get("absorb_bonus", 1.0)))
	breakthrough_bonus = maxf(0.0, float(account.get("breakthrough_bonus", 0.0)))
	if account.has("body_cultivation") and account["body_cultivation"] is Dictionary:
		body_cultivation = account["body_cultivation"].duplicate(true)
	if account.has("linh_thach"):
		spirit_stones = maxi(0, saved_spirit_stones)
	if account.has("luc_chien"):
		combat_power = maxi(0, saved_power)
	if account.has("arena_challenges_today"):
		arena_challenges_today = int(account.get("arena_challenges_today", 0))
	if account.has("arena_last_day"):
		arena_last_day = str(account.get("arena_last_day", ""))
	if account.has("arena_recovery_unix"):
		arena_recovery_unix = int(account.get("arena_recovery_unix", 0))
	if account.has("equipment") and account["equipment"] is Dictionary:
		equipment = account["equipment"].duplicate(true)
	if account.has("item_inventory") and account["item_inventory"] is Dictionary:
		item_inventory = account["item_inventory"].duplicate(true)
	if account.has("spirit_stone_inventory") and account["spirit_stone_inventory"] is Dictionary:
		spirit_stone_inventory = account["spirit_stone_inventory"].duplicate(true)
	else:
		spirit_stone_inventory = {"Trung phẩm": 0, "Thượng phẩm": 0, "Cực phẩm": 0}
	if account.has("cultivation_method_ids") and account["cultivation_method_ids"] is Array:
		cultivation_method_ids.clear()
		for item_id in account["cultivation_method_ids"]:
			if str(item_id) not in cultivation_method_ids:
				cultivation_method_ids.append(str(item_id))
	if account.has("inventory") and account["inventory"] is Dictionary:
		inventory = account["inventory"].duplicate(true)
		elixirs = inventory.get("elixirs", []).duplicate(true)
		_ensure_elixir_entries()
		_sync_elixir_counts_from_inventory()
		_rebuild_elixir_list()
	if account.has("owned_item_ids") and account["owned_item_ids"] is Array:
		owned_item_ids = account["owned_item_ids"].duplicate()
	if account.has("codex_unlocked_ids") and account["codex_unlocked_ids"] is Array:
		codex_unlocked_ids = account["codex_unlocked_ids"].duplicate()
	if account.has("secret_realm_clears") and account["secret_realm_clears"] is Array:
		secret_realm_clears = account["secret_realm_clears"].duplicate()
	_normalize_progression_state()
	_recalculate_cultivation_rates()
	_prepare_arena_day()

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
	var header := VBoxContainer.new()
	header.add_theme_constant_override("separation", 8)
	var title_row := HBoxContainer.new()
	title_row.add_theme_constant_override("separation", 8)
	header.add_child(title_row)
	header_title_label = _label("乾 坤  ·  TU TIÊN", 25, GOLD_BRIGHT)
	header_title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_row.add_child(header_title_label)
	cloud_status_label = _label("●  Đang tại thế gian", 12, SUCCESS)
	cloud_status_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	cloud_status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	cloud_status_label.custom_minimum_size.x = 145
	title_row.add_child(cloud_status_label)
	var actions := HBoxContainer.new()
	actions.alignment = BoxContainer.ALIGNMENT_END
	actions.add_theme_constant_override("separation", 8)
	header.add_child(actions)
	var save_button := _button("LƯU", GOLD, 92)
	save_button.pressed.connect(save_game)
	actions.add_child(save_button)
	var load_button := _button("TẢI", MUTED, 92)
	load_button.pressed.connect(load_game)
	actions.add_child(load_button)
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
	_set_touch_sizing(view, touch_mode_active)

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
	view.add_child(_build_cultivation_methods_section())
	return view

func _build_cultivation_methods_section() -> Control:
	var section := VBoxContainer.new()
	section.add_theme_constant_override("separation", 6)
	section.add_child(_label("LINH THẠCH · HẤP THỤ", 12, GOLD_BRIGHT))
	var stone_row := GridContainer.new()
	stone_row.columns = 2
	stone_row.add_theme_constant_override("h_separation", 5)
	stone_row.add_theme_constant_override("v_separation", 5)
	for grade in ["Hạ phẩm", "Trung phẩm", "Thượng phẩm", "Cực phẩm"]:
		var amount := _spirit_stone_count(grade)
		var button := _button("%s x%d" % [grade, amount], GOLD if amount > 0 else MUTED, 96)
		button.disabled = amount <= 0 or bool(cultivation.get("body_mode", false)) or collect_cooldown_remaining > 0.0
		button.pressed.connect(_absorb_spirit_stone.bind(grade))
		stone_row.add_child(button)
	section.add_child(stone_row)
	section.add_child(_label("CÔNG PHÁP ĐÃ LĨNH NGỘ", 12, GOLD_BRIGHT))
	var bonus := _cultivation_method_bonus()
	var method_text := "Chưa lĩnh ngộ công pháp" if cultivation_method_ids.is_empty() else "%d công pháp · Tốc độ hấp thu +%d%%" % [cultivation_method_ids.size(), roundi(bonus * 100.0)]
	section.add_child(_label(method_text, 11, MUTED))
	return section

func _cultivation_method_bonus() -> float:
	var bonus := 0.0
	for item_id in cultivation_method_ids:
		var item := _find_item_by_id(item_id)
		if not item.is_empty():
			bonus += 0.10 + float(item.get("rarity_index", 0)) * 0.05
	return bonus

func _learn_cultivation_method(item: Dictionary) -> void:
	var item_id := str(item.get("id", ""))
	if item_id.is_empty() or item.get("category", "") != "CÔNG PHÁP BÍ TỊCH":
		return
	if int(item_inventory.get(item_id, 0)) <= 0:
		_show_notification("Không có công pháp này trong túi đồ", DANGER)
		return
	if item_id in cultivation_method_ids:
		_show_notification("Công pháp đã lĩnh ngộ, hiệu quả được duy trì vĩnh viễn", MUTED)
		return
	cultivation_method_ids.append(item_id)
	_recalculate_cultivation_rates()
	_show_notification("Lĩnh ngộ %s · Tốc độ hấp thu tăng vĩnh viễn" % item.get("name", "Công pháp"), SUCCESS)
	if active_center_tab == "TÚI ĐỒ":
		_render_popup_tab("TÚI ĐỒ")

func _spirit_stone_count(grade: String) -> int:
	if grade == "Hạ phẩm":
		return spirit_stones
	return int(spirit_stone_inventory.get(grade, 0))

func _absorb_spirit_stone(grade: String) -> void:
	if collect_cooldown_remaining > 0.0:
		return
	if bool(cultivation.get("body_mode", false)):
		_show_notification("Chỉ có thể hấp thụ linh thạch ở chế độ Luyện Khí", DANGER)
		return
	if _spirit_stone_count(grade) <= 0:
		return
	if grade == "Hạ phẩm":
		spirit_stones -= 1
	else:
		spirit_stone_inventory[grade] = int(spirit_stone_inventory.get(grade, 0)) - 1
	var value: float = SPIRIT_STONE_VALUES[grade] * (1.0 + _cultivation_method_bonus())
	cultivation["spirit"] += value
	cultivation["cultivation"] += value
	collect_cooldown_remaining = COLLECT_COOLDOWN_SECONDS
	_show_notification("Hấp thụ %s linh thạch · Tu vi +%s" % [grade, _format_number(value)], SUCCESS)
	_update_display()
	if active_center_tab == "TU LUYỆN" and is_instance_valid(center_content):
		_render_center_tab("TU LUYỆN")

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
	view.add_child(_label("LINH THẠCH", 12, GOLD_BRIGHT))
	var stone_counts: Array[String] = []
	for grade in ["Hạ phẩm", "Trung phẩm", "Thượng phẩm", "Cực phẩm"]:
		stone_counts.append("%s x%d" % [grade, _spirit_stone_count(grade)])
	view.add_child(_label(" · ".join(stone_counts), 10, TEXT))
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
		elif item["category"] == "CÔNG PHÁP BÍ TỊCH":
			var learn := _button("LĨNH NGỘ", GOLD, 86)
			learn.disabled = item["id"] in cultivation_method_ids
			learn.pressed.connect(_learn_cultivation_method.bind(item))
			row.add_child(learn)
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
	return int(cultivation.get("realm_index", 0)) * 1000 + int(body_cultivation.get("realm_index", 0)) * 250 + floori(float(spirit_stones) / 10.0)

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
	refresh.pressed.connect(fetch_leaderboard_from_supabase)
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
	arena_content.add_child(_label("Tối đa 3 lượt · Hồi 1 lượt mỗi 5 phút.", 10, MUTED))
	arena_content.add_child(_rule())
	arena_target_label = _label("Chưa chọn đối thủ", 14, TEXT)
	arena_target_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	arena_content.add_child(arena_target_label)
	arena_status_label = _label("Chọn TỈ THÍ trong bảng xếp hạng.", 11, MUTED)
	arena_status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	arena_content.add_child(arena_status_label)
	arena_daily_label = _label("", 12, GOLD)
	arena_daily_label.name = "ArenaDailyCounter"
	arena_content.add_child(arena_daily_label)
	_update_arena_counter()
	arena_content.add_spacer(false)
	arena_content.add_child(_label("Thưởng cơ bản: 100 - 500 Linh Thạch\nTỉ lệ thắng dựa trên lực chiến và cảnh giới.", 10, MUTED))
	if not leaderboard_loaded and not leaderboard_loading:
		fetch_leaderboard_from_supabase()
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
		arena_recovery_unix = 0
	arena_challenges_today = clampi(arena_challenges_today, 0, ARENA_MAX_CHALLENGES)
	var now := int(Time.get_unix_time_from_system())
	if arena_challenges_today == 0:
		arena_recovery_unix = 0
	elif arena_recovery_unix <= 0:
		arena_recovery_unix = now + ARENA_RECOVERY_SECONDS
	elif now >= arena_recovery_unix:
		var recovered_charges := 1 + floori(float(now - arena_recovery_unix) / float(ARENA_RECOVERY_SECONDS))
		var restored := mini(arena_challenges_today, recovered_charges)
		arena_challenges_today -= restored
		if arena_challenges_today == 0:
			arena_recovery_unix = 0
		else:
			arena_recovery_unix += restored * ARENA_RECOVERY_SECONDS
	if is_authenticated:
		authenticated_account["arena_challenges_today"] = arena_challenges_today
		authenticated_account["arena_last_day"] = arena_last_day
		authenticated_account["arena_recovery_unix"] = arena_recovery_unix
	_update_arena_counter()

func _update_arena_counter() -> void:
	if not is_instance_valid(arena_daily_label):
		return
	var available := ARENA_MAX_CHALLENGES - arena_challenges_today
	if available >= ARENA_MAX_CHALLENGES or arena_recovery_unix <= 0:
		arena_daily_label.text = "Lượt tỉ thí: %d / %d · Đầy" % [available, ARENA_MAX_CHALLENGES]
		return
	var remaining := maxi(0, arena_recovery_unix - int(Time.get_unix_time_from_system()))
	var minutes := remaining / 60
	var seconds := remaining % 60
	arena_daily_label.text = "Lượt tỉ thí: %d / %d · Hồi lượt sau %02d:%02d" % [available, ARENA_MAX_CHALLENGES, minutes, seconds]

func _challenge_opponent(opponent: Dictionary) -> void:
	if str(opponent.get("name", "")).strip_edges() == current_username:
		_show_notification("Không thể tỉ thí với chính mình", DANGER)
		return
	_prepare_arena_day()
	if arena_challenges_today >= ARENA_MAX_CHALLENGES:
		_update_arena_counter()
		_show_notification("Đã dùng hết lượt tỉ thí · Lượt kế tiếp sau 5 phút", DANGER)
		return
	if is_instance_valid(active_combat):
		return
	var player_power := _base_combat_power() + _equipment_power()
	var player_data := {
		"name": current_username if not current_username.is_empty() else "Đạo hữu",
		"realm": str(cultivation.get("realm_name", "Phàm Nhân")),
		"realm_index": int(cultivation.get("realm_index", 0)),
		"power": player_power,
		"attack": 16.0 + float(player_power) * 0.035,
		"max_hp": 180.0 + float(player_power) * 0.18,
		"max_mp": 60.0 + float(cultivation.get("realm_index", 0)) * 4.0,
	}
	var enemy_data := {
		"name": str(opponent.get("name", "Đạo hữu vô danh")),
		"realm": str(opponent.get("qi_realm", "Phàm Nhân")),
		"realm_index": int(opponent.get("realm_index", 0)),
		"power": int(opponent.get("power", 0)),
	}
	var available_pills: Array[Dictionary] = []
	for pill in elixirs:
		var pill_id := str(pill.get("id", ""))
		var count := int(item_inventory.get(pill_id, pill.get("count", 0)))
		if count > 0:
			available_pills.append({"id": pill_id, "name": str(pill.get("name", "Linh đan")), "count": count})
	active_combat = COMBAT_SCENE.instantiate() as Control
	if active_combat == null:
		_show_notification("Không thể khởi tạo bảng tỉ thí", DANGER)
		return
	active_combat.name = "ActiveCombatManager"
	active_combat.z_index = 120
	active_combat.mouse_filter = Control.MOUSE_FILTER_STOP
	if not active_combat.has_method("start_combat"):
		active_combat.queue_free()
		active_combat = null
		_show_notification("CombatManager thiếu hàm start_combat", DANGER)
		return
	var signal_error := active_combat.connect("combat_finished", Callable(self, "_on_combat_finished").bind(opponent.duplicate(true)))
	if signal_error != OK:
		active_combat.queue_free()
		active_combat = null
		_show_notification("Không thể kết nối kết quả trận tỉ thí", DANGER)
		return
	add_child(active_combat)
	active_combat.call("start_combat", player_data, enemy_data, available_pills)

func _on_combat_finished(result: Dictionary, opponent: Dictionary) -> void:
	active_combat = null
	if arena_challenges_today == 0:
		arena_recovery_unix = int(Time.get_unix_time_from_system()) + ARENA_RECOVERY_SECONDS
	arena_challenges_today = mini(ARENA_MAX_CHALLENGES, arena_challenges_today + 1)
	_prepare_arena_day()
	var outcome := str(result.get("result", "defeat"))
	for pill_id in result.get("consumed_pills", {}):
		var used_count := int(result["consumed_pills"][pill_id])
		item_inventory[pill_id] = maxi(0, int(item_inventory.get(pill_id, 0)) - used_count)
	_sync_elixir_counts_from_inventory()
	var message: String
	var message_color := DANGER
	if outcome == "victory":
		var opponent_power := int(opponent.get("power", 0))
		var reward := clampi(100 + floori(float(opponent_power) / 1000.0) + randi_range(0, 200), 100, 700)
		spirit_stones += reward
		var cultivation_reward := maxf(100.0, float(opponent_power) * 0.5)
		cultivation["cultivation"] = minf(float(cultivation["cultivation_need"]), float(cultivation["cultivation"]) + cultivation_reward)
		cultivation["spirit"] += cultivation_reward
		message = "Tỉ thí thắng · +%s Linh Thạch · Tu vi +%s" % [_format_number(reward), _format_number(cultivation_reward)]
		message_color = SUCCESS
	elif outcome == "retreat":
		message = "Đã rút lui khỏi trận tỉ thí · Đã dùng 1 lượt hôm nay"
	else:
		message = "Tỉ thí thất bại · Tiến trình tu luyện được bảo toàn"
	_show_notification(message, message_color)
	if is_instance_valid(popup_body) and active_center_tab == "BẢNG XẾP HẠNG":
		_render_popup_tab("BẢNG XẾP HẠNG")
	_update_arena_counter()
	_update_display()
	if is_authenticated:
		save_game()

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
	var stage_multiplier := pow(1.18, float(index))
	var major_realm_index := floori(float(index) / 40.0)
	var major_realm_multiplier := pow(3.0, float(major_realm_index))
	return snappedf(12.0 * stage_multiplier * major_realm_multiplier * (1.0 + _cultivation_method_bonus()), 0.1)

func _calculate_body_speed_for_realm(realm_index: int) -> float:
	var index := maxi(realm_index, 0)
	var stage_multiplier := pow(1.16, float(index % BODY_REALMS.size()))
	var body_realm_index := floori(float(index) / float(BODY_REALMS.size()))
	var body_realm_multiplier := pow(2.0, float(body_realm_index))
	return snappedf(10.0 * stage_multiplier * body_realm_multiplier, 0.1)

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
	_ensure_elixir_entries()
	_sync_elixir_counts_from_inventory()
	var panel := _panel(340)
	var content := panel.get_child(0).get_child(0) as VBoxContainer
	content.add_child(_label("ĐAN DƯỢC", 22, GOLD_BRIGHT))
	content.add_child(_label("Danh mục đầy đủ · %d loại" % ELIXIR_DEFINITIONS.size(), 11, MUTED))
	content.add_child(_rule())
	var scroll := ScrollContainer.new()
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	scroll.clip_contents = true
	content.add_child(scroll)
	elixir_list = VBoxContainer.new()
	elixir_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	elixir_list.size_flags_vertical = Control.SIZE_EXPAND_FILL
	elixir_list.add_theme_constant_override("separation", 6)
	scroll.add_child(elixir_list)
	for elixir in elixirs:
		_add_elixir_row(elixir)
	return panel

func _add_elixir_row(elixir: Dictionary) -> void:
	var current_count := int(elixir.get("count", 0))
	var row := PanelContainer.new()
	row.custom_minimum_size.y = 92
	row.add_theme_stylebox_override("panel", _style(Color("#0b2922") if current_count > 0 else Color("#091d18"), 5, Color("#28624e") if current_count > 0 else Color("#244136"), 1))
	var layout := HBoxContainer.new()
	layout.add_theme_constant_override("separation", 7)
	row.add_child(layout)
	var icon := _label("✧", 25, GOLD)
	icon.custom_minimum_size.x = 38
	icon.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	layout.add_child(icon)
	var details := VBoxContainer.new()
	details.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	details.alignment = BoxContainer.ALIGNMENT_CENTER
	var title := _label(str(elixir.get("name", "Đan dược")), 12, GOLD_BRIGHT if current_count > 0 else MUTED)
	title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	details.add_child(title)
	var description := _label(elixir["description"], 10, MUTED)
	description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	details.add_child(description)
	var stock_status := _label("SẴN SÀNG" if current_count > 0 else "HẾT KHO · " + str(elixir.get("source", "Tìm trong bí cảnh")), 9, SUCCESS if current_count > 0 else DANGER)
	stock_status.name = "StockStatus"
	stock_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	details.add_child(stock_status)
	layout.add_child(details)
	var count := _label("x" + str(current_count), 11, TEXT if current_count > 0 else MUTED)
	count.custom_minimum_size.x = 28
	count.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	count.name = "StockCount"
	layout.add_child(count)
	var use := _button("DÙNG", GOLD, 64)
	use.disabled = current_count <= 0
	use.modulate.a = 0.48 if current_count <= 0 else 1.0
	use.pressed.connect(_use_elixir.bind(elixir, count, stock_status, use))
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
		tab.set_meta("responsive_base_font_size", 10)
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
	button.set_meta("responsive_base_height", 44.0)
	button.set_meta("responsive_base_font_size", 12)
	if touch_mode_active:
		button.custom_minimum_size.y = 52
		button.add_theme_font_size_override("font_size", 14)
	button.add_theme_color_override("font_color", color)
	button.add_theme_color_override("font_hover_color", GOLD_BRIGHT)
	button.add_theme_stylebox_override("normal", _style(Color("#102f27"), 4, Color("#80632f"), 1))
	button.add_theme_stylebox_override("hover", _style(Color("#1b493b"), 4, GOLD, 1))
	button.add_theme_stylebox_override("pressed", _style(Color("#071f1a"), 4, GOLD_BRIGHT, 1))
	button.add_theme_stylebox_override("focus", _style(Color("#102f27"), 4, GOLD_BRIGHT, 2))
	button.mouse_entered.connect(_animate_button.bind(button, true, false))
	button.mouse_exited.connect(_animate_button.bind(button, false, false))
	button.button_down.connect(_animate_button.bind(button, true, true))
	button.button_up.connect(_animate_button.bind(button, true, false))
	return button

func _set_touch_sizing(node: Node, enabled: bool) -> void:
	for child in node.get_children():
		if child is Button:
			if not child.has_meta("responsive_base_height"):
				child.set_meta("responsive_base_height", child.custom_minimum_size.y)
				child.set_meta("responsive_base_font_size", child.get_theme_font_size("font_size"))
			var base_height := float(child.get_meta("responsive_base_height", 44.0))
			var base_font_size := int(child.get_meta("responsive_base_font_size", 12))
			child.custom_minimum_size.y = maxf(base_height, 52.0) if enabled else base_height
			child.add_theme_font_size_override("font_size", base_font_size + 2 if enabled else base_font_size)
		elif child is ScrollContainer:
			var vertical_bar = child.get_v_scroll_bar()
			var horizontal_bar = child.get_h_scroll_bar()
			if not child.has_meta("responsive_v_scroll_width"):
				child.set_meta("responsive_v_scroll_width", vertical_bar.custom_minimum_size.x)
				child.set_meta("responsive_h_scroll_height", horizontal_bar.custom_minimum_size.y)
				child.set_meta("responsive_v_grabber", vertical_bar.get_theme_constant("grabber_min_size"))
				child.set_meta("responsive_h_grabber", horizontal_bar.get_theme_constant("grabber_min_size"))
			vertical_bar.custom_minimum_size.x = 22.0 if enabled else float(child.get_meta("responsive_v_scroll_width", 0.0))
			horizontal_bar.custom_minimum_size.y = 22.0 if enabled else float(child.get_meta("responsive_h_scroll_height", 0.0))
			vertical_bar.add_theme_constant_override("grabber_min_size", 44 if enabled else int(child.get_meta("responsive_v_grabber", 12)))
			horizontal_bar.add_theme_constant_override("grabber_min_size", 44 if enabled else int(child.get_meta("responsive_h_grabber", 12)))
			child.add_theme_constant_override("scrollbar_v_separation", 3 if enabled else 0)
			child.add_theme_constant_override("scrollbar_h_separation", 3 if enabled else 0)
		elif child is GridContainer:
			if not child.has_meta("responsive_h_separation"):
				child.set_meta("responsive_h_separation", child.get_theme_constant("h_separation"))
				child.set_meta("responsive_v_separation", child.get_theme_constant("v_separation"))
			var base_h := int(child.get_meta("responsive_h_separation", 0))
			var base_v := int(child.get_meta("responsive_v_separation", 0))
			child.add_theme_constant_override("h_separation", base_h + 3 if enabled else base_h)
			child.add_theme_constant_override("v_separation", base_v + 3 if enabled else base_v)
		elif child is BoxContainer:
			if not child.has_meta("responsive_separation"):
				child.set_meta("responsive_separation", child.get_theme_constant("separation"))
			var base_separation := int(child.get_meta("responsive_separation", 0))
			child.add_theme_constant_override("separation", base_separation + 2 if enabled else base_separation)
		elif child is LineEdit:
			if not child.has_meta("responsive_base_height"):
				child.set_meta("responsive_base_height", child.custom_minimum_size.y)
				child.set_meta("responsive_base_font_size", child.get_theme_font_size("font_size"))
			var base_height := float(child.get_meta("responsive_base_height", 0.0))
			var base_font_size := int(child.get_meta("responsive_base_font_size", 14))
			child.custom_minimum_size.y = maxf(base_height, 48.0) if enabled else base_height
			child.add_theme_font_size_override("font_size", maxi(base_font_size, 16) if enabled else base_font_size)
		elif child is Label:
			if not child.has_meta("responsive_base_font_size"):
				child.set_meta("responsive_base_font_size", child.get_theme_font_size("font_size"))
			var base_font_size := int(child.get_meta("responsive_base_font_size", 12))
			child.add_theme_font_size_override("font_size", base_font_size + 1 if enabled and base_font_size <= 14 else base_font_size)
		_set_touch_sizing(child, enabled)

func _animate_button(button: Button, hovered: bool, pressed: bool) -> void:
	if not is_instance_valid(button):
		return
	button.pivot_offset = button.size * 0.5
	var scale_factor := 0.96 if pressed else (1.035 if hovered else 1.0)
	if button.has_meta("ui_scale_tween"):
		var previous_tween: Variant = button.get_meta("ui_scale_tween")
		if previous_tween is Tween and previous_tween.is_running():
			previous_tween.kill()
	var tween := button.create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	button.set_meta("ui_scale_tween", tween)
	tween.tween_property(button, "scale", Vector2.ONE * scale_factor, 0.12)

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
	_animate_progress_bar(left_bar, minf(current / needed * 100.0, 100.0))
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
	_update_collect_button_state()

func _update_body_display() -> void:
	var current := body_cultivation["power"] as float
	var needed := body_cultivation["power_need"] as float
	left_title_label.text = "CẢNH GIỚI LUYỆN THỂ"
	left_realm_label.text = body_cultivation["realm_name"]
	_animate_progress_bar(left_bar, minf(current / needed * 100.0, 100.0))
	left_value_label.text = "Thể phách: " + _format_number(current) + "  /  " + _format_number(needed)
	left_subtitle_mat_label.text = "CHỈ SỐ THỂ PHÁCH"
	left_energy_title_label.text = "KHÍ HUYẾT"
	left_status_label.text = "Đủ lực lượng để đột phá" if current >= needed else "Đang tôi luyện thân thể..."
	left_status_label.add_theme_color_override("font_color", SUCCESS if current >= needed else MUTED)
	left_collect_button.text = "RÈN THỂ"
	left_action_button.text = "✦  ĐỘT PHÁ" if touch_mode_active else "✦  ĐỘT PHÁ LƯỢNG THỂ"
	left_action_button.disabled = current < needed
	spirit_label.text = "Khí huyết: " + _format_number(body_cultivation["blood"]) + "  /  +" + _format_number(body_cultivation["blood_per_second"]) + "/s"
	for material_row in left_material_rows:
		material_row.visible = false
	backlash_label.text = "Độ cứng cốt: " + _format_number(body_cultivation["power"] * 0.5)
	_update_collect_button_state()

func _update_collect_button_state() -> void:
	if not is_instance_valid(left_collect_button):
		return
	var cooling_down := collect_cooldown_remaining > 0.0
	left_collect_button.disabled = cooling_down
	left_collect_button.modulate = Color(1.0, 1.0, 1.0, 0.5) if cooling_down else Color.WHITE
	if cooling_down:
		left_collect_button.text = "CHỜ %.1fs" % collect_cooldown_remaining

func _animate_progress_bar(bar: ProgressBar, target_value: float) -> void:
	if not is_instance_valid(bar):
		return
	if progress_tween != null and progress_tween.is_running():
		progress_tween.kill()
	progress_tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	progress_tween.tween_property(bar, "value", target_value, UI_REFRESH_INTERVAL_SECONDS)

func _format_number(value: float) -> String:
	var raw := str(int(value))
	var formatted := ""
	while raw.length() > 3:
		formatted = "." + raw.substr(raw.length() - 3) + formatted
		raw = raw.substr(0, raw.length() - 3)
	return raw + formatted

func _collect_spirit() -> void:
	if collect_cooldown_remaining > 0.0:
		return
	var collected: float = cultivation["spirit_per_second"] * COLLECT_COOLDOWN_SECONDS * absorb_bonus
	cultivation["spirit"] += collected
	cultivation["cultivation"] += collected
	collect_cooldown_remaining = COLLECT_COOLDOWN_SECONDS
	_show_notification("Đã nhận " + _format_number(collected) + " Linh Khí")

func _collect_current_energy() -> void:
	if collect_cooldown_remaining > 0.0:
		return
	if cultivation["body_mode"]:
		var trained_power: float = body_cultivation["blood_per_second"] * COLLECT_COOLDOWN_SECONDS
		body_cultivation["blood"] += trained_power
		body_cultivation["power"] += trained_power
		collect_cooldown_remaining = COLLECT_COOLDOWN_SECONDS
		_show_notification("Đã rèn thể, khí huyết tăng " + _format_number(trained_power), SUCCESS)
	else:
		_collect_spirit()

func _build_breakthrough_minigame() -> void:
	breakthrough_overlay = Control.new()
	breakthrough_overlay.name = "BreakthroughMinigame"
	breakthrough_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	breakthrough_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	breakthrough_overlay.z_index = 120
	breakthrough_overlay.visible = false
	add_child(breakthrough_overlay)
	var dimmer := ColorRect.new()
	dimmer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dimmer.color = Color(0.015, 0.035, 0.05, 0.86)
	dimmer.mouse_filter = Control.MOUSE_FILTER_STOP
	breakthrough_overlay.add_child(dimmer)
	breakthrough_panel = PanelContainer.new()
	breakthrough_panel.anchor_left = 0.5
	breakthrough_panel.anchor_top = 0.5
	breakthrough_panel.anchor_right = 0.5
	breakthrough_panel.anchor_bottom = 0.5
	breakthrough_panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
	breakthrough_panel.grow_vertical = Control.GROW_DIRECTION_BOTH
	breakthrough_panel.add_theme_stylebox_override("panel", _style(Color("#0b2922"), 10, Color("#8bd8f0"), 2))
	breakthrough_overlay.add_child(breakthrough_panel)
	var margin := MarginContainer.new()
	for side in ["left", "top", "right", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 18)
	breakthrough_panel.add_child(margin)
	var layout := VBoxContainer.new()
	layout.add_theme_constant_override("separation", 12)
	margin.add_child(layout)
	var title := _label("DẪN KHÍ · ĐỊNH TÂM ĐỘT PHÁ", 18, GOLD_BRIGHT)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	layout.add_child(title)
	var instruction := _label("Dừng kim trong vùng vàng để tăng cơ hội vượt lôi kiếp", 11, MUTED)
	instruction.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	instruction.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	layout.add_child(instruction)
	breakthrough_chance_label = _label("", 12, SUCCESS)
	breakthrough_chance_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	layout.add_child(breakthrough_chance_label)
	breakthrough_meter_track = Control.new()
	breakthrough_meter_track.custom_minimum_size.y = 34
	breakthrough_meter_track.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	breakthrough_meter_track.clip_contents = true
	var track_background := ColorRect.new()
	track_background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	track_background.color = Color("#061610")
	track_background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	breakthrough_meter_track.add_child(track_background)
	var target_zone := ColorRect.new()
	target_zone.anchor_left = 0.62
	target_zone.anchor_right = 0.78
	target_zone.anchor_bottom = 1.0
	target_zone.color = Color(0.84, 0.66, 0.26, 0.62)
	target_zone.mouse_filter = Control.MOUSE_FILTER_IGNORE
	breakthrough_meter_track.add_child(target_zone)
	breakthrough_meter_marker = ColorRect.new()
	breakthrough_meter_marker.anchor_top = 0.0
	breakthrough_meter_marker.anchor_bottom = 1.0
	breakthrough_meter_marker.offset_left = -2.0
	breakthrough_meter_marker.offset_right = 2.0
	breakthrough_meter_marker.color = Color("#e5f6ff")
	breakthrough_meter_marker.mouse_filter = Control.MOUSE_FILTER_IGNORE
	breakthrough_meter_track.add_child(breakthrough_meter_marker)
	layout.add_child(breakthrough_meter_track)
	var legend := _label("◀ 0%                         VÙNG ĐỊNH MỆNH 62-78%                         100% ▶", 10, MUTED)
	legend.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	legend.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	layout.add_child(legend)
	var actions := HBoxContainer.new()
	actions.add_theme_constant_override("separation", 8)
	var cancel_button := _button("RÚT LUI", MUTED, -1)
	cancel_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	cancel_button.pressed.connect(_cancel_breakthrough_minigame)
	actions.add_child(cancel_button)
	var stop_button := _button("DỪNG · SPACE", GOLD_BRIGHT, -1)
	stop_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	stop_button.pressed.connect(_resolve_breakthrough_minigame)
	actions.add_child(stop_button)
	layout.add_child(actions)
	_set_touch_sizing(breakthrough_overlay, touch_mode_active)
	_update_responsive_layout()

func _open_breakthrough_minigame() -> void:
	var current := float(body_cultivation["power"]) if cultivation["body_mode"] else float(cultivation["cultivation"])
	var required := float(body_cultivation["power_need"]) if cultivation["body_mode"] else float(cultivation["cultivation_need"])
	if current < required:
		_show_notification("Tu vi hoặc thể phách chưa đủ để đột phá", DANGER)
		return
	if not is_instance_valid(breakthrough_overlay):
		_build_breakthrough_minigame()
	breakthrough_meter_value = randf_range(0.0, 25.0)
	breakthrough_meter_direction = 1.0
	breakthrough_meter_marker.anchor_left = breakthrough_meter_value / 100.0
	breakthrough_meter_marker.anchor_right = breakthrough_meter_marker.anchor_left
	var base_chance := _base_current_breakthrough_chance()
	breakthrough_chance_label.text = "Tỷ lệ nền: %d%% · Vùng vàng cộng tối đa 23%%" % roundi(base_chance * 100.0)
	breakthrough_minigame_active = true
	breakthrough_overlay.visible = true
	breakthrough_overlay.modulate.a = 0.0
	breakthrough_panel.scale = Vector2(0.96, 0.96)
	breakthrough_minigame_tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	breakthrough_minigame_tween.set_parallel(true)
	breakthrough_minigame_tween.tween_property(breakthrough_overlay, "modulate:a", 1.0, 0.16)
	breakthrough_minigame_tween.tween_property(breakthrough_panel, "scale", Vector2.ONE, 0.16)

func _update_breakthrough_minigame(delta: float) -> void:
	breakthrough_meter_value += breakthrough_meter_direction * 88.0 * delta
	if breakthrough_meter_value >= 100.0:
		breakthrough_meter_value = 100.0
		breakthrough_meter_direction = -1.0
	elif breakthrough_meter_value <= 0.0:
		breakthrough_meter_value = 0.0
		breakthrough_meter_direction = 1.0
	if is_instance_valid(breakthrough_meter_marker):
		breakthrough_meter_marker.anchor_left = breakthrough_meter_value / 100.0
		breakthrough_meter_marker.anchor_right = breakthrough_meter_marker.anchor_left

func _timing_bonus_at_position(position_value: float) -> float:
	if position_value < 62.0 or position_value > 78.0:
		return 0.0
	return 0.05 + (1.0 - absf(position_value - 70.0) / 8.0) * 0.18

func _resolve_breakthrough_minigame() -> void:
	if not breakthrough_minigame_active:
		return
	breakthrough_minigame_active = false
	breakthrough_timing_bonus = _timing_bonus_at_position(breakthrough_meter_value)
	if is_instance_valid(breakthrough_overlay):
		breakthrough_overlay.visible = false
	if cultivation["body_mode"]:
		_attempt_body_breakthrough()
	else:
		_attempt_breakthrough()
	breakthrough_timing_bonus = 0.0

func _timing_result_suffix() -> String:
	if breakthrough_timing_bonus <= 0.0:
		return ""
	return " · Định tâm +%d%%" % roundi(breakthrough_timing_bonus * 100.0)

func _cancel_breakthrough_minigame() -> void:
	breakthrough_minigame_active = false
	if is_instance_valid(breakthrough_overlay):
		breakthrough_overlay.visible = false

func _base_current_breakthrough_chance() -> float:
	if cultivation["body_mode"]:
		var body_index := int(body_cultivation["realm_index"])
		return clampf(0.72 - float(body_index) * 0.06, 0.32, 0.72)
	return _breakthrough_chance(int(cultivation["realm_index"]))

func _play_tribulation_effect() -> void:
	if tribulation_active:
		return
	tribulation_active = true
	var flash := ColorRect.new()
	flash.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	flash.color = Color("#d9efff")
	flash.modulate.a = 0.0
	flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	flash.z_index = 90
	add_child(flash)
	var bolts: Array[Line2D] = []
	var viewport_size := get_viewport_rect().size
	for bolt_index in range(3):
		var bolt := Line2D.new()
		bolt.width = 3.0 if bolt_index > 0 else 5.0
		bolt.default_color = Color("#bceaff") if bolt_index == 0 else Color("#f0f8ff")
		bolt.z_index = 91
		var points := PackedVector2Array()
		var x_position := randf_range(viewport_size.x * 0.25, viewport_size.x * 0.75)
		points.append(Vector2(x_position, 0.0))
		for point_index in range(1, 9):
			x_position = clampf(x_position + randf_range(-70.0, 70.0), 0.0, viewport_size.x)
			points.append(Vector2(x_position, viewport_size.y * float(point_index) / 9.0))
		bolt.points = points
		bolt.modulate.a = 0.0
		add_child(bolt)
		bolts.append(bolt)
	var flash_tween := create_tween()
	flash_tween.tween_property(flash, "modulate:a", 0.78, 0.045)
	flash_tween.tween_property(flash, "modulate:a", 0.12, 0.09)
	flash_tween.tween_property(flash, "modulate:a", 0.52, 0.035)
	flash_tween.tween_property(flash, "modulate:a", 0.0, 0.28)
	flash_tween.tween_callback(func():
		if is_instance_valid(flash):
			flash.queue_free()
		for bolt in bolts:
			if is_instance_valid(bolt):
				bolt.queue_free()
		tribulation_active = false
	)
	for bolt in bolts:
		var bolt_tween := create_tween()
		bolt_tween.tween_property(bolt, "modulate:a", 1.0, 0.04)
		bolt_tween.tween_property(bolt, "modulate:a", 0.0, 0.38)

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
			_play_tribulation_effect()
			_show_notification("Đột phá thành công! Đã đạt " + next_level["name"] + " · Tốc độ tu luyện tăng " + str(_format_number(cultivation["spirit_per_second"])) + "/s" + _timing_result_suffix(), SUCCESS)
		else:
			_show_notification("Đã chạm đỉnh hệ thống tu vi hiện tại", SUCCESS)
	else:
		var loss_ratio := randf_range(0.20, 0.35)
		cultivation["cultivation"] *= 1.0 - loss_ratio
		cultivation["backlash_seconds"] = 30.0
		_show_notification("Đột phá thất bại, mất " + str(roundi(loss_ratio * 100.0)) + "% tu vi. Phản phệ giáng lâm." + _timing_result_suffix(), DANGER)
	_update_display()

func _attempt_current_breakthrough() -> void:
	_open_breakthrough_minigame()

func _attempt_body_breakthrough() -> void:
	var current := body_cultivation["power"] as float
	var needed := body_cultivation["power_need"] as float
	if current < needed:
		_show_notification("Thể phách chưa đủ để đột phá", DANGER)
		return
	var realm_index: int = body_cultivation["realm_index"]
	var success_chance := clampf(0.72 - float(realm_index) * 0.06 + breakthrough_timing_bonus, 0.32, 0.93)
	if randf() <= success_chance:
		if realm_index < BODY_REALMS.size() - 1:
			var next_index := realm_index + 1
			body_cultivation["realm_index"] = next_index
			body_cultivation["realm_name"] = BODY_REALMS[next_index]
			body_cultivation["power"] = 0.0
			body_cultivation["power_need"] = snappedf(needed * minf(2.0 + float(next_index) * 0.08, 2.5), 1.0)
			_recalculate_cultivation_rates()
			_play_tribulation_effect()
			_show_notification("Lượng thể đột phá thành công: " + BODY_REALMS[next_index] + " · Tốc độ rèn thể tăng " + str(_format_number(body_cultivation["blood_per_second"])) + "/s" + _timing_result_suffix(), SUCCESS)
		else:
			_show_notification("Thân thể đã đạt Kim Cương Thể", SUCCESS)
	else:
		var loss_ratio := randf_range(0.20, 0.35)
		body_cultivation["power"] *= 1.0 - loss_ratio
		body_cultivation["blood"] *= 0.85
		_show_notification("Luyện thể thất bại, mất " + str(roundi(loss_ratio * 100.0)) + "% thể phách và khí huyết." + _timing_result_suffix(), DANGER)
	_update_display()

func _breakthrough_chance(realm_index: int) -> float:
	return clampf(0.68 - float(realm_index) * 0.02 + breakthrough_bonus + breakthrough_timing_bonus, 0.20, 0.93)

func _next_cultivation_need(previous_need: float, next_index: int) -> float:
	var multiplier := minf(2.0 + float(next_index) * 0.025, 2.5)
	return snappedf(previous_need * multiplier, 1.0)

func _use_elixir(elixir: Dictionary, count_label: Label, stock_status: Label, button: Button) -> void:
	var elixir_id := str(elixir.get("id", ""))
	var definition: Dictionary = elixir_definition_by_id.get(elixir_id, {})
	if definition.is_empty():
		_show_notification("Không tìm thấy định nghĩa đan dược: " + elixir_id, DANGER)
		return
	var effect := str(definition.get("effect", ""))
	if effect not in ["absorb", "breakthrough", "spirit", "body", "shield"]:
		_show_notification("Hiệu ứng đan dược không hợp lệ: " + effect, DANGER)
		return
	var current_count := int(item_inventory.get(elixir_id, elixir.get("count", 0)))
	if current_count <= 0:
		_show_notification("Đan dược đã hết trong kho", DANGER)
		count_label.text = "x0"
		stock_status.text = "HẾT KHO · " + str(definition.get("source", "Tìm trong bí cảnh"))
		button.disabled = true
		button.modulate.a = 0.48
		return
	current_count -= 1
	elixir["count"] = current_count
	item_inventory[elixir_id] = current_count
	_register_codex_unlock(elixir_id)
	count_label.text = "x" + str(current_count)
	stock_status.text = "SẴN SÀNG" if current_count > 0 else "HẾT KHO · " + str(definition.get("source", "Tìm trong bí cảnh"))
	stock_status.add_theme_color_override("font_color", SUCCESS if current_count > 0 else DANGER)
	count_label.add_theme_color_override("font_color", TEXT if current_count > 0 else MUTED)
	button.disabled = current_count == 0
	button.modulate.a = 0.48 if current_count == 0 else 1.0
	_apply_elixir_effect(definition)
	_update_display()

func _apply_elixir_effect(definition: Dictionary) -> void:
	var effect_value := float(definition.get("effect_value", 0.0))
	var elixir_name := str(definition.get("name", "Đan dược"))
	match str(definition.get("effect", "")):
		"absorb":
			absorb_bonus += effect_value
			_show_notification("%s · Tốc độ hấp thu vĩnh viễn +%d%%" % [elixir_name, roundi(effect_value * 100.0)], SUCCESS)
		"breakthrough":
			breakthrough_bonus += effect_value
			_show_notification("%s · Tỷ lệ đột phá vĩnh viễn +%d%%" % [elixir_name, roundi(effect_value * 100.0)], SUCCESS)
		"spirit":
			cultivation["spirit"] += effect_value
			cultivation["cultivation"] += effect_value
			_show_notification("%s · Tu vi và linh khí +%s" % [elixir_name, _format_number(effect_value)], SUCCESS)
		"body":
			body_cultivation["power"] += effect_value
			body_cultivation["blood"] += effect_value
			_show_notification("%s · Thể phách và khí huyết +%s" % [elixir_name, _format_number(effect_value)], SUCCESS)
		"shield":
			_show_notification("%s · Hộ thể đã được kích hoạt" % elixir_name, SUCCESS)

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
	if popup_tween != null and popup_tween.is_running():
		popup_tween.kill()
	var should_animate := not popup_overlay.visible or popup_closing
	popup_overlay.visible = true
	popup_closing = false
	if should_animate:
		popup_overlay.modulate.a = 0.0
		feature_popup_panel.scale = Vector2(0.94, 0.94)
		popup_tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		popup_tween.set_parallel(true)
		popup_tween.tween_property(popup_overlay, "modulate:a", 1.0, 0.2)
		popup_tween.tween_property(feature_popup_panel, "scale", Vector2.ONE, 0.2)

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
	_set_touch_sizing(view, touch_mode_active)

func _close_center_popup() -> void:
	if is_instance_valid(popup_overlay) and popup_overlay.visible and not popup_closing:
		popup_closing = true
		if popup_tween != null and popup_tween.is_running():
			popup_tween.kill()
		popup_tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
		popup_tween.set_parallel(true)
		popup_tween.tween_property(popup_overlay, "modulate:a", 0.0, 0.14)
		popup_tween.tween_property(feature_popup_panel, "scale", Vector2(0.96, 0.96), 0.14)
		popup_tween.chain().tween_callback(_finish_popup_close)
	active_center_tab = "TU LUYỆN"

func _finish_popup_close() -> void:
	if is_instance_valid(popup_overlay):
		popup_overlay.visible = false
		popup_overlay.modulate.a = 1.0
	if is_instance_valid(feature_popup_panel):
		feature_popup_panel.scale = Vector2.ONE
	popup_closing = false

func _on_popup_dimmer_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_close_center_popup()

func _show_notification(message: String, color: Color = GOLD_BRIGHT) -> void:
	append_global_log(message)
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

func _supabase_headers(with_auth: bool = true, extra_headers: PackedStringArray = PackedStringArray()) -> PackedStringArray:
	var headers := PackedStringArray(["Content-Type: application/json", "apikey: " + SUPABASE_KEY])
	if with_auth and not supabase_access_token.is_empty():
		headers.append("Authorization: Bearer " + supabase_access_token)
	for header in extra_headers:
		headers.append(header)
	return headers

func _refresh_supabase_session() -> void:
	if supabase_refresh_token.is_empty() or str(supabase_active_request.get("action", "")) == "refresh" or _supabase_queue_has_action("refresh"):
		return
	supabase_token_elapsed = 0.0
	var endpoint := SUPABASE_AUTH_URL + "/token?grant_type=refresh_token"
	_enqueue_supabase_request("refresh", endpoint, HTTPClient.METHOD_POST, JSON.stringify({"refresh_token": supabase_refresh_token}), false)

func _enqueue_supabase_request(action: String, endpoint: String, method: HTTPClient.Method, body: String = "", with_auth: bool = true, extra_headers: PackedStringArray = PackedStringArray()) -> void:
	if action == "save" and (str(supabase_active_request.get("action", "")) == "save" or _supabase_queue_has_action("save")):
		return
	supabase_request_queue.append({"action": action, "endpoint": endpoint, "method": method, "body": body, "with_auth": with_auth, "headers": extra_headers})
	_start_next_supabase_request()

func _supabase_queue_has_action(action: String) -> bool:
	for request_data in supabase_request_queue:
		if str(request_data.get("action", "")) == action:
			return true
	return false

func _start_next_supabase_request() -> void:
	if not supabase_active_request.is_empty() or supabase_request_queue.is_empty() or not is_instance_valid(http_request):
		return
	supabase_active_request = supabase_request_queue.pop_front()
	var endpoint := str(supabase_active_request["endpoint"])
	var headers: PackedStringArray = _supabase_headers(bool(supabase_active_request["with_auth"]), supabase_active_request["headers"])
	var error := http_request.request(endpoint, headers, int(supabase_active_request["method"]), str(supabase_active_request["body"]))
	if error != OK:
		var failed_action := str(supabase_active_request["action"])
		supabase_active_request.clear()
		_handle_supabase_request_error(failed_action, "Không thể gửi request đến Supabase.")
		_start_next_supabase_request()

func _request_error_message(body: PackedByteArray, fallback: String) -> String:
	var parsed: Variant = JSON.parse_string(body.get_string_from_utf8())
	if parsed is Dictionary:
		return str(parsed.get("msg", parsed.get("message", parsed.get("error_description", parsed.get("error", fallback)))))
	return fallback

func _handle_supabase_request_error(action: String, message: String) -> void:
	if action in ["login", "signup", "refresh"]:
		if action == "refresh":
			supabase_access_token = ""
			supabase_refresh_token = ""
			is_authenticated = false
			supabase_request_queue.clear()
			world_chat_socket.close()
			world_chat_socket_joined = false
			if is_instance_valid(auth_overlay):
				auth_overlay.visible = true
		else:
			auth_error_label.text = message
			auth_submit_button.disabled = false
		return
	if action == "leaderboard":
		leaderboard_loading = false
		leaderboard_loaded = false
		if is_instance_valid(leaderboard_status_label):
			leaderboard_status_label.text = "Supabase chưa phản hồi"
	elif action == "world_chat_send":
		world_chat_message_pending = ""
		if is_instance_valid(world_chat_input):
			world_chat_input.editable = true
		if is_instance_valid(world_chat_send_button):
			world_chat_send_button.disabled = false
		_show_notification("Không gửi được tin nhắn: " + message, DANGER)
	elif action in ["save", "load"]:
		cloud_status_label.text = "●  Supabase ngoại tuyến"
		if action == "save":
			_show_notification("Lưu Supabase thất bại: " + message, DANGER)

func fetch_leaderboard_from_supabase() -> void:
	if leaderboard_loading or not is_authenticated:
		return
	leaderboard_loading = true
	leaderboard_loaded = false
	if is_instance_valid(leaderboard_status_label):
		leaderboard_status_label.text = "Đang tải BXH Supabase..."
	var endpoint := SUPABASE_REST_URL + "/public_leaderboard?select=user_id,name,qi_realm,body_realm,power,stones,title&order=power.desc&limit=50"
	_enqueue_supabase_request("leaderboard", endpoint, HTTPClient.METHOD_GET)

func _build_save_data() -> Dictionary:
	var data := _current_leaderboard_profile()
	data["realm"] = str(cultivation.get("realm_name", "Luyện Khí Kỳ"))
	data["cultivation"] = cultivation.duplicate(true)
	data["body_cultivation"] = body_cultivation.duplicate(true)
	data["codex_unlocked_ids"] = codex_unlocked_ids.duplicate()
	data["secret_realm_clears"] = secret_realm_clears.duplicate()
	data["schema_version"] = STATE_VERSION
	return data

func save_game() -> void:
	if not is_authenticated or supabase_user_id.is_empty():
		return
	if cloud_request_cooldown_remaining > 0.0:
		return
	cloud_request_cooldown_remaining = CLOUD_REQUEST_COOLDOWN_SECONDS
	autosave_elapsed = 0.0
	cloud_status_label.text = "●  Đang lưu Supabase..."
	var profile := _current_leaderboard_profile()
	var payload := {
		"user_id": supabase_user_id,
		"username": current_username,
		"qi_realm": profile["qi_realm"],
		"body_realm": profile["body_realm"],
		"power": profile["power"],
		"stones": spirit_stones,
		"save_data": _build_save_data(),
		"updated_at": Time.get_datetime_string_from_system(true),
	}
	var extra := PackedStringArray(["Prefer: resolution=merge-duplicates,return=minimal"])
	_enqueue_supabase_request("save", SUPABASE_REST_URL + "/player_saves?on_conflict=user_id", HTTPClient.METHOD_POST, JSON.stringify(payload), true, extra)

func load_game() -> void:
	if not is_authenticated or supabase_user_id.is_empty():
		return
	cloud_status_label.text = "●  Đang tải Supabase..."
	var endpoint := SUPABASE_REST_URL + "/player_saves?select=save_data&user_id=eq." + supabase_user_id + "&limit=1"
	_enqueue_supabase_request("load", endpoint, HTTPClient.METHOD_GET)

func _on_supabase_request_completed(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	if supabase_active_request.is_empty():
		return
	var request_data := supabase_active_request
	supabase_active_request = {}
	var action := str(request_data.get("action", ""))
	if result != HTTPRequest.RESULT_SUCCESS or response_code < 200 or response_code >= 300:
		_handle_supabase_request_error(action, _request_error_message(body, "HTTP %d" % response_code))
	else:
		_handle_supabase_request_success(action, body)
	_start_next_supabase_request()

func _handle_supabase_request_success(action: String, body: PackedByteArray) -> void:
	var parsed: Variant = JSON.parse_string(body.get_string_from_utf8())
	match action:
		"signup", "login":
			if not parsed is Dictionary:
				auth_error_label.text = "Supabase trả dữ liệu đăng nhập không hợp lệ."
				auth_submit_button.disabled = false
				return
			var auth_data: Dictionary = parsed
			if str(auth_data.get("access_token", "")).is_empty():
				auth_error_label.text = "Đã tạo tài khoản. Hãy xác nhận email rồi đăng nhập."
				auth_submit_button.disabled = false
				pending_auth_password = ""
				return
			_finish_authentication(pending_auth_username, auth_data)
		"refresh":
			if parsed is Dictionary:
				supabase_access_token = str(parsed.get("access_token", supabase_access_token))
				supabase_refresh_token = str(parsed.get("refresh_token", supabase_refresh_token))
				supabase_token_lifetime = float(parsed.get("expires_in", 3600.0))
				supabase_token_elapsed = 0.0
				world_chat_socket.close()
				world_chat_socket_joined = false
		"save":
			cloud_status_label.text = "●  Đã lưu Supabase"
		"load":
			if parsed is Array and not parsed.is_empty() and parsed[0] is Dictionary:
				var save_data: Variant = parsed[0].get("save_data", {})
				if save_data is Dictionary:
					_hydrate_state_from_account(save_data)
					_apply_offline_reward(current_username)
					_update_display()
					cloud_status_label.text = "●  Đã tải tiến trình Supabase"
					save_game()
				else:
					cloud_status_label.text = "●  Bắt đầu hành trình mới"
					_apply_offline_reward(current_username)
					save_game()
			else:
				cloud_status_label.text = "●  Bắt đầu hành trình mới"
				_apply_offline_reward(current_username)
				save_game()
		"leaderboard":
			leaderboard_entries.clear()
			if parsed is Array:
				for row in parsed:
					if row is Dictionary:
						leaderboard_entries.append(_leaderboard_profile_from_user(row))
			leaderboard_loaded = true
			leaderboard_loading = false
			if is_instance_valid(leaderboard_status_label):
				leaderboard_status_label.text = "BXH Supabase · %d đạo hữu" % leaderboard_entries.size()
			if active_center_tab == "BẢNG XẾP HẠNG":
				_render_popup_tab("BẢNG XẾP HẠNG")
		"world_chat_history":
			if parsed is Array:
				for index in range(parsed.size() - 1, -1, -1):
					if parsed[index] is Dictionary:
						_append_world_chat_record(parsed[index])
		"world_chat_send":
			var sent_message := world_chat_message_pending
			world_chat_message_pending = ""
			if not sent_message.is_empty():
				append_global_log(sent_message)
			world_chat_input.editable = true
			world_chat_send_button.disabled = false

func _connect_world_chat_realtime() -> void:
	if not is_authenticated or supabase_access_token.is_empty():
		return
	if world_chat_socket.get_ready_state() != WebSocketPeer.STATE_CLOSED:
		return
	var error := world_chat_socket.connect_to_url(SUPABASE_REALTIME_URL)
	if error != OK:
		world_chat_reconnect_elapsed = 0.0
		return
	world_chat_socket_joined = false
	world_chat_reconnect_elapsed = 0.0

func _poll_world_chat_realtime(delta: float) -> void:
	var socket_state := world_chat_socket.get_ready_state()
	if socket_state != WebSocketPeer.STATE_CLOSED:
		world_chat_socket.poll()
		socket_state = world_chat_socket.get_ready_state()
	if socket_state == WebSocketPeer.STATE_OPEN and not world_chat_socket_joined:
		_send_world_chat_join()
	if socket_state == WebSocketPeer.STATE_OPEN:
		world_chat_heartbeat_elapsed += delta
		if world_chat_heartbeat_elapsed >= 25.0:
			world_chat_heartbeat_elapsed = 0.0
			_send_realtime_message("phoenix", "heartbeat", {})
		while world_chat_socket.get_available_packet_count() > 0:
			var packet := world_chat_socket.get_packet().get_string_from_utf8()
			_handle_world_chat_realtime_packet(packet)
	else:
		world_chat_socket_joined = false
		world_chat_reconnect_elapsed += delta
		if world_chat_reconnect_elapsed >= 5.0:
			_connect_world_chat_realtime()

func _send_world_chat_join() -> void:
	var payload := {
		"config": {
			"broadcast": {"ack": false, "self": false},
			"presence": {"enabled": false, "key": ""},
			"postgres_changes": [{"event": "INSERT", "schema": "public", "table": "world_chat"}],
		},
		"access_token": supabase_access_token,
	}
	_send_realtime_message("realtime:public:world_chat", "phx_join", payload)
	world_chat_socket_joined = true
	var history_url := SUPABASE_REST_URL + "/world_chat?select=id,user_id,username,message,created_at&order=id.desc&limit=40"
	_enqueue_supabase_request("world_chat_history", history_url, HTTPClient.METHOD_GET)

func _send_realtime_message(topic: String, event_name: String, payload: Dictionary) -> void:
	supabase_ref_counter += 1
	if world_chat_socket.get_ready_state() == WebSocketPeer.STATE_OPEN:
		world_chat_socket.send_text(JSON.stringify({"topic": topic, "event": event_name, "payload": payload, "ref": str(supabase_ref_counter)}))

func _handle_world_chat_realtime_packet(packet: String) -> void:
	var parsed: Variant = JSON.parse_string(packet)
	if not parsed is Dictionary:
		return
	var event_name := str(parsed.get("event", ""))
	if event_name == "phx_reply":
		var reply: Dictionary = parsed.get("payload", {})
		if str(reply.get("status", "ok")) != "ok":
			world_chat_socket_joined = false
			world_chat_socket.close()
		return
	if event_name != "postgres_changes":
		return
	var payload: Dictionary = parsed.get("payload", {})
	var data: Dictionary = payload.get("data", {})
	var message: Dictionary = data.get("record", {})
	if message.is_empty():
		return
	if str(message.get("user_id", "")) == supabase_user_id:
		return
	_append_world_chat_record(message)

func _append_world_chat_record(message: Dictionary) -> void:
	var message_id := int(message.get("id", 0))
	if message_id > 0:
		if message_id in world_chat_seen_ids:
			return
		world_chat_seen_ids.append(message_id)
		while world_chat_seen_ids.size() > 600:
			world_chat_seen_ids.pop_front()
	append_global_log("[Thế Giới] %s: %s" % [str(message.get("username", "Đạo hữu")), str(message.get("message", ""))])

func _current_leaderboard_profile() -> Dictionary:
	var calculated_power := _base_combat_power() + _equipment_power()
	combat_power = maxi(combat_power, calculated_power)
	return {
		"user_id": supabase_user_id,
		"name": current_username,
		"username": current_username,
		"realm": str(cultivation.get("realm_name", "Phàm Nhân")),
		"qi_realm": str(cultivation.get("realm_name", "Phàm Nhân")),
		"body_realm": str(body_cultivation.get("realm_name", "Bì Nhục Cảnh")),
		"power": combat_power,
		"tu_vi": int(cultivation.get("cultivation", 0.0)),
		"linh_thach": spirit_stones,
		"luc_chien": combat_power,
		"equipment": equipment.duplicate(true),
		"item_inventory": item_inventory.duplicate(true),
		"owned_item_ids": owned_item_ids.duplicate(),
		"absorb_bonus": absorb_bonus,
		"breakthrough_bonus": breakthrough_bonus,
		"body_cultivation": body_cultivation.duplicate(true),
		"spirit_stone_inventory": spirit_stone_inventory.duplicate(true),
		"cultivation_method_ids": cultivation_method_ids.duplicate(),
		"inventory": inventory.duplicate(true),
		"arena_challenges_today": arena_challenges_today,
		"arena_last_day": arena_last_day,
		"arena_recovery_unix": arena_recovery_unix,
		"title": "Đạo Hữu"
	}

func _leaderboard_profile_from_user(user: Dictionary) -> Dictionary:
	var name := str(user.get("name", user.get("username", "")))
	if name.is_empty():
		return {}
	return {
		"name": name,
		"qi_realm": str(user.get("qi_realm", user.get("realm", "Luyện Khí Kỳ"))),
		"body_realm": str(user.get("body_realm", "Bì Nhục Cảnh")),
		"power": int(user.get("power", user.get("luc_chien", 0))),
		"stones": int(user.get("stones", user.get("linh_thach", 0))),
		"title": str(user.get("title", "Đạo Hữu"))
	}

func _rebuild_elixir_list() -> void:
	if not is_instance_valid(elixir_list):
		return
	for child in elixir_list.get_children():
		child.queue_free()
	_ensure_elixir_entries()
	_sync_elixir_counts_from_inventory()
	for elixir in elixirs:
		_add_elixir_row(elixir)

func _ensure_elixir_entries() -> void:
	_initialize_elixir_catalog()
	var saved_counts: Dictionary = {}
	for saved_elixir in elixirs:
		var saved_id := str(saved_elixir.get("id", ""))
		if saved_id != "":
			saved_counts[saved_id] = int(saved_elixir.get("count", 0))
	var normalized_elixirs: Array = []
	for definition in ELIXIR_DEFINITIONS:
		var item_id := str(definition["id"])
		var count := int(item_inventory.get(item_id, saved_counts.get(item_id, 0)))
		item_inventory[item_id] = maxi(count, 0)
		var entry: Dictionary = definition.duplicate(true)
		entry["count"] = maxi(count, 0)
		normalized_elixirs.append(entry)
	elixirs = normalized_elixirs
	inventory["elixirs"] = elixirs

func _sync_elixir_counts_from_inventory() -> void:
	for elixir in elixirs:
		var item_id := str(elixir.get("id", ""))
		if item_id != "":
			var count := maxi(0, int(item_inventory.get(item_id, elixir.get("count", 0))))
			elixir["count"] = count
			item_inventory[item_id] = count
