shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture;

// Cores que NÃO devem virar grayscale
uniform vec4 protected_colors[1];

// Tolerância para comparação
uniform float color_tolerance = 0.01;

bool is_protected_color(vec3 color) {
	for (int i = 0; i < protected_colors.length(); i++) {
		if (
			distance(color, protected_colors[i].rgb)
			<= color_tolerance
		) {
			return true;
		}
	}

	return false;
}

void fragment() {
	vec4 tex_color = texture(SCREEN_TEXTURE, SCREEN_UV);

	// Se for uma cor protegida, mantém original
	if (is_protected_color(tex_color.rgb)) {
		COLOR = vec4(tex_color.rgb, tex_color.a * COLOR.a);
	}

	// Grayscale normal
	else {
		float gray = dot(
			tex_color.rgb,
			vec3(0.299, 0.587, 0.114)
		);
		float final_alpha = tex_color.a * COLOR.a;
		
		COLOR = vec4(vec3(gray), final_alpha);
	}
}