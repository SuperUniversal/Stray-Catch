extends SceneTree
## Capture tam thoi: load main.tscn, phat swing, luu vai khung ra screenshots/.
## Chay: godot --path . --script test/capture_catcher.gd

var _main: Node
var _frame: int = 0
const SHOTS := {6: "idle", 20: "s1", 23: "s2", 26: "s3", 29: "s4", 32: "s5", 36: "s6"}

func _initialize() -> void:
	get_root().size = Vector2i(1280, 720)
	_main = (load("res://main.tscn") as PackedScene).instantiate()
	get_root().add_child(_main)
	RenderingServer.frame_post_draw.connect(_on_drawn)

func _on_drawn() -> void:
	_frame += 1
	if _frame == 15:
		var c := _main.get_node_or_null("Catcher")
		if c and c.has_method("swing"):
			c.swing()
			print("swing triggered")
	if SHOTS.has(_frame):
		var img := get_root().get_texture().get_image()
		if img != null:
			var gp := ProjectSettings.globalize_path("res://screenshots/cap_%s.png" % SHOTS[_frame])
			var e := img.save_png(gp)
			print("shot %s err=%d -> %s" % [SHOTS[_frame], e, gp])
		else:
			print("img NULL at frame %d" % _frame)
	if _frame > 44:
		quit()

func _process(_delta: float) -> bool:
	return false
