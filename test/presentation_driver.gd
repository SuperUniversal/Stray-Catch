extends Node
## 15s @ 30fps: miss, hit+mash tug, miss, hit+tug.

var _f: int = 0
var _mash: bool = false


func _process(_delta: float) -> void:
	var main: Node = get_parent()
	var s: GameSession = main.get("session")
	if s == null:
		_f += 1
		return
	if _f == 2:
		if s.phase == &"ready":
			s.start()
		s.aim(640.0)
	if _f == 40:
		s.force_hit = 0
		s.aim(360.0)
		_tap(main)
	if _f == 130:
		_mash = false
		s.force_hit = 1
		s.aim(s.dog_x)
		_tap(main)
		_mash = true
	if _f == 230:
		_mash = false
	if _f == 250:
		s.force_hit = 0
		s.aim(420.0)
		_tap(main)
	if _f == 370:
		s.force_hit = 1
		s.aim(s.dog_x)
		_tap(main)
		_mash = true
	if _mash and s.phase == &"tug" and (_f % 2) == 0:
		_tap(main)
	_f += 1


func _tap(main: Node) -> void:
	if main.has_method("do_tap"):
		main.call("do_tap")
