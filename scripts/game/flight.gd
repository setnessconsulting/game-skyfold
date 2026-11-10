extends Node2D

## Grey-box presentation and input for the deterministic flight simulation.
## This scene is intentionally placeholder art: the point of Gate 0 is to prove
## the flap/glide feel and the simulation boundary, not the final look.

const FlightSimScript = preload("res://scripts/sim/flight_sim.gd")
const STEP := 1.0 / 120.0

const SKY := Color("#0d1726")
const SKY_FAR := Color("#16243a")
const SKY_NEAR := Color("#1d314a")
const PAPER := Color("#f3e7cf")
const PAPER_DARK := Color("#c8a97a")
const GOLD := Color("#e8c76a")
const GATE := Color("#46647f")
const GATE_EDGE := Color("#8fb2c9")
const DANGER := Color("#d36b5f")
const MUTED := Color("#8ea3b5")

var sim: SkyfoldFlightSim

var _accumulator: float = 0.0
var _flap_buffer: float = 0.0
var _paused: bool = false
var _last_flap_ms: int = -1000
var _best_score: int = 0


func _ready() -> void:
	sim = SkyfoldFlightSim.new(20261110)
	queue_redraw()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("flap"):
		_queue_flap()
	elif event.is_action_pressed("pause"):
		_toggle_pause()
	elif event.is_action_pressed("restart"):
		_restart()
	elif event.is_action_pressed("mute"):
		AudioServer.set_bus_mute(0, not AudioServer.is_bus_mute(0))
	elif event.is_action_pressed("fullscreen"):
		_toggle_fullscreen()
	elif event is InputEventMouseButton:
		var mouse := event as InputEventMouseButton
		if mouse.button_index == MOUSE_BUTTON_LEFT and mouse.pressed:
			_queue_flap()


func _physics_process(delta: float) -> void:
	if _paused:
		return

	_accumulator += minf(delta, 0.25)
	while _accumulator >= STEP:
		_accumulator -= STEP
		_flap_buffer = maxf(_flap_buffer - STEP, 0.0)

		var flap := _flap_buffer > 0.0
		if flap:
			_flap_buffer = 0.0

		var glide := Input.is_action_pressed("flap") or Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
		sim.step_fixed(flap, glide)

		if not sim.alive:
			_best_score = maxi(_best_score, sim.score)
			break

	queue_redraw()


func _queue_flap() -> void:
	if _paused:
		return
	if not sim.alive:
		_restart()
		return

	var now := Time.get_ticks_msec()
	if now - _last_flap_ms < 80:
		return
	_last_flap_ms = now
	_flap_buffer = 0.1


func _restart() -> void:
	_best_score = maxi(_best_score, sim.score)
	sim.restart()
	_accumulator = 0.0
	_flap_buffer = 0.0
	_paused = false
	queue_redraw()


func _toggle_pause() -> void:
	if not sim.alive:
		return
	_paused = not _paused
	sim.set_paused(_paused)
	queue_redraw()


func _toggle_fullscreen() -> void:
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)


func _draw() -> void:
	_draw_sky()
	_draw_wind()
	_draw_gates()
	_draw_crane()
	_draw_hud()

	if _paused:
		_draw_pause_overlay()
	elif not sim.alive:
		_draw_crash_overlay()


func _draw_sky() -> void:
	draw_rect(Rect2(0.0, 0.0, sim.VIEW_W, sim.VIEW_H), SKY)
	draw_rect(Rect2(0.0, 0.0, sim.VIEW_W, 360.0), SKY_FAR)
	draw_rect(Rect2(0.0, 360.0, sim.VIEW_W, 260.0), SKY_NEAR)

	draw_circle(Vector2(1560.0, 210.0), 74.0, Color(GOLD, 0.18))
	draw_circle(Vector2(1560.0, 210.0), 42.0, Color(GOLD, 0.75))

	for i in range(4):
		var y := 230.0 + float(i) * 150.0
		var offset := fmod(sim.time_s * (14.0 + float(i) * 7.0), sim.VIEW_W)
		draw_line(Vector2(-offset, y), Vector2(sim.VIEW_W - offset, y), Color(1, 1, 1, 0.035), 2.0)
		draw_line(Vector2(sim.VIEW_W - offset, y), Vector2(sim.VIEW_W * 2.0 - offset, y), Color(1, 1, 1, 0.035), 2.0)

	draw_rect(Rect2(0.0, sim.VIEW_H - 12.0, sim.VIEW_W, 12.0), Color(DANGER, 0.55))
	draw_string(ThemeDB.fallback_font, Vector2(40.0, 70.0), "SKYFOLD", HORIZONTAL_ALIGNMENT_LEFT, -1, 30, Color(PAPER, 0.9))
	draw_string(ThemeDB.fallback_font, Vector2(40.0, 100.0), "grey-box flight", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color(MUTED, 0.9))


func _draw_wind() -> void:
	var base := fmod(sim.time_s * 90.0, sim.VIEW_W)
	for i in range(8):
		var y := 160.0 + float(i) * 108.0
		var x := sim.VIEW_W - fmod(base + float(i) * 231.0, sim.VIEW_W)
		draw_line(Vector2(x, y), Vector2(x + 120.0, y), Color(1, 1, 1, 0.06), 2.0)
		draw_line(Vector2(x + 150.0, y + 26.0), Vector2(x + 230.0, y + 26.0), Color(1, 1, 1, 0.04), 1.5)


func _draw_gates() -> void:
	for gate in sim.gates:
		var top := sim.get_gate_top_rect(gate)
		var bottom := sim.get_gate_bottom_rect(gate)
		var gap := sim.get_gate_gap_rect(gate)
		var gate_color := GATE
		if bool(gate["threaded"]):
			gate_color = Color("#587f73")
		elif bool(gate["grazed"]):
			gate_color = Color("#7d6b4f")

		draw_rect(top, gate_color)
		draw_rect(bottom, gate_color)
		draw_rect(top, GATE_EDGE, false, 3.0)
		draw_rect(bottom, GATE_EDGE, false, 3.0)

		var thread_height := gap.size.y * sim.THREAD_FRACTION
		var thread_rect := Rect2(gap.position.x, gap.position.y + (gap.size.y - thread_height) * 0.5, gap.size.x, thread_height)
		draw_rect(thread_rect, Color(GOLD, 0.10))
		draw_line(Vector2(gap.position.x, gap.position.y + gap.size.y * 0.5),
			Vector2(gap.position.x + gap.size.x, gap.position.y + gap.size.y * 0.5),
			Color(GOLD, 0.35), 2.0)

		var label := str(gate["kind"])
		draw_string(ThemeDB.fallback_font, top.position + Vector2(12.0, 28.0), label,
			HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color(PAPER, 0.45))


func _draw_crane() -> void:
	var snap := sim.get_snapshot()
	var y := float(snap["bird_y"])
	var tilt := float(snap["bird_rotation"])
	var gliding := bool(snap["gliding"])

	for i in range(3):
		var alpha := 0.08 * float(3 - i)
		draw_circle(Vector2(sim.CRANE_X - 46.0 - float(i) * 18.0, y), 7.0 - float(i), Color(PAPER, alpha))

	draw_set_transform(Vector2(sim.CRANE_X, y), tilt, Vector2.ONE)
	var body := PackedVector2Array([
		Vector2(-30.0, 4.0),
		Vector2(-9.0, -10.0),
		Vector2(8.0, -5.0),
		Vector2(30.0, -16.0),
		Vector2(19.0, 3.0),
		Vector2(33.0, 14.0),
		Vector2(4.0, 9.0),
		Vector2(-7.0, 18.0),
		Vector2(-20.0, 11.0),
	])
	draw_colored_polygon(body, PAPER if not bool(snap["crashed"]) else Color(DANGER, 0.9))
	draw_polyline(body + PackedVector2Array([body[0]]), PAPER_DARK, 2.0, true)
	draw_line(Vector2(-5.0, -4.0), Vector2(20.0, -11.0), PAPER_DARK, 2.0, true)
	draw_line(Vector2(-7.0, 2.0), Vector2(18.0, 8.0), Color(PAPER_DARK, 0.6), 1.5, true)

	if gliding:
		draw_line(Vector2(-16.0, -18.0), Vector2(10.0, -24.0), Color(GOLD, 0.75), 2.0, true)
		draw_line(Vector2(8.0, -24.0), Vector2(22.0, -17.0), Color(GOLD, 0.45), 1.5, true)

	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func _draw_hud() -> void:
	var font := ThemeDB.fallback_font
	draw_string(font, Vector2(40.0, 150.0), "SCORE  %d" % sim.score, HORIZONTAL_ALIGNMENT_LEFT, -1, 34, PAPER)
	draw_string(font, Vector2(40.0, 184.0), "DIST  %d m" % int(sim.distance_m), HORIZONTAL_ALIGNMENT_LEFT, -1, 20, MUTED)
	draw_string(font, Vector2(40.0, 216.0), "THREAD  %d   COMBO x%d" % [sim.threads, sim.multiplier],
		HORIZONTAL_ALIGNMENT_LEFT, -1, 20, GOLD if sim.multiplier > 1 else MUTED)

	draw_string(font, Vector2(sim.VIEW_W - 360.0, 70.0), "BEST  %d" % _best_score,
		HORIZONTAL_ALIGNMENT_RIGHT, 320.0, 22, PAPER)
	draw_string(font, Vector2(sim.VIEW_W - 360.0, 100.0), "GATES  %d" % sim.gates_passed,
		HORIZONTAL_ALIGNMENT_RIGHT, 320.0, 16, MUTED)

	if sim.time_s < 2.2 and sim.flaps == 0:
		draw_string(font, Vector2(0.0, 500.0), "TAP OR SPACE TO FLY",
			HORIZONTAL_ALIGNMENT_CENTER, sim.VIEW_W, 38, Color(PAPER, 0.9))
		draw_string(font, Vector2(0.0, 542.0), "hold after a flap to glide",
			HORIZONTAL_ALIGNMENT_CENTER, sim.VIEW_W, 22, Color(MUTED, 0.9))


func _draw_crash_overlay() -> void:
	draw_rect(Rect2(0.0, 0.0, sim.VIEW_W, sim.VIEW_H), Color(0.02, 0.03, 0.05, 0.55))
	draw_string(ThemeDB.fallback_font, Vector2(0.0, 450.0), "THE FOLD TORE",
		HORIZONTAL_ALIGNMENT_CENTER, sim.VIEW_W, 54, PAPER)
	draw_string(ThemeDB.fallback_font, Vector2(0.0, 505.0),
		"score %d   •   %d m   •   %d threads" % [sim.score, int(sim.distance_m), sim.threads],
		HORIZONTAL_ALIGNMENT_CENTER, sim.VIEW_W, 24, GOLD)
	draw_string(ThemeDB.fallback_font, Vector2(0.0, 580.0), "tap, click, or press Space to retry",
		HORIZONTAL_ALIGNMENT_CENTER, sim.VIEW_W, 22, Color(MUTED, 0.95))


func _draw_pause_overlay() -> void:
	draw_rect(Rect2(0.0, 0.0, sim.VIEW_W, sim.VIEW_H), Color(0.02, 0.03, 0.05, 0.62))
	draw_string(ThemeDB.fallback_font, Vector2(0.0, 470.0), "PAUSED",
		HORIZONTAL_ALIGNMENT_CENTER, sim.VIEW_W, 54, PAPER)
	draw_string(ThemeDB.fallback_font, Vector2(0.0, 525.0), "Esc / P to resume   •   R to restart",
		HORIZONTAL_ALIGNMENT_CENTER, sim.VIEW_W, 22, MUTED)
