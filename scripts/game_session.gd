class_name GameSession
extends RefCounted
## Port of GameThamKhao/source/logic.js. Design space is 1280x720, step 1/60.

const DT := 1.0 / 60.0
const DESIGN := Vector2(1280, 720)
const GROUND_Y := 452.0
const THROW_Y := 348.0
const REST_SCALE := 1.5
const TEX_SCALE := 0.66

signal event_fired(event_name: StringName)

var phase: StringName = &"ready"
var resume_phase: StringName = &"idle"
var phase_time: float = 0.0
var elapsed: float = 0.0
var remaining: float = 60.0
var seed: int = 1337
var aim_x: float = 640.0
var score: int = 0
var catches: int = 0
var combo: int = 0
var best_combo: int = 0
var throws: int = 0
var misses: int = 0
var escapes: int = 0
var player_force: float = 0.0
var progress: float = 0.0
var struggle_left: float = 5.0
var taps: int = 0
var last_tap: float = -1.0
var event: StringName = &"ready"
var event_id: int = 0
var event_age: float = 0.0
var reason: String = ""
var close_start_frame: int = 0
## -1 auto ellipse, 0 force miss, 1 force hit (movie driver).
var force_hit: int = -1

var dog_id: int = 0
var dog_state: StringName = &"RunSide"
var dog_x: float = 1100.0
var dog_ground_y: float = GROUND_Y
var dog_scale: float = REST_SCALE
var dog_angle: float = 0.0
var dog_age: float = 0.0
var dog_speed: float = 145.0
var dog_strength: float = 28.0
var dog_neck: Vector2 = Vector2.ZERO
var dog_snare_x: float = 0.0
var visual_anim: StringName = &"run"
var visual_frame: int = 0

var loop_x: float = 640.0
var loop_y: float = 466.0
var loop_tx: float = 640.0
var loop_ty: float = THROW_Y
var loop_from_x: float = 640.0
var loop_from_y: float = 466.0
var loop_p: float = 0.0
var loop_attached: bool = false


func reset() -> void:
	phase = &"ready"
	resume_phase = &"idle"
	phase_time = 0.0
	elapsed = 0.0
	remaining = 60.0
	seed = 1337
	aim_x = 640.0
	score = 0
	catches = 0
	combo = 0
	throws = 0
	misses = 0
	escapes = 0
	player_force = 0.0
	progress = 0.0
	struggle_left = 5.0
	taps = 0
	last_tap = -1.0
	event = &"ready"
	event_id = 0
	event_age = 0.0
	reason = ""
	close_start_frame = 0
	force_hit = -1
	loop_attached = false
	loop_x = 640.0
	loop_y = 466.0
	loop_p = 0.0
	dog_id = 0
	_spawn(true)


func start() -> bool:
	if phase != &"ready":
		return false
	_enter(&"idle")
	_notify(&"start")
	return true


func pause_toggle() -> bool:
	if phase == &"ready" or phase == &"over":
		return false
	if phase == &"paused":
		phase = resume_phase
	else:
		resume_phase = phase
		phase = &"paused"
	return true


func aim(x: float) -> void:
	aim_x = clampf(x, 100.0, 1180.0)


func tap(origin: Vector2) -> bool:
	if phase != &"idle" and phase != &"tug":
		return false
	if elapsed - last_tap < 0.065:
		return false
	last_tap = elapsed
	if phase == &"idle":
		loop_x = origin.x
		loop_y = origin.y
		loop_from_x = origin.x
		loop_from_y = origin.y
		loop_tx = aim_x
		loop_ty = THROW_Y
		loop_p = 0.0
		loop_attached = false
		throws += 1
		_enter(&"windup")
		_notify(&"throw")
	else:
		player_force = minf(100.0, player_force + 14.0)
		taps += 1
		_notify(&"pull")
	return true


func tick() -> void:
	if phase == &"ready" or phase == &"paused" or phase == &"over":
		return
	_advance()


func dog_world_scale() -> float:
	return TEX_SCALE * (dog_scale / REST_SCALE)


func _enter(next: StringName) -> void:
	phase = next
	phase_time = 0.0


func _notify(name: StringName) -> void:
	event = name
	event_id += 1
	event_age = 0.0
	event_fired.emit(name)


func _spawn(first: bool = false) -> void:
	seed = (seed * 1664525 + 1013904223) & 0xFFFFFFFF
	var level: int = mini(catches, 6)
	dog_id += 1
	dog_state = &"RunSide"
	dog_x = 1100.0 if first else 1400.0
	dog_ground_y = GROUND_Y
	dog_scale = REST_SCALE
	dog_angle = 0.0
	dog_age = 0.0
	dog_speed = 145.0 + float(level) * 10.0 + float(seed % 26)
	dog_strength = 28.0 + float(level) * 2.0
	dog_snare_x = 0.0
	visual_anim = &"run"
	visual_frame = 0
	_pose()


func _pose() -> void:
	_update_visual()
	dog_neck = DogAtlas.neck_world(
		Vector2(dog_x, dog_ground_y), dog_angle, dog_world_scale(), visual_anim, visual_frame
	)


func _update_visual() -> void:
	match dog_state:
		&"Escape":
			visual_anim = &"sprint"
			visual_frame = int(floor(dog_age * 14.0)) % 6
		&"Snared":
			var f: int = mini(3, int(floor(phase_time / (4.0 / 15.0) * 4.0)))
			if f == 0:
				visual_anim = &"run"
				visual_frame = close_start_frame
			elif f <= 2:
				visual_anim = &"turn"
				visual_frame = f - 1
			else:
				visual_anim = &"front"
				visual_frame = 0
		&"Struggle":
			visual_anim = &"front"
			visual_frame = int(floor(phase_time * 14.0)) % 6
		&"Caught":
			if phase_time < 0.28:
				visual_anim = &"caught"
				visual_frame = mini(5, int(floor(phase_time * 18.0)))
			else:
				visual_anim = &"sit"
				visual_frame = mini(3, int(floor((phase_time - 0.28) * 8.0)))
		_:
			visual_anim = &"run"
			visual_frame = int(floor(dog_age * 12.0)) % 8


func _ellipses(ax: float, ay: float, arx: float, ary: float, bx: float, by: float, brx: float, bry: float) -> bool:
	var dx: float = ax - bx
	var dy: float = ay - by
	if absf(dx) > arx + brx or absf(dy) > ary + bry:
		return false
	if dx * dx / (brx * brx) + dy * dy / (bry * bry) <= 1.0:
		return true
	if dx * dx / (arx * arx) + dy * dy / (ary * ary) <= 1.0:
		return true
	for i in 24:
		var t: float = float(i) * PI / 12.0
		var x: float = dx + cos(t) * arx
		var y: float = dy + sin(t) * ary
		if x * x / (brx * brx) + y * y / (bry * bry) <= 1.0:
			return true
	return false


func _release(why: String) -> void:
	loop_attached = false
	loop_from_x = loop_x
	loop_from_y = loop_y
	dog_state = &"Escape"
	dog_angle = 0.0
	dog_scale = REST_SCALE
	dog_ground_y = GROUND_Y
	combo = 0
	escapes += 1
	reason = why
	_enter(&"break")
	_notify(&"escape")


func _advance() -> void:
	elapsed += DT
	remaining = maxf(0.0, 60.0 - elapsed)
	phase_time += DT
	event_age += DT
	dog_age += DT
	var old_n: Vector2 = dog_neck

	if dog_state == &"RunSide" or dog_state == &"Escape":
		var mul: float = 1.65 if dog_state == &"Escape" else 1.0
		dog_x -= dog_speed * mul * DT
		dog_angle = 0.0
		_pose()
		if dog_x < -180.0 and phase == &"idle":
			_spawn()
	else:
		_pose()

	if phase == &"windup" and phase_time >= 0.18:
		_enter(&"throw")
		loop_from_x = loop_x
		loop_from_y = loop_y
	elif phase == &"throw":
		var p: float = clampf(phase_time / 0.56, 0.0, 1.0)
		var ox: float = loop_x
		var oy: float = loop_y
		var e: float = 1.0 - (1.0 - p) * (1.0 - p)
		loop_p = p
		loop_x = lerpf(loop_from_x, loop_tx, e)
		loop_y = lerpf(loop_from_y, THROW_Y, p) - 32.0 * sin(p * PI)
		var hit := false
		if p >= 0.5 and dog_state == &"RunSide":
			if force_hit == 1:
				hit = true
			elif force_hit == 0:
				hit = false
			else:
				for j in range(1, 5):
					var q: float = float(j) / 4.0
					if _ellipses(
						lerpf(ox, loop_x, q), lerpf(oy, loop_y, q), 20.0, 13.0,
						lerpf(old_n.x, dog_neck.x, q), lerpf(old_n.y, dog_neck.y, q),
						12.0 * dog_scale, 8.0 * dog_scale
					):
						hit = true
						break
		if hit:
			dog_state = &"Snared"
			dog_snare_x = dog_x
			loop_attached = true
			loop_x = dog_neck.x
			loop_y = dog_neck.y
			close_start_frame = visual_frame
			_enter(&"close")
			_notify(&"hit")
		elif p >= 1.0:
			loop_from_x = loop_x
			loop_from_y = loop_y
			misses += 1
			combo = 0
			_enter(&"retract")
			_notify(&"miss")
	elif phase == &"close":
		_pose()
		loop_x = dog_neck.x
		loop_y = dog_neck.y
		if phase_time >= 4.0 / 15.0:
			dog_state = &"Struggle"
			player_force = 42.0
			progress = 0.15
			struggle_left = 5.0
			taps = 0
			_enter(&"tug")
			_notify(&"tug")
	elif phase == &"tug":
		player_force = maxf(0.0, player_force - 22.0 * DT)
		struggle_left = maxf(0.0, struggle_left - DT)
		var net: float = player_force - dog_strength
		progress = clampf(progress + net * 0.0075 * DT, 0.0, 1.0)
		var pull: float = clampf((progress - 0.15) / 0.85, 0.0, 1.0)
		dog_angle = sin(phase_time * 21.0) * 0.075
		dog_scale = REST_SCALE * (1.0 + pull * 0.62)
		dog_ground_y = GROUND_Y + pull * 95.0
		dog_x = lerpf(dog_snare_x, 640.0, pull * 0.65) + sin(phase_time * 25.0) * 5.0
		_pose()
		loop_x = dog_neck.x
		loop_y = dog_neck.y
		if progress >= 1.0 and player_force >= dog_strength:
			score += 100 + combo * 25
			catches += 1
			combo += 1
			best_combo = maxi(best_combo, combo)
			dog_state = &"Caught"
			_enter(&"caught")
			_notify(&"caught")
		elif player_force <= 0.0 or struggle_left <= 0.0 or progress <= 0.0:
			_release("timeout" if struggle_left <= 0.0 else "force")
	elif phase == &"caught":
		dog_angle *= 0.88
		dog_ground_y += 250.0 * DT
		dog_scale += 0.4 * DT
		_pose()
		loop_x = dog_neck.x
		loop_y = dog_neck.y
		if phase_time > 0.7:
			loop_attached = false
			_spawn()
			_enter(&"idle")
	elif phase == &"retract" or phase == &"break":
		var dur: float = 0.55 if phase == &"break" else 0.36
		var rp: float = clampf(phase_time / dur, 0.0, 1.0)
		loop_x = lerpf(loop_from_x, 640.0, rp)
		loop_y = lerpf(loop_from_y, 466.0, rp)
		if rp >= 1.0:
			loop_attached = false
			dog_state = &"RunSide"
			_enter(&"idle")
			if dog_x < -150.0:
				_spawn()

	if remaining <= 0.0:
		loop_attached = false
		_enter(&"over")
		_notify(&"roundOver")


func _init() -> void:
	reset()
