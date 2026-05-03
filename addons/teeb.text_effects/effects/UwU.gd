@tool
extends RichTextEffect


# Syntax: [uwu][/uwu]
var bbcode = "uwu"


const r: int = ord("r")
const R: int = ord("R")
const l: int = ord("l")
const L: int = ord("L")

const w: int = ord("w")
const W: int = ord("W")


func _process_custom_fx(char_fx: CharFXTransform) -> bool:
	match char_fx.glyph_index:
		r, l: char_fx.glyph_index = w
		R, L: char_fx.glyph_index = W
	return true
