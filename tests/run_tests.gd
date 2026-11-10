extends SceneTree

## Zero-dependency headless test runner.
##   godot --headless --path . --script res://tests/run_tests.gd
##
## The simulation is the authority for gameplay rules. These tests cover the
## deterministic core, scoring, collision, restart, and the seeded RNG.

const FlightSimScript = preload("res://scripts/sim/flight_sim.gd")
const RngScript = preload("res://scripts/sim/rng.gd")

var tests: int = 0
var checks: int = 0
var failures: int = 0
var current: String = ""


func _initialize() -> void:
	print("Skyfold — Gate 0 core tests")

	_test_initial_state()
	_test_flap_sets_upward_velocity()
	_test_gravity_pulls_down()
	_test_terminal_velocity_clamped()
	_test_glide_reduces_descent()
	_test_glide_increases_speed()
	_test_gate_spawns_ahead()
	_test_gate_moves_left()
	_test_gate_gap_within_bounds()
	_test_gate_spacing()
	_test_thread_scores_more()
	_test_graze_scores()
	_test_normal_pass_scores()
	_test_gate_collision_crashes()
	_test_bottom_crash()
	_test_top_clamp_is_safe()
	_test_restart_resets()
	_test_pause_stops_time()
	_test_finish_state()
	_test_combo_multiplier()
	_test_combo_expires()
	_test_rng_is_reproducible()
	_test_rng_differs_by_seed()
	_test_seeded_gates_are_reproducible()
	_test_no_nan_under_fuzz()
	_test_gate_count_is_bounded()
	_test_distance_score()
	_test_gate_gap_shrinks()
	_test_snapshot_shape()
	_test_crane_rect()
	_test_gate_rects_tile_the_screen()
	_test_thread_and_graze_zones()
	_test_flap_count()
	_test_gate_kind_is_seeded()

	print("")
	if failures == 0:
		print("PASS %d tests, %d checks" % [tests, checks])
		quit(0)
	else:
		print("FAIL %d tests, %d checks, %d failures" % [tests, checks, failures])
		quit(1)


func _begin(test_name: String) -> void:
	current = test_name
	tests += 1
	print("• %s" % test_name)


func _check(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		print("  FAIL [%s] %s" % [current, message])


func _eq(actual: Variant, expected: Variant, message: String) -> void:
	checks += 1
	if actual != expected:
		failures += 1
		print("  FAIL [%s] %s (expected %s, got %s)" % [current, message, str(expected), str(actual)])


func _almost_eq(actual: float, expected: float, tolerance: float, message: String) -> void:
	checks += 1
	if absf(actual - expected) > tolerance:
		failures += 1
		print("  FAIL [%s] %s (expected %.4f ± %.4f, got %.4f)" % [current, message, expected, tolerance, actual])


func _new_sim(seed_value: int = 42, config: Dictionary = {}) -> SkyfoldFlightSim:
	return FlightSimScript.new(seed_value, config)


func _place_gate_left(sim: SkyfoldFlightSim) -> void:
	sim.gates[0]["x"] = FlightSimScript.CRANE_X - 240.0


func _test_initial_state() -> void:
	_begin("initial state")
	var sim := _new_sim()
	_check(sim.alive, "starts alive")
	_check(not sim.crashed, "starts uncrashed")
	_eq(sim.score, 0, "starts at zero score")
	_eq(sim.gates_passed, 0, "starts with no gates passed")
	_eq(sim.multiplier, 1, "starts at x1")
	_almost_eq(sim.bird_y, FlightSimScript.VIEW_H * 0.5, 0.01, "starts centered")
	_check(sim.gates.size() >= 1, "has at least one gate")
	_check(float(sim.gates[0]["x"]) > FlightSimScript.VIEW_W, "first gate starts off-screen")


func _test_flap_sets_upward_velocity() -> void:
	_begin("flap sets upward velocity")
	var sim := _new_sim()
	var start_y := sim.bird_y
	sim.step_fixed(true, false)
	_check(sim.bird_vy < 0.0, "flap gives negative (up) velocity")
	_check(sim.bird_y < start_y, "crane rises after a flap")
	_eq(sim.flaps, 1, "flap count increments")


func _test_gravity_pulls_down() -> void:
	_begin("gravity pulls down")
	var sim := _new_sim()
	sim.step_fixed(false, false)
	_check(sim.bird_vy > 0.0, "gravity gives positive (down) velocity")
	_check(sim.bird_y > FlightSimScript.VIEW_H * 0.5, "crane falls")


func _test_terminal_velocity_clamped() -> void:
	_begin("terminal velocity clamped")
	var sim := _new_sim()
	for i in range(70):
		sim.step_fixed(false, false)
	_check(sim.bird_vy <= FlightSimScript.TERMINAL_VELOCITY + 0.01, "velocity never exceeds terminal")
	_check(sim.alive, "still alive after 70 steps")


func _test_glide_reduces_descent() -> void:
	_begin("glide reduces descent")
	var fall := _new_sim()
	var glide := _new_sim()
	for i in range(60):
		fall.step_fixed(false, false)
		glide.step_fixed(false, true)
	_check(glide.bird_y < fall.bird_y, "glide stays higher than free fall")
	_check(glide.gliding, "glide state is reported")


func _test_glide_increases_speed() -> void:
	_begin("glide increases forward speed")
	var fall := _new_sim()
	var glide := _new_sim()
	fall.step_fixed(false, false)
	glide.step_fixed(false, true)
	_check(glide.distance_m > fall.distance_m, "glide covers more distance in one step")


func _test_gate_spawns_ahead() -> void:
	_begin("gate spawns ahead")
	var sim := _new_sim()
	_check(sim.gates.size() >= 1, "gate exists")
	_check(float(sim.gates[0]["x"]) > FlightSimScript.CRANE_X, "gate is ahead of the crane")


func _test_gate_moves_left() -> void:
	_begin("gate moves left")
	var sim := _new_sim()
	var before := float(sim.gates[0]["x"])
	for i in range(10):
		sim.step_fixed(false, false)
	_check(float(sim.gates[0]["x"]) < before, "gate moves toward the crane")


func _test_gate_gap_within_bounds() -> void:
	_begin("gate gap within bounds")
	var sim := _new_sim()
	for gate in sim.gates:
		var gap_h := float(gate["gap_h"])
		var gap_y := float(gate["gap_y"])
		_check(gap_h >= FlightSimScript.GATE_MIN_GAP, "gap not too small")
		_check(gap_h <= FlightSimScript.GATE_MAX_GAP, "gap not too large")
		_check(gap_y - gap_h * 0.5 >= 0.0, "gap top is on-screen")
		_check(gap_y + gap_h * 0.5 <= FlightSimScript.VIEW_H, "gap bottom is on-screen")


func _test_gate_spacing() -> void:
	_begin("gate spacing")
	var sim := _new_sim()
	for i in range(240):
		sim.step_fixed(false, false)
		if not sim.alive:
			break
	if sim.gates.size() >= 2:
		var first := float(sim.gates[0]["x"])
		var second := float(sim.gates[1]["x"])
		_almost_eq(absf(second - first), FlightSimScript.GATE_SPACING, 0.01, "gates keep world spacing")
	else:
		_check(sim.gates.size() < 2, "spacing check needs at least two gates")


func _test_thread_scores_more() -> void:
	_begin("thread scores more")
	var sim := _new_sim()
	var gate := sim.gates[0]
	sim.bird_y = float(gate["gap_y"])
	sim.bird_vy = 0.0
	_place_gate_left(sim)
	sim.step_fixed(false, false)
	_eq(sim.threads, 1, "thread counted")
	_check(sim.score > 10, "thread bonus applied")
	_check(bool(gate["threaded"]), "gate records thread")


func _test_graze_scores() -> void:
	_begin("graze scores")
	var sim := _new_sim()
	var gate := sim.gates[0]
	sim.bird_y = float(gate["gap_y"]) + float(gate["gap_h"]) * 0.5 - 4.0
	sim.bird_vy = 0.0
	_place_gate_left(sim)
	sim.step_fixed(false, false)
	_eq(sim.grazes, 1, "graze counted")
	_eq(sim.threads, 0, "graze is not a thread")
	_check(sim.score >= 15, "graze bonus applied")


func _test_normal_pass_scores() -> void:
	_begin("normal pass scores")
	var sim := _new_sim()
	var gate := sim.gates[0]
	sim.bird_y = float(gate["gap_y"]) + float(gate["gap_h"]) * 0.25
	sim.bird_vy = 0.0
	_place_gate_left(sim)
	sim.step_fixed(false, false)
	_eq(sim.gates_passed, 1, "gate passed")
	_eq(sim.threads, 0, "normal pass is not a thread")
	_eq(sim.grazes, 0, "normal pass is not a graze")
	_check(sim.score >= 10, "gate score applied")


func _test_gate_collision_crashes() -> void:
	_begin("gate collision crashes")
	var sim := _new_sim()
	var gate := sim.gates[0]
	gate["x"] = FlightSimScript.CRANE_X - 20.0
	sim.bird_y = float(gate["gap_y"]) + float(gate["gap_h"]) * 0.5 + 50.0
	sim.bird_vy = 0.0
	sim.step_fixed(false, false)
	_check(sim.crashed, "crashed on gate")
	_eq(sim.crash_reason, "gate", "crash reason is gate")


func _test_bottom_crash() -> void:
	_begin("bottom crash")
	var sim := _new_sim()
	sim.bird_y = FlightSimScript.VIEW_H - 10.0
	sim.step_fixed(false, false)
	_check(sim.crashed, "crashed at the bottom")
	_eq(sim.crash_reason, "ground", "crash reason is ground")


func _test_top_clamp_is_safe() -> void:
	_begin("top clamp is safe")
	var sim := _new_sim()
	sim.bird_y = 5.0
	sim.bird_vy = -500.0
	sim.step_fixed(false, false)
	_check(sim.alive, "top does not kill")
	_check(sim.bird_y >= FlightSimScript.CRANE_HALF_H, "crane is pushed below the top")
	_check(sim.bird_vy >= 0.0, "upward velocity is cancelled at the top")


func _test_restart_resets() -> void:
	_begin("restart resets")
	var sim := _new_sim()
	sim.score = 99
	sim.threads = 3
	sim._crash("test")
	sim.restart()
	_eq(sim.score, 0, "score resets")
	_eq(sim.threads, 0, "threads reset")
	_check(sim.alive, "alive after restart")
	_check(not sim.crashed, "not crashed after restart")
	_almost_eq(sim.bird_y, FlightSimScript.VIEW_H * 0.5, 0.01, "position resets")


func _test_pause_stops_time() -> void:
	_begin("pause stops time")
	var sim := _new_sim()
	sim.set_paused(true)
	var before := sim.time_s
	sim.step_fixed(true, true)
	_almost_eq(sim.time_s, before, 0.0001, "paused simulation does not advance")
	_check(sim.alive, "paused crane stays alive")


func _test_finish_state() -> void:
	_begin("finish state")
	var sim := _new_sim()
	sim.finish_run()
	_check(sim.finished, "finished flag")
	_check(not sim.alive, "not alive after finish")
	_check(not sim.crashed, "finish is not a crash")


func _test_combo_multiplier() -> void:
	_begin("combo multiplier")
	var sim := _new_sim()
	var gate := sim.gates[0]
	for i in range(2):
		sim.bird_y = float(gate["gap_y"])
		sim.bird_vy = 0.0
		gate["passed"] = false
		_place_gate_left(sim)
		sim.step_fixed(false, false)
	_eq(sim.threads, 2, "two threads")
	_eq(sim.combo, 2, "combo is two")
	_eq(sim.multiplier, 2, "multiplier reaches x2")


func _test_combo_expires() -> void:
	_begin("combo expires")
	var sim := _new_sim()
	var gate := sim.gates[0]
	sim.bird_y = float(gate["gap_y"])
	_place_gate_left(sim)
	sim.step_fixed(false, false)
	_eq(sim.combo, 1, "combo starts")
	sim.combo_timer = 0.01
	sim.step_fixed(false, false)
	sim.step_fixed(false, false)
	_eq(sim.combo, 0, "combo expires")
	_eq(sim.multiplier, 1, "multiplier resets")


func _test_rng_is_reproducible() -> void:
	_begin("RNG is reproducible")
	var a := RngScript.new(1234)
	var b := RngScript.new(1234)
	var same := true
	for i in range(32):
		if a.next_u31() != b.next_u31():
			same = false
			break
	_check(same, "same seed gives same sequence")


func _test_rng_differs_by_seed() -> void:
	_begin("RNG differs by seed")
	var a := RngScript.new(1)
	var b := RngScript.new(2)
	var differs := false
	for i in range(8):
		if a.next_u31() != b.next_u31():
			differs = true
			break
	_check(differs, "different seeds diverge")


func _test_seeded_gates_are_reproducible() -> void:
	_begin("seeded gates are reproducible")
	var a := _new_sim(777)
	var b := _new_sim(777)
	for i in range(60):
		a.step_fixed(false, false)
		b.step_fixed(false, false)
	var same := a.gates.size() == b.gates.size()
	if same:
		for i in range(a.gates.size()):
			if absf(float(a.gates[i]["x"]) - float(b.gates[i]["x"])) > 0.001:
				same = false
			if absf(float(a.gates[i]["gap_y"]) - float(b.gates[i]["gap_y"])) > 0.001:
				same = false
	_check(same, "same seed produces the same gates")


func _test_no_nan_under_fuzz() -> void:
	_begin("no NaN under fuzz")
	var sim := _new_sim(99)
	var clean := true
	for i in range(3000):
		if not sim.alive:
			sim.restart()
		sim.step_fixed(i % 40 == 0, i % 80 < 40)
		if not is_finite(sim.bird_y) or not is_finite(sim.bird_vy) or not is_finite(sim.time_s):
			clean = false
			break
	_check(clean, "state stays finite for 3000 steps")


func _test_gate_count_is_bounded() -> void:
	_begin("gate count is bounded")
	var sim := _new_sim(5)
	for i in range(3000):
		if not sim.alive:
			sim.restart()
		sim.step_fixed(i % 32 == 0, i % 64 < 32)
	_check(sim.gates.size() <= 12, "gate list stays bounded")


func _test_distance_score() -> void:
	_begin("distance score")
	var sim := _new_sim()
	sim.distance_m = 9.9
	sim._distance_score_carry = 9.9
	sim.step_fixed(false, false)
	_check(sim.score >= 1, "distance awards score at 10 m")


func _test_gate_gap_shrinks() -> void:
	_begin("gate gap shrinks with progress")
	var sim := _new_sim()
	var initial := float(sim.gates[0]["gap_h"])
	sim.gates_passed = 20
	sim._spawn_gate(3000.0)
	var later := float(sim.gates[-1]["gap_h"])
	_check(later < initial, "later gates are tighter")
	_check(later >= FlightSimScript.GATE_MIN_GAP, "gap never drops below the floor")


func _test_snapshot_shape() -> void:
	_begin("snapshot shape")
	var sim := _new_sim()
	var snap := sim.get_snapshot()
	for key in ["bird_y", "bird_vy", "alive", "score", "gates", "combo", "multiplier", "gliding"]:
		_check(snap.has(key), "snapshot has %s" % key)
	_check(snap["gates"] is Array, "snapshot gates is an array")


func _test_crane_rect() -> void:
	_begin("crane rect")
	var sim := _new_sim()
	var rect := sim.get_crane_rect()
	_almost_eq(rect.position.x, FlightSimScript.CRANE_X - FlightSimScript.CRANE_HALF_W, 0.001, "crane rect x")
	_almost_eq(rect.position.y, sim.bird_y - FlightSimScript.CRANE_HALF_H, 0.001, "crane rect y")
	_almost_eq(rect.size.x, FlightSimScript.CRANE_HALF_W * 2.0, 0.001, "crane rect width")
	_almost_eq(rect.size.y, FlightSimScript.CRANE_HALF_H * 2.0, 0.001, "crane rect height")


func _test_gate_rects_tile_the_screen() -> void:
	_begin("gate rects tile the screen")
	var sim := _new_sim()
	var gate := sim.gates[0]
	var top := sim.get_gate_top_rect(gate)
	var gap := sim.get_gate_gap_rect(gate)
	var bottom := sim.get_gate_bottom_rect(gate)
	_almost_eq(top.size.y + gap.size.y + bottom.size.y, FlightSimScript.VIEW_H, 0.01, "rects cover the height")
	_almost_eq(gap.position.y, top.size.y, 0.01, "gap starts where the top ends")
	_almost_eq(bottom.position.y, gap.position.y + gap.size.y, 0.01, "bottom starts where the gap ends")


func _test_thread_and_graze_zones() -> void:
	_begin("thread and graze zones")
	var sim := _new_sim()
	var gate := sim.gates[0]
	sim.bird_y = float(gate["gap_y"])
	_check(sim.is_in_thread_zone(gate), "center is a thread")
	_check(not sim.is_grazing(gate), "center is not a graze")
	sim.bird_y = float(gate["gap_y"]) + float(gate["gap_h"]) * 0.5 - 4.0
	_check(not sim.is_in_thread_zone(gate), "edge is not a thread")
	_check(sim.is_grazing(gate), "edge is a graze")


func _test_flap_count() -> void:
	_begin("flap count")
	var sim := _new_sim()
	sim.step_fixed(true, false)
	sim.step_fixed(true, false)
	_eq(sim.flaps, 2, "two flaps counted")


func _test_gate_kind_is_seeded() -> void:
	_begin("gate kind is seeded")
	var a := _new_sim(31415)
	var b := _new_sim(31415)
	_eq(str(a.gates[0]["kind"]), str(b.gates[0]["kind"]), "same seed gives same first gate kind")
	_check(str(a.gates[0]["kind"]) in ["arch", "bell", "windmill"], "gate kind is known")
