shader_type canvas_item;

void fragment() {
	vec4 tex_color = texture(TEXTURE, UV);
	float gray = dot(tex_color.rgb, vec3(0.299, 0.587, 0.114));
	gray = 1.0 - gray; // inverte o tom de cinza
	float final_alpha = tex_color.a * COLOR.a;
	COLOR = vec4(vec3(gray), final_alpha);
	}
