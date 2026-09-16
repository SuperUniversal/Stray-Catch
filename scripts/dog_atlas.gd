class_name DogAtlas
extends RefCounted
## Neck / foot in the 400x280 ChoCo cell. HTML anchors (192x160, foot 96,150)
## are scaled into this crop, then one run-frame tweak (foot ~ground, neck ahead of shoulder).

const CELL := Vector2(400, 280)
const HTML_CELL := Vector2(192, 160)
const HTML_FOOT := Vector2(96, 150)
## Calibrated on dog_run_00: paws on the crop ground line, collar in front of the withers.
const FOOT := Vector2(204, 252)

const _HTML_RUN: Array[Vector2] = [
	Vector2(67.6, 80.7), Vector2(67.6, 80.7), Vector2(68.4, 80.7), Vector2(64.8, 80.7),
	Vector2(62.0, 80.7), Vector2(62.0, 80.7), Vector2(66.1, 80.7), Vector2(67.7, 80.7),
]
const _HTML_TURN: Array[Vector2] = [
	Vector2(89.4, 81.03), Vector2(90.36, 81.03), Vector2(96.0, 86.56),
]
const _HTML_FRONT: Array[Vector2] = [
	Vector2(96.0, 86.56), Vector2(96.0, 86.56), Vector2(96.5, 86.56),
	Vector2(96.5, 86.56), Vector2(96.5, 86.56), Vector2(96.0, 86.56),
]
const _HTML_CAUGHT: Array[Vector2] = [
	Vector2(89.4, 81.03), Vector2(90.36, 81.03), Vector2(96.0, 86.56),
	Vector2(96.5, 86.56), Vector2(74.4, 87.3), Vector2(74.4, 87.3),
]


static func html_anchor(anim: StringName, frame: int) -> Vector2:
	var list: Array[Vector2] = _HTML_RUN
	match anim:
		&"run", &"walk", &"sprint", &"look", &"idle", &"jump":
			list = _HTML_RUN
		&"turn":
			list = _HTML_TURN
		&"front":
			list = _HTML_FRONT
		&"caught", &"sit":
			list = _HTML_CAUGHT
	if list.is_empty():
		return HTML_FOOT
	return list[clampi(frame, 0, list.size() - 1)]


static func neck_local(anim: StringName, frame: int) -> Vector2:
	## Offset from FOOT in 400x280 pixels (before sprite scale / rotate).
	var h: Vector2 = html_anchor(anim, frame)
	var mapped := Vector2(
		(h.x / HTML_CELL.x) * CELL.x,
		(h.y / HTML_CELL.y) * CELL.y
	)
	return mapped - FOOT


static func neck_world(foot: Vector2, angle: float, world_scale: float, anim: StringName, frame: int) -> Vector2:
	var local: Vector2 = neck_local(anim, frame) * world_scale
	var c := cos(angle)
	var n := sin(angle)
	return Vector2(foot.x + local.x * c - local.y * n, foot.y + local.x * n + local.y * c)


static func neck_global(dog: Node2D) -> Vector2:
	if dog == null:
		return Vector2.ZERO
	var sprite := dog as AnimatedSprite2D
	var anim: StringName = &"run"
	var frame := 0
	if sprite:
		anim = sprite.animation
		frame = sprite.frame
	var local: Vector2 = neck_local(anim, frame)
	return dog.to_global(local)
