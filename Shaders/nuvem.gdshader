shader_type canvas_item;

uniform float speed : hint_range(0.0, 5.0) = 0.5;
uniform bool diretion_inversa = false;


void fragment() {
	vec2 uv = UV;
	
	// Move para esquerda com o tempo
	if (diretion_inversa) {
	uv.x += TIME * speed;
	}
	else {
		uv.x -= TIME * speed;
	}

	// Faz loop automático
	uv.x = fract(uv.x);
	
	COLOR = texture(TEXTURE, uv);
}