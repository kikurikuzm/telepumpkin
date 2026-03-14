shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

void fragment() {
	vec2 distortedUV = SCREEN_UV + texture(TEXTURE, UV).r * 0.02;

	vec4 reflection = texture(SCREEN_TEXTURE, distortedUV);
	
	COLOR = reflection;
}
