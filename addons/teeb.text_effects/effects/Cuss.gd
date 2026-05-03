@tool
extends RichTextEffect

#Syntax: [cuss][/cuss]
var bbcode: String = "cuss"

var VOWELS: PackedInt32Array = [
	ord("a"), ord("e"), ord("i"), ord("o"), ord("u"),
	ord("A"), ord("E"), ord("I"), ord("O"), ord("U")
	]

var CHARS: PackedInt32Array = [ord("&"), ord("$"), ord("!"), ord("@"), ord("*"), ord("#"), ord("%")]

var SPACE: int = ord(" ")

func _process_custom_fx(char_fx: CharFXTransform) -> bool:
	#var character: int = ord(char(char_fx.glyph_index))
	#print(char_fx.range)
	
	if char_fx.relative_index != 0 and not char_fx.glyph_index == SPACE:
		var t: int = char_fx.elapsed_time + char_fx.glyph_index * 10.2 + char_fx.relative_index * 2
		t *= 4.3
		if char_fx.glyph_index in VOWELS or sin(t) > 0.0:
			char_fx.glyph_index = CHARS[t % CHARS.size()]
	
	return true
