@tool
extends RichTextEffect


# Syntax: [rain][/rain]
var bbcode = "rain"


func get_rand(char_fx: CharFXTransform) -> float:
	return fmod(get_rand_unclamped(char_fx), 1.0)


func get_rand_unclamped(char_fx: CharFXTransform) -> float:
	return char_fx.glyph_count * 33.33 + char_fx.relative_index * 4545.5454

func _process_custom_fx(char_fx: CharFXTransform) -> bool:
	var time: float = char_fx.elapsed_time
	var r: float = get_rand(char_fx)
	var t: float = fmod(r + time * .5, 1.0)
	char_fx.offset.y += t * 8.0
	char_fx.color = lerp(char_fx.color, Color.TRANSPARENT, t)
	return true
