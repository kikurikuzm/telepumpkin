shader_type canvas_item;

uniform float lod: hint_range(0.0, 5) = 0.0;
uniform float tint: hint_range(-0.4, 0.0) = -0.1;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

void fragment(){
	vec4 color = texture(SCREEN_TEXTURE, SCREEN_UV, lod);
	COLOR = color + tint;
}

//by shellrider on godotshaders.com