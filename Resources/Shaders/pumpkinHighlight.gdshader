shader_type canvas_item;

const float MULT_FACTOR = 7.0;

uniform sampler2D noise : repeat_enable;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform float distortion_strength = 0.006;
uniform vec2 scroll = vec2(0.05, 0.05);

void fragment() {
	vec4 noise_col = texture(noise, UV + scroll * TIME);
	vec4 pumpkin = texture(TEXTURE, UV + distortion_strength * noise_col.rr);
	
	COLOR = pumpkin + (vec4(-0.2, -0.15, 0.0, pumpkin.a) * distortion_strength * vec4(MULT_FACTOR, MULT_FACTOR, MULT_FACTOR, MULT_FACTOR));
}
