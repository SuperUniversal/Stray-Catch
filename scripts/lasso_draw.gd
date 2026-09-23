extends Node2D
## Mot soi day: quadratic tu tay toi mep vong, khong ve them gay hay vong ngam.

@export var half: StringName = &"front"

var session: GameSession
var catcher: Node2D


func bind(s: GameSession, hands: Node2D) -> void:
	session = s
	catcher = hands


func _process(_delta: float) -> void:
	queue_redraw()


func _draw() -> void:
	if session == null:
		return
	var vp: Vector2 = get_viewport_rect().size
	var sx: float = vp.x / 1280.0
	var sy: float = vp.y / 720.0
	draw_set_transform(Vector2.ZERO, 0.0, Vector2(sx, sy))
	var tip: Vector2 = _tip_design()
	var loop: Vector2 = _loop_pos(tip)
	var p: StringName = session.phase
	if p == &"paused":
		p = session.resume_phase
	var attached: bool = session.loop_attached
	var close_t := 1.0
	if p == &"close":
		var cf: int = mini(3, int(floor(session.phase_time / (4.0 / 15.0) * 4.0)))
		close_t = float(cf) / 3.0
	var rx: float
	var ry: float
	if attached:
		rx = (1.0 - close_t) * 40.0 + close_t * 16.0 * session.dog_scale
		ry = (1.0 - close_t) * 22.0 + close_t * 5.5 * session.dog_scale
	else:
		rx = 30.0 - session.loop_p * 5.0
		ry = 18.0 - session.loop_p * 3.0
	var opacity := 1.0
	if p == &"break":
		opacity = maxf(0.1, 1.0 - session.phase_time * 1.3)
	if attached:
		if half == &"back":
			_ring(loop, rx, ry, session.dog_angle, opacity, true)
		else:
			_ring(loop, rx, ry, session.dog_angle, opacity, false)
			_shaft(tip, loop, rx, ry, session.dog_angle)
			_vfx()
	elif half == &"front":
		_shaft(tip, loop, rx, ry, 0.0)
		_ring(loop, rx, ry, 0.0, opacity, true)
		_ring(loop, rx, ry, 0.0, opacity, false)


func _tip_design() -> Vector2:
	var vp: Vector2 = get_viewport_rect().size
	if catcher and catcher.has_method("tool_tip_global"):
		var g = catcher.call("tool_tip_global")
		return GameLayout.to_design(g, vp)
	return Vector2(640, 490)


func _loop_pos(tip: Vector2) -> Vector2:
	var p: StringName = session.phase
	if p == &"paused":
		p = session.resume_phase
	if p == &"ready" or p == &"idle" or p == &"over":
		return Vector2(tip.x + (session.aim_x - 640.0) * 0.10, tip.y - 62.0)
	return Vector2(session.loop_x, session.loop_y)


func _ring(c: Vector2, rx: float, ry: float, rot: float, opacity: float, back: bool) -> void:
	var start: float = PI if back else 0.0
	var end: float = TAU if back else PI
	var cr := cos(rot)
	var sr := sin(rot)
	var pts: PackedVector2Array = PackedVector2Array()
	var steps := 28
	for i in steps + 1:
		var t: float = lerpf(start, end, float(i) / float(steps))
		var lx: float = cos(t) * rx
		var ly: float = sin(t) * ry
		pts.append(c + Vector2(lx * cr - ly * sr, lx * sr + ly * cr))
	for i in steps:
		draw_line(pts[i], pts[i + 1], Color(0.376, 0.212, 0.078, opacity), 9.0, true)
	for i in steps:
		draw_line(pts[i], pts[i + 1], Color(1.0, 0.678, 0.271, opacity), 5.5, true)


func _rim(from: Vector2, center: Vector2, rx: float, ry: float, rot: float) -> Vector2:
	var d := from - center
	var cr := cos(-rot)
	var sr := sin(-rot)
	var local := Vector2(d.x * cr - d.y * sr, d.x * sr + d.y * cr)
	var ang := atan2(local.y / maxf(ry, 0.1), local.x / maxf(rx, 0.1))
	var p := Vector2(cos(ang) * rx, sin(ang) * ry)
	var cr2 := cos(rot)
	var sr2 := sin(rot)
	return center + Vector2(p.x * cr2 - p.y * sr2, p.x * sr2 + p.y * cr2)


func _shaft(tip: Vector2, loop: Vector2, rx: float, ry: float, rot: float) -> void:
	var endp := _rim(tip, loop, rx, ry, rot)
	var dist: float = maxf(1.0, tip.distance_to(endp))
	var sag: float = maxf(0.0, (100.0 - session.player_force) * 0.12) if session.loop_attached else minf(18.0, dist * 0.08)
	var mid := Vector2((tip.x + endp.x) * 0.5, (tip.y + endp.y) * 0.5 + sag)
	var prev := tip
	for i in range(1, 13):
		var t: float = float(i) / 12.0
		var omt: float = 1.0 - t
		var pt: Vector2 = omt * omt * tip + 2.0 * omt * t * mid + t * t * endp
		draw_line(prev, pt, Color(0.38, 0.216, 0.086), 7.0, true)
		draw_line(prev, pt, Color(0.922, 0.561, 0.208), 4.5, true)
		prev = pt


func _vfx() -> void:
	if session.phase != &"tug" and session.resume_phase != &"tug":
		return
	if session.phase == &"paused":
		return
	var n: Vector2 = session.dog_neck
	var s: float = session.dog_scale
	var col := Color(1, 0.953, 0.722, 0.69)
	for sign_i in 2:
		var sign: float = -1.0 if sign_i == 0 else 1.0
		for i in 2:
			var c := Vector2(n.x + sign * (38.0 + float(i) * 7.0) * s, n.y)
			var rad: float = 13.0 + float(i) * 7.0
			var a0: float = -0.7 if sign > 0.0 else PI - 0.7
			var a1: float = 0.7 if sign > 0.0 else PI + 0.7
			var pts: PackedVector2Array = PackedVector2Array()
			for k in 10:
				var t: float = lerpf(a0, a1, float(k) / 9.0)
				pts.append(c + Vector2(cos(t) * rad, sin(t) * rad))
			for k in 9:
				draw_line(pts[k], pts[k + 1], col, 2.4, true)
