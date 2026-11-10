class_name SkyfoldFlightSim
extends RefCounted

## Deterministic, node-free flight simulation.
##
## The view reads `get_snapshot()` and never mutates this object. The controller
## feeds one fixed step at a time. No Input, scene tree, audio, or global RNG is
## allowed here; `tools/verify_project.gd` enforces that boundary.

const STEP := 1.0 / 120.0
const VIEW_W := 1920.0
const VIEW_H := 1080.0

const CRANE_X := 560.0
const CRANE_HALF_W := 22.0
const CRANE_HALF_H := 14.0

const GRAVITY := 1850.0
const FLAP_VELOCITY := -620.0
const TERMINAL_VELOCITY := 980.0
const GLIDE_GRAVITY_SCALE := 0.55
const GLIDE_SPEED_SCALE := 1.15

const BASE_SPEED := 330.0
const GATE_WIDTH := 92.0
const GATE_GAP := 300.0
const GATE_MIN_GAP := 220.0
const GATE_MAX_GAP := 360.0
const GATE_SPACING := 560.0
const GATE_MARGIN := 110.0
const GATE_MAX_STEP := 240.0

const COMBO_WINDOW := 6.0
const THREAD_FRACTION := 0.35
const GRAZE_PX := 8.0

var config: Dictionary = {}

var seed_value: int = 1
var rng: SkyfoldRng
var time_s: float = 0.0

var bird_y: float = VIEW_H * 0.5
var bird_vy: float = 0.0
var bird_rotation: float = 0.0

var alive: bool = true
var finished: bool = false
var crashed: bool = false
var crash_reason: String = ""
var paused: bool = false
var gliding: bool = false

var score: int = 0
var distance_m: float = 0.0
var gates_passed: int = 0
var threads: int = 0
var grazes: int = 0
var combo: int = 0
var best_combo: int = 0
var multiplier: int = 1
var combo_timer: float = 0.0
var flaps: int = 0

var gates: Array[Dictionary] = []

var _next_gate_x: float = 0.0
var _distance_score_carry: float = 0.0


func _init(p_seed: int = 1, p_config: Dictionary = {}) -> void:
	config = p_config.duplicate(true)
	reset(p_seed)


func reset(p_seed: int = 1) -> void:
	seed_value = p_seed
	rng = SkyfoldRng.new(p_seed)

	time_s = 0.0
	bird_y = VIEW_H * 0.5
	bird_vy = 0.0
	bird_rotation = 0.0
	alive = true
	finished = false
	crashed = false
	crash_reason = ""
	paused = false
	gliding = false

	score = 0
	distance_m = 0.0
	gates_passed = 0
	threads = 0
	grazes = 0
	combo = 0
	best_combo = 0
	multiplier = 1
	combo_timer = 0.0
	flaps = 0

	gates.clear()
	_next_gate_x = VIEW_W + 40.0
	_distance_score_carry = 0.0
	_spawn_gate(_next_gate_x)
	_next_gate_x += _gate_spacing()


func set_paused(value: bool) -> void:
	paused = value


func restart() -> void:
	reset(seed_value)


func step_fixed(flap_pressed: bool, glide_held: bool) -> void:
	if paused or not alive:
		return

	time_s += STEP
	gliding = glide_held

	if flap_pressed:
		_flap()

	var gravity := GRAVITY
	if gliding:
		gravity *= GLIDE_GRAVITY_SCALE
	bird_vy = minf(bird_vy + gravity * STEP, TERMINAL_VELOCITY)
	bird_y += bird_vy * STEP

	if bird_y - CRANE_HALF_H < 0.0:
		bird_y = CRANE_HALF_H
		bird_vy = maxf(bird_vy, 0.0)

	if bird_y + CRANE_HALF_H >= VIEW_H:
		_crash("ground")
		return

	var rotation_target := clampf(bird_vy / 900.0, -0.45, 0.9)
	bird_rotation = lerpf(bird_rotation, rotation_target, 0.15)

	if combo_timer > 0.0:
		combo_timer -= STEP
		if combo_timer <= 0.0:
			combo = 0
			multiplier = 1

	var speed := _current_speed()
	var delta_m := speed * STEP / 10.0
	distance_m += delta_m
	_distance_score_carry += delta_m
	while _distance_score_carry >= 10.0:
		_distance_score_carry -= 10.0
		score += 1

	_next_gate_x -= speed * STEP
	if _next_gate_x < VIEW_W + 200.0:
		_spawn_gate(_next_gate_x)
		_next_gate_x += _gate_spacing()

	for gate in gates:
		gate["x"] = float(gate["x"]) - speed * STEP
		_check_gate(gate)
		if not alive:
			return

	var kept: Array[Dictionary] = []
	for gate in gates:
		if float(gate["x"]) + _gate_width() > -200.0:
			kept.append(gate)
	gates = kept


func finish_run() -> void:
	if not alive:
		return
	alive = false
	finished = true
	bird_vy = 0.0


func get_snapshot() -> Dictionary:
	var gate_snapshots: Array[Dictionary] = []
	for gate in gates:
		gate_snapshots.append(gate.duplicate(true))
	return {
		"time_s": time_s,
		"seed": seed_value,
		"bird_y": bird_y,
		"bird_vy": bird_vy,
		"bird_rotation": bird_rotation,
		"alive": alive,
		"finished": finished,
		"crashed": crashed,
		"crash_reason": crash_reason,
		"paused": paused,
		"gliding": gliding,
		"score": score,
		"distance_m": distance_m,
		"gates_passed": gates_passed,
		"threads": threads,
		"grazes": grazes,
		"combo": combo,
		"best_combo": best_combo,
		"multiplier": multiplier,
		"combo_timer": combo_timer,
		"flaps": flaps,
		"gates": gate_snapshots,
	}


func get_crane_rect() -> Rect2:
	return Rect2(
		CRANE_X - CRANE_HALF_W,
		bird_y - CRANE_HALF_H,
		CRANE_HALF_W * 2.0,
		CRANE_HALF_H * 2.0
	)


func get_gate_rect(gate: Dictionary) -> Rect2:
	return Rect2(float(gate["x"]), float(gate["gap_y"]) - float(gate["gap_h"]) * 0.5,
		_gate_width(), float(gate["gap_h"]))


func get_gate_gap_rect(gate: Dictionary) -> Rect2:
	return get_gate_rect(gate)


func get_gate_top_rect(gate: Dictionary) -> Rect2:
	var gap_top := float(gate["gap_y"]) - float(gate["gap_h"]) * 0.5
	return Rect2(float(gate["x"]), 0.0, _gate_width(), maxf(gap_top, 0.0))


func get_gate_bottom_rect(gate: Dictionary) -> Rect2:
	var gap_bottom := float(gate["gap_y"]) + float(gate["gap_h"]) * 0.5
	return Rect2(float(gate["x"]), gap_bottom, _gate_width(), maxf(VIEW_H - gap_bottom, 0.0))


func is_in_thread_zone(gate: Dictionary) -> bool:
	var half_thread := float(gate["gap_h"]) * THREAD_FRACTION * 0.5
	return absf(bird_y - float(gate["gap_y"])) <= half_thread


func is_grazing(gate: Dictionary) -> bool:
	var edge_distance := float(gate["gap_h"]) * 0.5 - absf(bird_y - float(gate["gap_y"]))
	return edge_distance <= GRAZE_PX


func _flap() -> void:
	bird_vy = FLAP_VELOCITY
	flaps += 1


func _crash(reason: String) -> void:
	if not alive:
		return
	alive = false
	crashed = true
	crash_reason = reason
	bird_vy = 0.0
	combo = 0
	multiplier = 1


func _check_gate(gate: Dictionary) -> void:
	var gate_left := float(gate["x"])
	var gate_right := gate_left + _gate_width()
	var crane_left := CRANE_X - CRANE_HALF_W
	var crane_right := CRANE_X + CRANE_HALF_W

	if gate_right < crane_left:
		if not bool(gate["passed"]):
			_award_gate(gate)
		return

	if gate_left > crane_right:
		return

	var gap_top := float(gate["gap_y"]) - float(gate["gap_h"]) * 0.5
	var gap_bottom := float(gate["gap_y"]) + float(gate["gap_h"]) * 0.5
	if bird_y - CRANE_HALF_H < gap_top or bird_y + CRANE_HALF_H > gap_bottom:
		_crash("gate")


func _award_gate(gate: Dictionary) -> void:
	gate["passed"] = true
	gates_passed += 1
	score += int(round(10.0 * float(multiplier)))

	if is_in_thread_zone(gate):
		gate["threaded"] = true
		threads += 1
		combo += 1
		best_combo = maxi(best_combo, combo)
		combo_timer = COMBO_WINDOW
		multiplier = clampi(1 + int(combo / 2), 1, 5)
		score += int(round(15.0 * float(multiplier)))
	elif is_grazing(gate):
		gate["grazed"] = true
		grazes += 1
		score += 5


func _spawn_gate(x: float) -> void:
	var gap_h := clampf(
		float(config.get("gate_gap", GATE_GAP)) - float(gates_passed) * 4.0,
		GATE_MIN_GAP,
		GATE_MAX_GAP
	)
	var min_center := GATE_MARGIN + gap_h * 0.5
	var max_center := VIEW_H - GATE_MARGIN - gap_h * 0.5
	var gap_y := rng.range_float(min_center, max_center)

	if not gates.is_empty():
		var previous_y := float(gates[-1]["gap_y"])
		gap_y = clampf(gap_y, previous_y - GATE_MAX_STEP, previous_y + GATE_MAX_STEP)
		gap_y = clampf(gap_y, min_center, max_center)

	var kinds := ["arch", "bell", "windmill"]
	var kind: String = kinds[rng.range_int(0, kinds.size())]
	gates.append({
		"x": x,
		"gap_y": gap_y,
		"gap_h": gap_h,
		"kind": kind,
		"passed": false,
		"threaded": false,
		"grazed": false,
	})


func _current_speed() -> float:
	var speed := float(config.get("base_speed", BASE_SPEED))
	if gliding:
		speed *= GLIDE_SPEED_SCALE
	var ramp := 1.0 + minf(float(gates_passed) * 0.004, 0.30)
	return speed * ramp


func _gate_width() -> float:
	return float(config.get("gate_width", GATE_WIDTH))


func _gate_spacing() -> float:
	return float(config.get("gate_spacing", GATE_SPACING))
