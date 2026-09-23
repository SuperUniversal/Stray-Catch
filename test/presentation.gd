extends SceneTree
## Trinh dien: miss -> hit+tug -> miss -> hit+tug.
## Video: godot --path . --write-movie screenshots/result/frame.png --fixed-fps 30 --quit-after 450 --script test/presentation.gd

# Timing that su nam o presentation_driver.gd (miss/catch/miss/catch).

func _initialize() -> void:
	get_root().size = Vector2i(1280, 720)
	var main: Node = (load("res://main.tscn") as PackedScene).instantiate()
	get_root().add_child(main)
	if main.has_node("PresentationDriver"):
		return
	var driver := Node.new()
	driver.name = "PresentationDriver"
	driver.set_script(load("res://test/presentation_driver.gd"))
	main.add_child(driver)

func _process(_delta: float) -> bool:
	return false
