shader_type spatial;
render_mode unshaded;

uniform vec4 normal_line_color: source_color = vec4( 0.0, 1.0, 0.3, 1.0 );
uniform vec4 normal_background_color: source_color = vec4( 0.0, 0.0, 0.0, 1.0 );
uniform vec4 selected_line_color: source_color = vec4( 1.0, 0.0, 0.0, 1.0 );
uniform vec4 selected_background_color: source_color = vec4( 0.5, 0.0, 0.0, 1.0 );
uniform vec4 highlight_line_color: source_color = vec4( 1.0, 0.0, 0.0, 1.0 );
uniform vec4 highlight_background_color: source_color = vec4( 0.3, 0.0, 0.0, 1.0 );
uniform vec4 outside_color: source_color = vec4( 0.5, 0.0, 0.0, 1.0 );
uniform float line_size = 0.01; // : hint_range(0.1, 50, 0.1) = 0.1;
uniform int max_hex_distance = 3;
uniform float hex_outer_radius = 0.08;
uniform ivec2 selected_index = ivec2(1000);
uniform int highlighted_index_count = 3;
uniform ivec2 highlighted_indexes[1000];

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

	// uv = [-1.0, +1.0]
	vec2 uv = UV - vec2(0.5, 0.5);
	uv *= 2.0;

    ivec2 current_axial = uv_to_axial(uv);
	int hex_distance = axial_distance_from_origin(current_axial);

    if (hex_distance > max_hex_distance) {
        ALBEDO = outside_color.rgb;
		ALPHA = outside_color.a;
    } else {

		vec4 line_color = normal_line_color;
		vec4 background_color = normal_background_color;

		for (int i = 0; i < highlighted_index_count; i++) {
			if(current_axial == highlighted_indexes[i]) {
				line_color = highlight_line_color;
				background_color = highlight_background_color;
				break;
			}
		}

		if (current_axial == selected_index) {
			line_color = selected_line_color;
			background_color = selected_background_color;
		}
		
		float hex_outer_diameter = hex_outer_radius * 2.0;
		vec2 scaled_uv = (mod(uv + hex_outer_radius, hex_outer_diameter) / hex_outer_diameter);

		vec2 current_center = axial_to_uv(current_axial);
		//current_center = vec2(0.0, 0.0);
		vec2 offset_uv = (uv - current_center) / hex_outer_radius;
		//vec2 offset_uv = (uv - current_center);
		float d = hexDist(offset_uv);

		float line_size_2 = line_size;
		
		// Calculate the screen-space derivatives of the distance field
		float dist_dx = length(dFdx(d));
		float dist_dy = length(dFdy(d));
		float screen_px_distance = sqrt(dist_dx * dist_dx + dist_dy * dist_dy);

		vec2 fw = fwidth(offset_uv);
		
		//screen_px_distance = 1.0;
		
		// Convert line size from pixels to UV space distance
		float scaled_line_size = line_size_2 * screen_px_distance;
		
		//scaled_line_size = 0.3;
	    float half_line = 0.5 * scaled_line_size;

	    // We’ll fade from background_color to line_color whenever |d| < half_line.
	    float fade_start = half_line;        // where line begins
	    float fade_end   = half_line;
	    float edge_alpha = 1.0 - smoothstep(fade_start, fade_end, abs(d));
		
	    vec4 c = background_color;
		//c = mix(c, vec4(d2, 0.0, 0.0, 1.0), 0.2);
	    //c = mix(c, line_color, smoothstep(hex_outer_radius, 0.0, (d - line_size)));
		c = mix(c, line_color, edge_alpha);

		ALBEDO = c.rgb;
		ALPHA = c.a;
		
		float d2 = length(fw);
		ALBEDO = mix(ALBEDO, vec3(d2, 0.0, 0.0), 0.2);
		//ALBEDO = vec3(scaled_uv, 0.0);
		//if (d2 == 0.0) {
			//ALBEDO = vec3(1.0, 0.0, 0.0);
		//}
		//if (d2 == 0.0) {
			//ALBEDO = vec3(1.0, 0.0, 0.0);
		//} else if (d2 < 0.0) {
			//ALBEDO = vec3(0.0, 1.0, 0.0);
		//} else if (d2 > 0.0) {
			//ALBEDO = vec3(0.0, 0.0, 1.0);			
		//}		
	}

}
