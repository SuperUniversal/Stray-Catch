class_name CatcherAtlas
extends RefCounted
## toolTip = dinh can sat gang (sau khi Python xoa vong cam).

const CACHE: Dictionary = {}


static func tool_tip(tex: Texture2D) -> Vector2:
	if tex == null:
		return Vector2(80, 40)
	var key: int = tex.get_rid().get_id()
	if CACHE.has(key):
		return CACHE[key]
	var img: Image = tex.get_image()
	if img == null:
		return Vector2(float(tex.get_width()) * 0.55, float(tex.get_height()) * 0.22)
	if img.is_compressed():
		img.decompress()
	var w: int = img.get_width()
	var h: int = img.get_height()
	var best := Vector2(float(w) * 0.55, float(h) * 0.22)
	var found := false
	var min_y: int = h
	for y in h:
		for x in w:
			var c: Color = img.get_pixel(x, y)
			if c.a < 0.2:
				continue
			var r := c.r * 255.0
			var g := c.g * 255.0
			var b := c.b * 255.0
			var metal: bool = absf(r - g) < 28.0 and absf(g - b) < 28.0 and r > 90.0 and r < 220.0
			var pole_wood: bool = r > 70.0 and r < 160.0 and g > 50.0 and g < 120.0 and b < 80.0
			if not metal and not pole_wood:
				continue
			if y < min_y:
				min_y = y
				best = Vector2(float(x), float(y))
				found = true
		if found and y > min_y + 8:
			break
	if not found:
		for y in h:
			for x in range(w - 1, -1, -1):
				if img.get_pixel(x, y).a > 0.35:
					best = Vector2(float(x), float(y))
					found = true
					break
			if found:
				break
	CACHE[key] = best
	return best
