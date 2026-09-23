class_name GameLayout
extends RefCounted
## Bo tri man hinh dung chung cho ca game (toa do chuan hoa 0..1 theo viewport).
## Cac script khac (dog spawner, catcher, vung bat) dung chung nguon nay
## de "cai dat" tren nen lang khop nhau.

## Duong chay cua cho (chan cho cham dat) — nam tren khu dat trong.
const DOG_LANE_Y := 0.58            # ti le chieu cao viewport

## Vung bat co dinh phia truoc (noi vong cap voi toi), chuan hoa.
const CATCH_ZONE := Rect2(0.36, 0.64, 0.28, 0.20)  # x, y, w, h

## Cho di vao tu mep phai, ra o mep trai (dem ngoai man hinh).
const SPAWN_X := 1.12
const DESPAWN_X := -0.12

## --- Helpers: doi tu chuan hoa sang pixel theo kich thuoc viewport ---
static func lane_y(vp: Vector2) -> float:
	return DOG_LANE_Y * vp.y

static func catch_zone_px(vp: Vector2) -> Rect2:
	return Rect2(CATCH_ZONE.position * vp, CATCH_ZONE.size * vp)

static func spawn_x(vp: Vector2) -> float:
	return SPAWN_X * vp.x

static func despawn_x(vp: Vector2) -> float:
	return DESPAWN_X * vp.x


static func to_view(p: Vector2, vp: Vector2) -> Vector2:
	return Vector2(p.x / 1280.0 * vp.x, p.y / 720.0 * vp.y)


static func to_design(p: Vector2, vp: Vector2) -> Vector2:
	return Vector2(p.x / vp.x * 1280.0, p.y / vp.y * 720.0)
