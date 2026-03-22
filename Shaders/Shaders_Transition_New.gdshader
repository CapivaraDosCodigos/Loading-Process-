shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture;

uniform float screen_width = 1920.0;
uniform float screen_height = 1080.0;
uniform vec2 center = vec2(0.5);
uniform vec2 player = vec2(0.5);

uniform float progress : hint_range(0,1);
uniform float pixel_size = 15.0;
uniform float circle_size : hint_range(0,2) = 1.5;
uniform float curtains : hint_range(0,1) = 1.0;

// 0–4 normal | 5–9 invertido
uniform int type : hint_range(0,9) = 0;

void fragment() {
	vec4 tex_color = texture(SCREEN_TEXTURE, SCREEN_UV);

	bool visible = true;

	// 🔹 Detecta inversão
	bool invert = type >= 5;
	int base_type = type % 5;

	// =========================
	// MÁSCARA BASE
	// =========================
	if (base_type == 0) {
		float xFraction = fract(FRAGCOORD.x / pixel_size);
		float yFraction = fract(FRAGCOORD.y / pixel_size);
		
		float xDistance = abs(xFraction - 0.5);
		float yDistance = abs(yFraction - 0.5);

		if (xDistance + yDistance + UV.x + UV.y > progress * 4.0) {
			visible = false;
		}
	}
	else if (base_type == 1) {
		float ratio = screen_width / screen_height;
		if (distance(player, vec2(mix(player.x, UV.x, ratio), UV.y)) < circle_size * (1.0 - progress)) {
			visible = false;
		}
	}
	else if (base_type == 2) {
		float ratio = screen_width / screen_height;
		if (distance(center, vec2(mix(center.x, UV.x, ratio), UV.y)) < circle_size * (1.0 - progress)) {
			visible = false;
		}
	}
	else if (base_type == 3) {
		if (distance(vec2(0.5), vec2(UV.x, UV.x)) < curtains * (1.0 - progress)) {
			visible = false;
		}
	}
	else if (base_type == 4) {
		if (distance(vec2(0.5), vec2(UV.y, UV.y)) < curtains * (1.0 - progress)) {
			visible = false;
		}
	}

	// 🔥 Inversão da lógica
	if (invert) {
		visible = !visible;
	}

	// =========================
	// RESULTADO FINAL
	// =========================
	if (!visible) {
		discard;
	} else {
		float gray = dot(tex_color.rgb, vec3(0.299, 0.587, 0.114));
		gray = 1.0 - gray;

		COLOR = vec4(vec3(gray), tex_color.a);
	}
}