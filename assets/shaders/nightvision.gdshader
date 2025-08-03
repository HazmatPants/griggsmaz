shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture;

uniform float intensity = 0.05;
uniform float spark_density = 0.001;

void fragment() {
    vec4 col = texture(SCREEN_TEXTURE, SCREEN_UV);
    float gray = dot(col.rgb, vec3(0.3, 0.59, 0.11)); // grayscale base

    // Green tint
    vec3 greenish = vec3(0.0, 1.0, 1.0) * gray;



    // Base noise (flicker)
    float base_noise = fract(sin(dot(SCREEN_UV * TIME, vec2(12.9898, 78.233))) * 43758.5453);
    greenish += base_noise * intensity;



    // Scattered sparkles
    float sparkle_noise = fract(sin(dot(SCREEN_UV * 100.0 + TIME, vec2(91.345, 12.234))) * 54321.123);
    if (sparkle_noise < spark_density) {
        greenish = vec3(1.0); // bright white sparkle
    }

	float vignette = smoothstep(0.6, 1.0, distance(SCREEN_UV, vec2(0.5)));
	greenish *= 1.0 - vignette * 0.4; // dims edges by 40%

    COLOR = vec4(greenish, col.a);
}