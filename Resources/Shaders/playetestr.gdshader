shader_type canvas_item;

void fragment() {
	float movedUVy = UV.y + sin(TIME * 10.0) * 0.1;
	float movedUVx = UV.x;
	
	vec2 movedUV = vec2(movedUVx, movedUVy);
	
	COLOR = texture(TEXTURE, movedUV);
}
