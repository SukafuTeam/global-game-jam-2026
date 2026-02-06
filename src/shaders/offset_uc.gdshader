shader_type canvas_item;

uniform float speed_multiplier = 1.0;

void fragment(){
	vec2 newuv = UV;
	newuv.x -= TIME * 4.0 * speed_multiplier;
	vec4 c = texture(TEXTURE, newuv);
	COLOR = c;
}