shader_type spatial;

uniform float outline_width : hint_range(0.0, 1.0) = 0.001; // Thickness of the outline
uniform vec4 outline_color : source_color = vec4(1.0, 1.0, 1.0, 0.3); // Color of the outline
uniform float time_factor : hint_range(0.0, 1.0) = 0.0; // Time-based effect for animation (optional)

void fragment() {
    vec3 norm = normalize(NORMAL);
    float outline = 1.0 - max(0.0, dot(norm, vec3(0.0, 0.0, 1.0))); // Detect edges

    // The outline color is applied based on the normal
    if (outline > outline_width) {
		 // Generate a rainbow color effect by using sine functions based on the angle
        float hue = mod((atan(norm.x, norm.z) / (2.0 * 3.14159)) + time_factor, 1.0); // Wrap around the angle
        vec3 rainbow_color = vec3(abs(sin(hue * 6.28318)), abs(sin(hue * 6.28318 + 2.0944)), abs(sin(hue * 6.28318 + 4.1888))); // RGB rainbow cycle

        ALBEDO = rainbow_color;
        ALPHA = outline_color.a;
		EMISSION = rainbow_color * outline_color.a; // For a glowing effect
    } else {
        discard; // Make the inside of the cylinder invisible
    }
}
