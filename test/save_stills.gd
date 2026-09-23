extends SceneTree
## Windowed stills via frame_post_draw. No movie writer.
## godot --path . --fixed-fps 30 --script test/save_stills.gd

const SWINGS := {35: 0, 90: 1}
const SHOTS := {
	20: "idle",
	28: "walk",
	40: "windup",
	50: "swing",
	64: "miss",
	96: "open",
	108: "spin",
	118: "catch",
	130: "sit",
}

var _main: Node
var _frame: int = 0

func _initialize() -> void:
	get_root().size = Vector2i(1280, 720)
	_main = (load("res://main.tscn") as PackedScene).instantiate()
	get_root().add_child(_main)
	RenderingServer.frame_post_draw.connect(_on_drawn)

func _on_drawn() -> void:
	_frame += 1
	if SWINGS.has(_frame):
		var c: Node = _main.get_node_or_null("Catcher")
		if c and c.has_method("swing"):
			c.call("swing", SWINGS[_frame])
			print("swing %d force=%d" % [_frame, SWINGS[_frame]])
	if SHOTS.has(_frame):
		var img: Image = get_root().get_texture().get_image()
		if img != null:
			var gp: String = ProjectSettings.globalize_path("res://screenshots/result/dog_qa_%s.png" % SHOTS[_frame])
			var e: int = img.save_png(gp)
			print("shot %s err=%d -> %s" % [SHOTS[_frame], e, gp])
		else:
			print("img NULL at frame %d" % _frame)
	if _frame % 30 == 0:
		print("frame %d" % _frame)
	if _frame > 140:
		quit()

func _process(_delta: float) -> bool:
	return false
