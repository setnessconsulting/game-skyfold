extends SceneTree

## Project-level verification run by CI:
##   godot --headless --path . --script res://tools/verify_project.gd
##
## Checks the pinned project settings, required input actions, the main scene,
## and the simulation boundary (no Input/scene-tree/global RNG in scripts/sim).

var failures: int = 0
var checks: int = 0


func _initialize() -> void:
	print("Skyfold — project verification")

	_check_setting("application/run/main_scene", "res://scenes/app/boot.tscn")
	_check_setting("application/config/name", "Skyfold")
	_check_setting("display/window/size/viewport_width", 1920)
	_check_setting("display/window/size/viewport_height", 1080)
	_check_setting("display/window/size/window_width_override", 1280)
	_check_setting("display/window/size/window_height_override", 720)
	_check_setting("physics/common/physics_ticks_per_second", 120)
	_check_setting("rendering/renderer/rendering_method", "gl_compatibility")

	var features: PackedStringArray = ProjectSettings.get_setting("application/config/features", PackedStringArray())
	_check(features.has("4.7"), "project targets Godot 4.7")
	_check(features.has("GL Compatibility"), "project declares GL Compatibility")

	for action in ["flap", "pause", "restart", "confirm", "back", "mute", "fullscreen"]:
		_check(InputMap.has_action(action), "input action exists: %s" % action)

	_check(FileAccess.file_exists("res://scenes/app/boot.tscn"), "boot scene exists")
	_check(FileAccess.file_exists("res://scenes/game/flight.tscn"), "flight scene exists")
	_check(FileAccess.file_exists("res://scripts/sim/flight_sim.gd"), "flight sim exists")
	_check(FileAccess.file_exists("res://scripts/sim/rng.gd"), "rng exists")

	_check_sim_boundary()

	print("")
	if failures == 0:
		print("PASS %d project checks" % checks)
		quit(0)
	else:
		print("FAIL %d project checks, %d failures" % [checks, failures])
		quit(1)


func _check_setting(key: String, expected: Variant) -> void:
	var actual: Variant = ProjectSettings.get_setting(key, null)
	_check(actual == expected, "%s == %s (got %s)" % [key, str(expected), str(actual)])


func _check(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		print("  FAIL %s" % message)


func _check_sim_boundary() -> void:
	var files := DirAccess.get_files_at("res://scripts/sim")
	var forbidden := [
		"get_tree(",
		"Input.",
		"AudioServer",
		"load(",
		"preload(",
		"randf(",
		"randi(",
		"randomize(",
	]
	_check(files.size() > 0, "simulation scripts found")
	for file in files:
		if not file.ends_with(".gd"):
			continue
		var text := FileAccess.get_file_as_string("res://scripts/sim/" + file)
		for token in forbidden:
			_check(not text.contains(token), "sim boundary: %s must not contain %s" % [file, token])
