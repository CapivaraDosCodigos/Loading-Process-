@tool
extends RichTextEffect

# Syntax: [l33t][/l33t]
var bbcode = "l33t"


const leet: Dictionary[int, int] = {
	ord("L"): ord("1"),
	ord("l"): ord("1"),
	ord("I"): ord("1"),
	ord("i"): ord("1"),
	ord("E"): ord("3"),
	ord("e"): ord("3"),
	ord("T"): ord("7"),
	ord("t"): ord("7"),
	ord("S"): ord("5"),
	ord("s"): ord("5"),
	ord("A"): ord("4"),
	ord("a"): ord("4"),
	ord("O"): ord("0"),
	ord("o"): ord("0"),
}

func _process_custom_fx(char_fx: CharFXTransform) -> bool:
	#var character: int = ord(char(char_fx.glyph_index))
	
	if char_fx.glyph_flags in leet:
		char_fx.glyph_index = leet[char_fx.glyph_index]
	return true
