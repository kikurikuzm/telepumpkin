shader_type canvas_item;

uniform float horizontal = 10.0;
uniform float vertical = 10.0;

float rand(vec2 co){
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

void vertex(){
	VERTEX += vec2(cos(TIME)*horizontal, sin(TIME)*vertical);
}

void fragment(){
	
}