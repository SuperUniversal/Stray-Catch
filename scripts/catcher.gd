extends AnimatedSprite2D
## Tay POV: clip theo session.phase. Nguoi choi ngam, khong auto-aim.

const GRIP_PX := Vector2(147.7, 182.2)

var session: GameSession
var _bob: float = 0.0
var _home: Vector2 = Vector2.ZERO
var _last_phase: StringName = &""


func _ready() -> void:
	centered = false
	offset = -GRIP_PX
	z_index = 20
	_home = position
	play("idle")


func bind_session(s: GameSession) -> void:
	session = s


func tool_tip_global() -> Vector2:
	var tex: Texture2D = null
	if sprite_frames:
		tex = sprite_frames.get_frame_texture(animation, frame)
	var local: Vector2 = CatcherAtlas.tool_tip(tex) - GRIP_PX
	return to_global(local)


func _process(delta: float) -> void:
	if session == null:
		return
	_bob += delta
	var p: StringName = session.phase
	if p == &"paused":
		p = session.resume_phase
	if p == &"ready" or p == &"over":
		p = &"idle"
	var anim: StringName = _anim_for(p)
	if sprite_frames and sprite_frames.has_animation(anim):
		if animation != anim or _last_phase != p:
			play(anim)
		_last_phase = p
		var dur: float = _phase_dur(p)
		var count: int = sprite_frames.get_frame_count(anim)
		if dur > 0.0 and count > 0:
			pause()
			frame = mini(count - 1, int(floor(session.phase_time / dur * float(count))))
		else:
			speed_scale = 1.0
	if p == &"idle":
		position = _home + Vector2(sin(_bob * 1.6) * 3.0, sin(_bob * 2.1) * 2.0)
	else:
		position = _home


func _phase_dur(p: StringName) -> float:
	match p:
		&"windup":
			return 0.18
		&"throw":
			return 0.56
		&"close":
			return 4.0 / 15.0
		&"retract":
			return 0.36
		&"break":
			return 0.55
		&"caught":
			return 0.7
		_:
			return 0.0


func _anim_for(p: StringName) -> StringName:
	match p:
		&"windup":
			return &"windup"
		&"throw":
			return &"swing"
		&"close", &"caught":
			return &"catch"
		&"tug":
			return &"tug" if sprite_frames.has_animation(&"tug") else &"catch"
		&"retract":
			return &"retract" if sprite_frames.has_animation(&"retract") else &"miss"
		&"break":
			return &"break" if sprite_frames.has_animation(&"break") else &"miss"
		&"idle":
			if session and session.dog_x > 280.0 and session.dog_x < 980.0:
				return &"ready"
			return &"idle"
		_:
			return &"idle"
