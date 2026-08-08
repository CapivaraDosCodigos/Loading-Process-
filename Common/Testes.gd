@tool
extends EditorScript

func _run() -> void:
	test(2, "oi", "oi3", "oi 4")

@warning_ignore("untyped_declaration")
func test(var1: int, var2: String, ...vars) -> void:
	print(var1)
	print(var2)
	print(vars.pick_random())
