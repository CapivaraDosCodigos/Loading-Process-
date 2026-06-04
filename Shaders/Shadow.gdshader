shader_type canvas_item;

// Cor da sombra
uniform vec4 shadow_color : source_color = vec4(0.0, 0.0, 0.0, 0.5);

// Distância da sombra para baixo
uniform float shadow_offset = 4.0;

// Transparência mínima
uniform float alpha_threshold : hint_range(0.0, 1.0, 0.01) = 0.1;

void fragment() {
	vec4 tex = texture(TEXTURE, UV);

	// Pega o pixel deslocado PARA CIMA
	// pra desenhar a sombra EMBAIXO
	vec2 shadow_uv = UV - vec2(0.0, TEXTURE_PIXEL_SIZE.y * shadow_offset);

	vec4 shadow_tex = texture(TEXTURE, shadow_uv);

	bool original_visible = tex.a > alpha_threshold;
	bool shadow_visible = shadow_tex.a > alpha_threshold;

	// Desenha sprite normal
	if (original_visible) {
		COLOR = tex;
	}
	// Desenha sombra abaixo
	else if (shadow_visible) {
		COLOR = vec4(shadow_color.rgb, shadow_color.a * shadow_tex.a);
	}
	else {
		discard;
	}
}