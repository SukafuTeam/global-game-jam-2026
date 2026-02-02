shader_type canvas_item;

void fragment(){
	vec2 newuv = UV;
	newuv.x -= TIME * 4.0;
	vec4 c = texture(TEXTURE, newuv);
	COLOR = c;
}