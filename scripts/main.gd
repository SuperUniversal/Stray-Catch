extends Node2D
## Root: GameSession 1/60, aim/tap/pause, bind dog/catcher/lasso/HUD.

var session: GameSession = GameSession.new()
var _acc: float = 0.0
var _left: bool = false
var _right: bool = false

@onready var dog: AnimatedSprite2D = $ChoCo
@onready var catcher: AnimatedSprite2D = $Catcher
@onready var hud: CanvasLayer = $HUD
@onready var lasso_back: Node2D = $LassoBehind
@onready var lasso_front: Node2D = $LassoFront


func _ready() -> void:
	if dog.has_method("bind_session"):
		dog.call("bind_session", session)
	if catcher.has_method("bind_session"):
		catcher.call("bind_session", session)
	if hud.has_method("bind_session"):
		hud.call("bind_session", session)
	if lasso_back.has_method("bind"):
		lasso_back.call("bind", session, catcher)
	if lasso_front.has_method("bind"):
		lasso_front.call("bind", session, catcher)
	if Engine.get_write_movie_path() != "":
		session.start()
	if Engine.get_write_movie_path() == "":
		return
	if has_node("PresentationDriver"):
		return
	var driver := Node.new()
	driver.name = "PresentationDriver"
	driver.set_script(load("res://test/presentation_driver.gd"))
	add_child(driver)


func _process(delta: float) -> void:
	if session.phase == &"idle" or session.phase == &"ready":
		var dir: float = (1.0 if _right else 0.0) - (1.0 if _left else 0.0)
		if dir != 0.0:
			session.aim(session.aim_x + dir * 600.0 * delta)
	_acc += delta
	while _acc >= GameSession.DT:
		_acc -= GameSession.DT
		session.tick()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if session.phase == &"idle" or session.phase == &"ready":
			session.aim(GameLayout.to_design(event.position, get_viewport_rect().size).x)
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if session.phase == &"idle" or session.phase == &"ready":
			session.aim(GameLayout.to_design(event.position, get_viewport_rect().size).x)
		act()
		get_viewport().set_input_as_handled()
	if event is InputEventKey:
		if event.keycode == KEY_LEFT:
			_left = event.pressed
		elif event.keycode == KEY_RIGHT:
			_right = event.pressed
		if not event.pressed or event.echo:
			return
		if event.keycode == KEY_P or event.keycode == KEY_ESCAPE:
			session.pause_toggle()
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_SPACE:
			act()
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_R and session.phase == &"over":
			session.reset()
			session.start()
			get_viewport().set_input_as_handled()


func act() -> void:
	if session.phase == &"ready":
		session.start()
		return
	if session.phase == &"over" or session.phase == &"paused":
		return
	var origin := Vector2(640, 490)
	if catcher and catcher.has_method("tool_tip_global"):
		var tip = catcher.call("tool_tip_global")
		var dtip: Vector2 = GameLayout.to_design(tip, get_viewport_rect().size)
		origin = Vector2(dtip.x + (session.aim_x - 640.0) * 0.10, dtip.y - 62.0)
	session.tap(origin)


func do_tap() -> void:
	act()
