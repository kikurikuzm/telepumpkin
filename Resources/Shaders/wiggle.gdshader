shader_type canvas_item;

uniform float height = 10.0;
uniform float frequency = 3.0;
uniform float speed = 2.0;

void vertex(){
	VERTEX.x += height * sin((frequency * UV.y) + (speed * TIME));
}