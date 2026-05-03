shader_type canvas_item;

uniform float intensity : hint_range(0.0, 20.0) = 4.0;
uniform float speed : hint_range(0.0, 50.0) = 20.0;

float random(vec2 uv){
	return fract(
		sin(dot(uv, vec2(12.9898, 78.233))) * 43758.5453
	);
}

void vertex() {
	float t = floor(TIME * speed);
	
	float offset_x = (random(vec2(t, 0.0)) - 0.5) * intensity;
	float offset_y = (random(vec2(0.0, t)) - 0.5) * intensity;
	
	VERTEX.xy += vec2(offset_x, offset_y);
}