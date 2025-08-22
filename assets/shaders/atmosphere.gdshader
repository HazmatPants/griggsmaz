shader_type spatial;
render_mode unshaded, cull_front, depth_draw_always;

uniform vec4 atmosphere_color : source_color = vec4(0.4, 0.6, 1.0, 1.0);
uniform float intensity : hint_range(0.0, 5.0) = 1.5;
uniform float falloff : hint_range(0.1, 10.0) = 3.0;

// Sunlight direction (normalized vector in world space, pointing FROM sun TO planet)
uniform vec3 light_direction = vec3(0.0, 1.0, 0.0);

void fragment() {
    vec3 normal = normalize(NORMAL);
    vec3 view_dir = normalize(-VIEW);

    // Rim lighting (makes atmosphere visible at edges)
    float rim = pow(1.0 - dot(normal, view_dir), falloff);

    // Sun lighting: stronger on the side facing the light
    float sun_factor = max(dot(normal, -light_direction), 0.0);

    // Combine rim + sunlight
    float glow = rim * sun_factor * intensity;

    ALBEDO = atmosphere_color.rgb;
    ALPHA = glow * atmosphere_color.a;
}
