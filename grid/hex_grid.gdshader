shader_type spatial;
render_mode unshaded;

uniform vec4 normal_line_color: source_color = vec4( 0.0, 1.0, 0.3, 1.0 );
uniform vec4 selected_line_color: source_color = vec4( 1.0, 0.0, 0.0, 1.0 );
uniform vec4 normal_background_color: source_color = vec4( 0.0, 0.0, 0.0, 1.0 );
uniform vec4 selected_background_color: source_color = vec4( 0.5, 0.0, 0.0, 1.0 );
uniform vec4 outside_color: source_color = vec4( 0.5, 0.0, 0.0, 1.0 );
uniform float line_size = 0.01; // : hint_range(0.1, 50, 0.1) = 0.1;
uniform int max_hex_distance = 3;
uniform float hex_outer_radius = 0.08;
uniform ivec2 selected_index = ivec2(1000);

int axial_distance_from_origin(ivec2 axial) {
    return (abs(axial.x)
          + abs(-axial.x - axial.y)
          + abs(axial.y)) / 2;
}

//int axial_distance(ivec2 a, ivec2 b) {
	//return (abs(a.x - b.x)
          //+ abs(a.x + a.y - b.x - b.y)
          //+ abs(a.y - b.y)) / 2;
//}

ivec2 axial_round(float q, float r) {
	float rounded_q = round(q);
	float rounded_r = round(r);
	q -= rounded_q;
	r -= rounded_r;
	if(abs(q) >= abs(r)) {
		return ivec2(int(rounded_q + round(q + 0.5 * r)), int(rounded_r));
	} else {
		return ivec2(int(rounded_q), int(rounded_r + round(r + 0.5 * q)));
	}
}

// pixel_to_pointy_hex
ivec2 uv_to_axial(vec2 uv) {
    float q = (sqrt(3.0)/3.0 * uv.x - 1.0/3.0 * uv.y) / hex_outer_radius;
    float r = (2.0/3.0 * uv.y) / hex_outer_radius;
    return axial_round(q, r);
}

// sqrt(3)/2
//const float hex_factor = 0.8660254037844386;

// pointy_hex_to_pixel
vec2 axial_to_uv(ivec2 axial) {
	float x = hex_outer_radius * (sqrt(3.0) * float(axial.x) + sqrt(3.0)/2.0 * float(axial.y));
	float y = hex_outer_radius * (3.0 / 2.0 * float(axial.y));
    return vec2(x, y);
}

float hexDist(vec2 p) {
    p = abs(p);
    return max(dot(p, vec2(0.5, sqrt(3.0)/2.0)), p.x) - 1.0;
}

void fragment( )
{

	//vec2 uv = (UV * 2.0) - 1.0;
	vec2 uv = UV - vec2(0.5, 0.5);

    ivec2 current_axial = uv_to_axial(uv);
	int hex_distance = axial_distance_from_origin(current_axial);

    if (hex_distance > max_hex_distance) {
        ALBEDO = outside_color.rgb;
		ALPHA = outside_color.a;
    } else {

		vec2 current_center = axial_to_uv(current_axial);
		vec2 offset_uv = (uv - current_center) / hex_outer_radius;
		float d = abs(hexDist(offset_uv));

		vec4 line_color = normal_line_color;
		vec4 background_color = normal_background_color;
		if (current_axial == selected_index) {
			line_color = selected_line_color;
			background_color = selected_background_color;
		}

	    vec4 c = background_color;
	    c = mix(c, line_color, smoothstep(hex_outer_radius, 0.0, (d - line_size)));

		ALBEDO = c.rgb;
		ALPHA = c.a;
	}

}
