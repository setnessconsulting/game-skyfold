extends Node

## Minimal boot scene. The router will grow into the title/campaign flow in
## Gate 2; for now the grey-box is the only destination.


func _ready() -> void:
	call_deferred("_enter_flight")


func _enter_flight() -> void:
	var error := get_tree().change_scene_to_file("res://scenes/game/flight.tscn")
	if error != OK:
		push_error("Could not load the flight scene: %s" % error)
