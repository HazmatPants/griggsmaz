shader_type canvas_item;

uniform vec2 direction = vec2(0.0, 0.0); // (1,0)=horizontal, (0,1)=vertical
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture;

// Precomputed 9-tap Gaussian weights for blur_radius ≈ 4.0
const float kernel[9] = float[](0.05, 0.09, 0.12, 0.15, 0.16, 0.15, 0.12, 0.09, 0.05);

void fragment() {
	vec2 uv = SCREEN_UV;
	vec2 texel = direction / vec2(textureSize(SCREEN_TEXTURE, 0));
	vec4 color = vec4(0.0);

	for (int i = -4; i <= 4; i++) {
		color += texture(SCREEN_TEXTURE, uv + float(i) * texel) * kernel[i + 4];
	}

	COLOR = color;
}