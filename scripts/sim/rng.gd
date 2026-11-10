class_name SkyfoldRng
extends RefCounted

## Small deterministic 31-bit LCG. This is deliberately simple: gameplay needs
## reproducible sequences, not cryptographic randomness. The modulus keeps all
## arithmetic inside signed 64-bit integers on every platform.

const MODULUS := 0x7FFFFFFF
const MULTIPLIER := 1103515245
const INCREMENT := 12345

var state: int = 1


func _init(seed_value: int = 1) -> void:
	reseed(seed_value)


func reseed(seed_value: int) -> void:
	state = absi(seed_value) % MODULUS
	if state == 0:
		state = 1


func next_u31() -> int:
	state = int((state * MULTIPLIER + INCREMENT) & MODULUS)
	return state


func next_float() -> float:
	return float(next_u31()) / float(MODULUS)


func range_float(min_value: float, max_value: float) -> float:
	return min_value + (max_value - min_value) * next_float()


func range_int(min_value: int, max_value: int) -> int:
	if max_value <= min_value:
		return min_value
	return min_value + int(next_u31() % (max_value - min_value))
