extends Sprite2D
## Background cover-fit — Sprite2D phu kin viewport, tu co dan khi resize.
## Khong dung CanvasLayer, khong dung TextureRect, khong dung anchors.

func _ready() -> void:
	texture = preload("res://assets/HinhNen/HinhNen1.png")
	centered = false
	z_index = -100
	_fit()
	get_tree().get_root().size_changed.connect(_fit)

func _fit() -> void:
	var vp := get_viewport_rect().size
	var tex_size := Vector2(texture.get_width(), texture.get_height())
	# Cover: scale du lon de phu kin ca 2 chieu
	var s := maxf(vp.x / tex_size.x, vp.y / tex_size.y)
	scale = Vector2(s, s)
	# Canh giua
	var scaled := tex_size * s
	position = (vp - scaled) * 0.5
