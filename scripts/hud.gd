extends CanvasLayer
## HUD: diem 4 so, combo +25, dong ho 60s. Khong mang paw. Overlay + tug bars.

const TEX_BONE := preload("res://assets/UI/icon_bone.png")
const TEX_CLOCK := preload("res://assets/UI/icon_clock.png")
const TEX_MISS := preload("res://assets/UI/icon_miss.png")
const TEX_SPARK := preload("res://assets/UI/vfx_catch_spark.png")
const TEX_PLAQUE := preload("res://assets/UI/hud_plaque.png")
const TEX_LASSO := preload("res://assets/UI/icon_lasso.png")
const TEX_PLAY := preload("res://assets/UI/btn_play.png")

var session: GameSession
var _t: float = 0.0
var _seen_event: int = -1
var _best: int = 0
var _prev_score: int = -1
var _prev_combo: int = -1
var _prev_time: int = -1
var _prev_phase: StringName = &""

var _score_label: Label
var _combo_label: Label
var _time_label: Label
var _spark: TextureRect
var _miss: TextureRect
var _lasso: TextureRect
var _play: TextureButton
var _overlay: ColorRect
var _overlay_title: Label
var _overlay_body: Label
var _tug: Control
var _prog_fill: ColorRect
var _force_fill: ColorRect


func _ready() -> void:
	layer = 30
	_best = _load_best()
	_build()
	get_tree().get_root().size_changed.connect(_layout)


func bind_session(s: GameSession) -> void:
	session = s


func _process(delta: float) -> void:
	_t += delta
	if session == null:
		return
	if session.event_id != _seen_event:
		_seen_event = session.event_id
		_on_event(session.event)
	_refresh_labels()
	_pulse_lasso()


func _build() -> void:
	var plaque := _icon(TEX_PLAQUE, Vector2(2.0, 2.0))
	plaque.name = "Plaque"
	add_child(plaque)
	var bone := _icon(TEX_BONE, Vector2(1.35, 1.35))
	bone.name = "Bone"
	add_child(bone)
	_score_label = _label(32)
	_score_label.name = "Score"
	add_child(_score_label)
	_combo_label = _label(22)
	_combo_label.name = "Combo"
	_combo_label.add_theme_color_override("font_color", Color(1.0, 0.82, 0.35))
	add_child(_combo_label)
	var clock := _icon(TEX_CLOCK, Vector2(1.25, 1.25))
	clock.name = "Clock"
	add_child(clock)
	_time_label = _label(28)
	_time_label.name = "Time"
	add_child(_time_label)
	_lasso = _icon(TEX_LASSO, Vector2(1.2, 1.2))
	_lasso.name = "Lasso"
	add_child(_lasso)
	_spark = _icon(TEX_SPARK, Vector2(1.6, 1.6))
	_spark.name = "Spark"
	_spark.visible = false
	_spark.modulate.a = 0.0
	add_child(_spark)
	_miss = _icon(TEX_MISS, Vector2(1.8, 1.8))
	_miss.name = "MissStamp"
	_miss.visible = false
	_miss.modulate.a = 0.0
	add_child(_miss)

	_tug = Control.new()
	_tug.name = "Tug"
	_tug.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_tug)
	var prog_bg := ColorRect.new()
	prog_bg.name = "ProgBg"
	prog_bg.color = Color(0.12, 0.08, 0.04, 0.72)
	prog_bg.size = Vector2(280, 16)
	_tug.add_child(prog_bg)
	_prog_fill = ColorRect.new()
	_prog_fill.name = "ProgFill"
	_prog_fill.color = Color(0.95, 0.72, 0.22)
	_prog_fill.size = Vector2(280, 16)
	_tug.add_child(_prog_fill)
	var force_bg := ColorRect.new()
	force_bg.name = "ForceBg"
	force_bg.color = Color(0.12, 0.08, 0.04, 0.72)
	force_bg.position = Vector2(0, 22)
	force_bg.size = Vector2(280, 12)
	_tug.add_child(force_bg)
	_force_fill = ColorRect.new()
	_force_fill.name = "ForceFill"
	_force_fill.color = Color(0.35, 0.78, 0.42)
	_force_fill.position = Vector2(0, 22)
	_force_fill.size = Vector2(280, 12)
	_tug.add_child(_force_fill)
	var tug_lab := _label(16)
	tug_lab.name = "TugHint"
	tug_lab.text = "NHAN NHANH"
	tug_lab.position = Vector2(0, 38)
	tug_lab.size = Vector2(280, 22)
	tug_lab.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_tug.add_child(tug_lab)

	_overlay = ColorRect.new()
	_overlay.name = "Overlay"
	_overlay.color = Color(0.05, 0.08, 0.06, 0.62)
	_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(_overlay)
	_overlay_title = _label(42)
	_overlay_title.name = "OverlayTitle"
	_overlay_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_overlay.add_child(_overlay_title)
	_overlay_body = _label(22)
	_overlay_body.name = "OverlayBody"
	_overlay_body.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_overlay.add_child(_overlay_body)
	_play = TextureButton.new()
	_play.name = "Play"
	_play.texture_normal = TEX_PLAY
	_play.custom_minimum_size = Vector2(96, 96)
	_play.size = Vector2(96, 96)
	_play.stretch_mode = TextureButton.STRETCH_KEEP
	_play.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_play.pressed.connect(_on_play)
	_overlay.add_child(_play)
	_layout()


func _icon(tex: Texture2D, sc: Vector2) -> TextureRect:
	var n := TextureRect.new()
	n.texture = tex
	n.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	n.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	n.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	n.custom_minimum_size = tex.get_size() * sc
	n.size = n.custom_minimum_size
	n.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return n


func _label(px: int) -> Label:
	var n := Label.new()
	n.add_theme_font_size_override("font_size", px)
	n.add_theme_color_override("font_color", Color(1.0, 0.94, 0.78))
	n.add_theme_color_override("font_outline_color", Color(0.18, 0.08, 0.04))
	n.add_theme_constant_override("outline_size", 8)
	n.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return n


func _layout() -> void:
	var vp: Vector2 = get_viewport().get_visible_rect().size
	var plaque: TextureRect = get_node("Plaque") as TextureRect
	plaque.position = Vector2((vp.x - plaque.size.x) * 0.5, 10.0)
	var bone: TextureRect = get_node("Bone") as TextureRect
	bone.position = Vector2(plaque.position.x + 22.0, plaque.position.y + (plaque.size.y - bone.size.y) * 0.5)
	_score_label.position = Vector2(bone.position.x + bone.size.x + 6.0, plaque.position.y + 10.0)
	_score_label.size = Vector2(160.0, 40.0)
	_combo_label.position = Vector2(bone.position.x + bone.size.x + 6.0, plaque.position.y + 42.0)
	_combo_label.size = Vector2(200.0, 28.0)
	var clock: TextureRect = get_node("Clock") as TextureRect
	clock.position = Vector2(vp.x - clock.size.x - 118.0, 16.0)
	_time_label.position = Vector2(clock.position.x + clock.size.x + 6.0, 28.0)
	_time_label.size = Vector2(90.0, 40.0)
	_lasso.position = Vector2(plaque.position.x + plaque.size.x - 72.0, plaque.position.y + 8.0)
	_spark.position = Vector2((vp.x - _spark.size.x) * 0.5, vp.y * 0.42)
	_miss.position = Vector2((vp.x - _miss.size.x) * 0.5, vp.y * 0.38)
	_tug.position = Vector2((vp.x - 280.0) * 0.5, 86.0)
	_overlay.position = Vector2.ZERO
	_overlay.size = vp
	_overlay_title.position = Vector2((vp.x - 520.0) * 0.5, vp.y * 0.28)
	_overlay_title.size = Vector2(520, 52)
	_overlay_body.position = Vector2((vp.x - 560.0) * 0.5, vp.y * 0.36)
	_overlay_body.size = Vector2(560, 40)
	_play.position = Vector2((vp.x - 96.0) * 0.5, vp.y * 0.46)


func _refresh_labels() -> void:
	if session == null:
		return
	if session.score != _prev_score:
		_prev_score = session.score
		_score_label.text = "%04d" % session.score
	var cur_combo: int = session.combo if session.combo > 0 else -(maxi(_best, session.best_combo) + 1)
	if cur_combo != _prev_combo:
		_prev_combo = cur_combo
		if session.combo > 0:
			_combo_label.text = "x%d  +%d" % [session.combo, session.combo * 25]
		else:
			_combo_label.text = "BEST %d" % maxi(_best, session.best_combo)
	var cur_time: int = ceili(session.remaining)
	if cur_time != _prev_time:
		_prev_time = cur_time
		_time_label.text = "%02d" % cur_time
	var tugging: bool = session.phase == &"tug"
	_tug.visible = tugging
	if tugging:
		_prog_fill.size.x = 280.0 * session.progress
		var f: float = clampf(session.player_force / 100.0, 0.0, 1.0)
		_force_fill.size.x = 280.0 * f
		_force_fill.color = Color(0.35, 0.78, 0.42) if session.player_force >= session.dog_strength else Color(0.85, 0.32, 0.22)
	if session.phase != _prev_phase:
		_prev_phase = session.phase
		var show_overlay: bool = session.phase == &"ready" or session.phase == &"paused" or session.phase == &"over"
		_overlay.visible = show_overlay
		_overlay.mouse_filter = Control.MOUSE_FILTER_STOP if show_overlay else Control.MOUSE_FILTER_IGNORE
		if session.phase == &"ready":
			_overlay_title.text = "SAN SANG"
			_overlay_body.text = "Ngam chuot / mui ten  ·  Click hoac Space de quang"
		elif session.phase == &"paused":
			_overlay_title.text = "TAM DUNG"
			_overlay_body.text = "P hoac Esc de tiep"
		elif session.phase == &"over":
			_overlay_title.text = "HET GIO"
			_overlay_body.text = "Diem %04d   Bat %d   Combo %d" % [session.score, session.catches, session.best_combo]


func _pulse_lasso() -> void:
	var hot: bool = session != null and session.phase == &"idle"
	var pulse: float = 1.0 + (sin(_t * 8.0) * 0.08 if hot else 0.0)
	_lasso.scale = Vector2(pulse, pulse)
	_lasso.modulate = Color(1.15, 1.05, 0.85) if hot else Color(1, 1, 1, 0.85)


func _on_event(name: StringName) -> void:
	match name:
		&"hit", &"caught":
			_flash(_spark)
			if name == &"caught":
				_save_best()
		&"miss", &"escape":
			_flash(_miss)


func _flash(n: TextureRect) -> void:
	n.visible = true
	n.modulate.a = 1.0
	n.scale = Vector2(0.7, 0.7)
	var tw := create_tween()
	tw.set_parallel(true)
	tw.tween_property(n, "modulate:a", 0.0, 0.42)
	tw.tween_property(n, "scale", Vector2(1.15, 1.15), 0.42)
	tw.chain().tween_callback(func() -> void:
		n.visible = false
		n.scale = Vector2.ONE
	)


func _on_play() -> void:
	if session == null:
		return
	if session.phase == &"ready":
		session.start()
	elif session.phase == &"paused":
		session.pause_toggle()
	elif session.phase == &"over":
		session.reset()
		session.start()


func _load_best() -> int:
	var cf := ConfigFile.new()
	if cf.load("user://shiba_best.cfg") == OK:
		return int(cf.get_value("score", "best_combo", 0))
	return 0


func _save_best() -> void:
	if session == null:
		return
	_best = maxi(_best, session.best_combo)
	var cf := ConfigFile.new()
	cf.set_value("score", "best_combo", _best)
	cf.set_value("score", "best_score", session.score)
	cf.save("user://shiba_best.cfg")
