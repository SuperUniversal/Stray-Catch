extends Node2D
## Hieu ung gio — la bay va bui cuon tu phai sang trai.
## Dung Sprite2D thu cong de pha tron la chuoi va bui nho.

@export var wind_speed: float = 120.0  ## Toc do gio (px/s)
@export var particle_count: int = 35   ## So luong hat
@export var wind_alpha: float = 0.55   ## Do mo cua hat

const LEAF_TEX := preload("res://assets/HieuUng/leaf_banana.png")

var _particles: Array[Sprite2D] = []
var _velocities: Array[Vector2] = []
var _rot_speeds: Array[float] = []
var _vp_size: Vector2 = Vector2.ZERO

## Shared procedural dust textures (avoid per-particle GPU allocation)
var _dust_textures: Array[ImageTexture] = []

func _ready() -> void:
	_vp_size = get_viewport_rect().size
	z_index = 50  # Tren background
	_create_dust_textures()
	_spawn_particles()
	get_tree().get_root().size_changed.connect(func(): _vp_size = get_viewport_rect().size)


func _create_dust_textures() -> void:
	## Tao 3 texture bui dung chung thay vi 1 texture rieng cho moi hat.
	var colors: Array[Color] = [
		Color(0.55, 0.8, 0.3, wind_alpha),       # la xanh
		Color(0.65, 0.85, 0.4, wind_alpha),       # la nhat
		Color(0.95, 0.95, 0.9, wind_alpha * 0.7), # bui trang
	]
	for c in colors:
		var img := Image.create(4, 6, false, Image.FORMAT_RGBA8)
		img.fill(c)
		_dust_textures.append(ImageTexture.create_from_image(img))


func _spawn_particles() -> void:
	for i in range(particle_count):
		var leaf := Sprite2D.new()
		leaf.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		if randf() < 0.55:
			leaf.texture = LEAF_TEX
			var s: float = 0.7 + randf() * 1.1
			leaf.scale = Vector2(s, s)
			leaf.modulate = Color(1, 1, 1, wind_alpha * (0.45 + randf() * 0.4))
		else:
			leaf.texture = _dust_textures[randi() % _dust_textures.size()]
			leaf.scale = Vector2(1.0 + randf() * 1.5, 1.0 + randf() * 0.8)
			leaf.modulate.a = wind_alpha * (0.5 + randf() * 0.5)
		leaf.rotation = randf() * TAU
		leaf.position = Vector2(randf() * _vp_size.x, randf() * _vp_size.y)
		add_child(leaf)
		_particles.append(leaf)

		# Van toc ngau nhien: chu yeu sang trai, lac nhe doc
		var vx: float = -(wind_speed * (0.6 + randf() * 0.8))
		var vy: float = (randf() - 0.5) * 30.0
		_velocities.append(Vector2(vx, vy))

		# Toc do xoay co dinh cho tung hat (tranh randf moi frame -> jitter)
		_rot_speeds.append((0.5 + randf() * 0.3) * sign(vx))


func _process(delta: float) -> void:
	for i in range(_particles.size()):
		var p: Sprite2D = _particles[i]
		var v: Vector2 = _velocities[i]

		# Di chuyen
		p.position += v * delta

		# Lac nhe (sin wave)
		p.position.y += sin(p.position.x * 0.02 + _velocities[i].x * 0.01) * 0.5

		# Xoay nhe (toc do co dinh, khong goi randf moi frame)
		p.rotation += delta * _rot_speeds[i]

		# Wrap khi ra ngoai man hinh
		if p.position.x < -20.0:
			p.position.x = _vp_size.x + 10.0
			p.position.y = randf() * _vp_size.y
		if p.position.y < -20.0 or p.position.y > _vp_size.y + 20.0:
			p.position.y = randf() * _vp_size.y
