shader_type canvas_item;

uniform float vignette_strength = 1.5;
uniform float vignette_softness = 0.5;
uniform vec4 overlay_color : source_color = vec4(0.1, 1.0, 1.0, 0.4); // NVG tint

void fragment() {
	vec2 uv = SCREEN_UV * 2.0 - 1.0;
	float dist = length(uv);
	float vignette = smoothstep(vignette_strength, vignette_strength + vignette_softness, dist);

	COLOR = overlay_color + vec4(vec3(0.0, 0.0, 0.0), vignette);
}