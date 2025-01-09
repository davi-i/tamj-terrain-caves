shader_type spatial;

uniform vec3 cylinder_positions[100]; // Array for up to 100 cylinders
uniform float cylinder_radius = 5;
uniform int cylinder_count = 0;       // Number of cylinders
uniform vec3 color;

varying vec3 vertex_local;

void vertex() {
	vertex_local = VERTEX;
}

void fragment() {
    vec3 world_pos = vertex_local;

	vec2 ground_pos = vec2(world_pos.x, world_pos.z);

    bool is_black = false;

    // Check for intersection with any cylinder
    for (int i = 0; i < cylinder_count; i++) {
        vec2 cylinder_pos_2d = vec2(cylinder_positions[i].x, cylinder_positions[i].z);
        float dist_to_cylinder = distance(ground_pos, cylinder_pos_2d);

        bool within_cylinder = (dist_to_cylinder <= cylinder_radius);

        if (within_cylinder) {
            is_black = true;
            break;
        }
    }

    // Apply color based on intersection
    if (is_black) {
        ALBEDO = vec3(0.0);  // Black for intersections
    } else {
        ALBEDO = color;
    }
}
