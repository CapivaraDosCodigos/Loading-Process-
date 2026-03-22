shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE :
hint_screen_texture;

void fragment() {
	vec4 tex_color = texture(SCREEN_TEXTURE, SCREEN_UV);
	float gray = dot(tex_color.rgb, vec3(0.299, 0.587, 0.114));
	float final_alpha = tex_color.a * COLOR.a; // respeita o modulate.a
	COLOR = vec4(vec3(gray), final_alpha);
	}
