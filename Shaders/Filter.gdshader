shader_type canvas_item;

uniform sampler2D palette_texture : source_color, filter_nearest;
uniform int method : hint_range(0, 3) = 0;
uniform float luminance_threshold : hint_range(0.0, 1.0, 0.01) = 0.1;
uniform float hue_weight : hint_range(0.0, 5.0, 0.1) = 1.0;

const int MAX_PALETTE = 1024;

// sRGB -> linear
vec3 srgb_to_linear(vec3 c) {
	vec3 low = c / 12.92;
	vec3 high = pow((c + 0.055) / 1.055, vec3(2.4));
	return mix(low, high, step(0.04045, c));
}

// RGB -> OKLab
vec3 rgb_to_oklab(vec3 rgb) {
	vec3 lin = srgb_to_linear(rgb);
	float l = 0.4122214708 * lin.r + 0.5363325363 * lin.g + 0.0514459929 * lin.b;
	float m = 0.2119034982 * lin.r + 0.6806995451 * lin.g + 0.1073969566 * lin.b;
	float s = 0.0883024619 * lin.r + 0.2817188376 * lin.g + 0.6299787005 * lin.b;
	float l_root = pow(l, 1.0/3.0);
	float m_root = pow(m, 1.0/3.0);
	float s_root = pow(s, 1.0/3.0);
	return vec3(
		0.2104542553 * l_root + 0.7936177850 * m_root - 0.0040720468 * s_root,
		1.9779984951 * l_root - 2.4285922050 * m_root + 0.4505937099 * s_root,
		0.0259040371 * l_root + 0.7827717662 * m_root - 0.8086757660 * s_root
	);
}

// RGB -> HSV (todos componentes 0..1)
vec3 rgb_to_hsv(vec3 c) {
	vec4 K = vec4(0.0, -1.0/3.0, 2.0/3.0, -1.0);
	vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
	vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));
	float d = q.x - min(q.w, q.y);
	float e = 1.0e-10;
	return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

// Distância entre duas cores HSV
float hsv_distance(vec3 h1, vec3 h2, float hw) {
	float dh = min(abs(h1.x - h2.x), 1.0 - abs(h1.x - h2.x));
	float ds = h1.y - h2.y;
	float dv = h1.z - h2.z;
	return sqrt((hw * dh) * (hw * dh) + ds * ds + dv * dv);
}

void fragment() {
	// Cor original do pixel (textura do nó)
	vec4 tex_color = texture(TEXTURE, UV);
	vec3 rgb = tex_color.rgb;
	float alpha = tex_color.a * COLOR.a;   // respeita modulate alpha

	int palette_size = int(textureSize(palette_texture, 0).x);
	vec3 best_color = rgb;
	float best_dist = 1e10;

	if (method == 0) {
		// 1 - Distância Euclidiana (RGB)
		for (int i = 0; i < MAX_PALETTE; i++) {
			if (i >= palette_size) break;
			vec3 pal = texelFetch(palette_texture, ivec2(i, 0), 0).rgb;
			float d = length(pal - rgb);
			if (d < best_dist) {
				best_dist = d;
				best_color = pal;
			}
		}
	} else if (method == 1) {
		// 2 - Luminância + Distância
		float src_lum = 0.2126 * rgb.r + 0.7152 * rgb.g + 0.0722 * rgb.b;
		bool found = false;
		for (int i = 0; i < MAX_PALETTE; i++) {
			if (i >= palette_size) break;
			vec3 pal = texelFetch(palette_texture, ivec2(i, 0), 0).rgb;
			float pal_lum = 0.2126 * pal.r + 0.7152 * pal.g + 0.0722 * pal.b;
			if (abs(pal_lum - src_lum) <= luminance_threshold) {
				float d = length(pal - rgb);
				if (d < best_dist) {
					best_dist = d;
					best_color = pal;
					found = true;
				}
			}
		}
		// Se nenhuma cor estiver dentro do limiar, faz busca completa
		if (!found) {
			for (int i = 0; i < MAX_PALETTE; i++) {
				if (i >= palette_size) break;
				vec3 pal = texelFetch(palette_texture, ivec2(i, 0), 0).rgb;
				float d = length(pal - rgb);
				if (d < best_dist) {
					best_dist = d;
					best_color = pal;
				}
			}
		}
	} else if (method == 2) {
		// 3 - Perceptual (OKLab)
		vec3 src_lab = rgb_to_oklab(rgb);
		for (int i = 0; i < MAX_PALETTE; i++) {
			if (i >= palette_size) break;
			vec3 pal = texelFetch(palette_texture, ivec2(i, 0), 0).rgb;
			vec3 pal_lab = rgb_to_oklab(pal);
			float d = length(pal_lab - src_lab);
			if (d < best_dist) {
				best_dist = d;
				best_color = pal;
			}
		}
	} else if (method == 3) {
		// 4 - Distância HSV (com peso ajustável no matiz)
		vec3 src_hsv = rgb_to_hsv(rgb);
		for (int i = 0; i < MAX_PALETTE; i++) {
			if (i >= palette_size) break;
			vec3 pal = texelFetch(palette_texture, ivec2(i, 0), 0).rgb;
			vec3 pal_hsv = rgb_to_hsv(pal);
			float d = hsv_distance(src_hsv, pal_hsv, hue_weight);
			if (d < best_dist) {
				best_dist = d;
				best_color = pal;
			}
		}
	}

	COLOR = vec4(best_color, alpha);
}
