extends AnimatedSprite2D
## Cho follows GameSession: RunSide / Escape / close / tug / caught. No self-catch.

const DUST_LOCAL := Vector2(36, -8)

var _base_scale: Vector2 = Vector2(0.66, 0.66)
var _last_id: int = -1
var session: GameSession

@onready var dust: AnimatedSprite2D = $DustEffect


func _ready() -> void:
	_base_scale = scale
	centered = false
	offset = -DogAtlas.FOOT
	if dust:
		dust.position = DUST_LOCAL
		dust.visible = false
	z_index = 10
	play("run")


func bind_session(s: GameSession) -> void:
	session = s


func _process(_delta: float) -> void:
	if session == null:
		return
	var vp: Vector2 = get_viewport_rect().size
	if session.dog_id != _last_id:
		_last_id = session.dog_id
		modulate.a = 0.0
		if dust:
			dust.visible = false
	var target_a: float = 1.0
	if session.phase == &"caught":
		target_a = maxf(0.0, 1.0 - session.phase_time * 0.7)
	elif session.phase == &"ready":
		target_a = 0.85
	modulate.a = move_toward(modulate.a, target_a, 0.08)

	position = GameLayout.to_view(Vector2(session.dog_x, session.dog_ground_y), vp)
	rotation = session.dog_angle
	var s: float = session.dog_world_scale()
	scale = Vector2(s, s)
	var want: StringName = session.visual_anim
	if sprite_frames and sprite_frames.has_animation(want):
		if animation != want:
			play(want)
		var last: int = maxi(sprite_frames.get_frame_count(want) - 1, 0)
		frame = clampi(session.visual_frame, 0, last)
	if dust:
		var running: bool = session.dog_state == &"RunSide" and modulate.a > 0.3
		dust.visible = running
		if running and (frame == 0 or frame == 4) and not dust.is_playing():
			dust.play("puff")
