shader_type spatial;
render_mode unshaded;

uniform vec4 default_line_color: source_color = vec4( 1.0, 1.0, 1.0, 1.0 );
uniform vec4 default_background_color: source_color = vec4( 0.0, 0.0, 0.0, 1.0 );
uniform vec4 outside_color: source_color = vec4( 0.0, 0.0, 0.0, 1.0 );
uniform float line_size = 0.01; // : hint_range(0.1, 50, 0.1) = 0.1;
uniform int max_hex_distance = 3;
uniform float hex_outer_radius = 0.08;
uniform int colored_hex_count = 0;
uniform ivec2 colored_hex_indexes[1000];
uniform int colored_hex_color_index[1000];
uniform vec4 hex_line_colors[10]: source_color;
uniform vec4 hex_background_colors[10]: source_color;

int axial_distance_from_origin(ivec2 axial) {
    return (abs(axial.x)
          + abs(-axial.x - axial.y)
          + abs(axial.y)) / 2;
}

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

// pointy_hex_to_pixel
vec2 axial_to_uv(ivec2 axial) {
	float x = hex_outer_radius * (sqrt(3.0) * float(axial.x) + sqrt(3.0)/2.0 * float(axial.y));
	float y = hex_outer_radius * (3.0 / 2.0 * float(axial.y));
    return vec2(x, y);
}

// 0 at center, < 1 inside, 1 at edge, > 1 outside
float hexDist(vec2 p) {
    p = abs(p);
    return max(dot(p, vec2(0.5, sqrt(3.0)/2.0)), p.x) - 1.0;
}

// ------------------------------------------------------
// Neighbor offsets for "pointy-top" axial hex
// (q, r) -> 6 neighbors
// ------------------------------------------------------
const ivec2 AXIAL_NEIGHBORS[6] = ivec2[](
    ivec2( 0,  1),
    ivec2( 1,  0),
    ivec2( 1, -1),
    ivec2( 0, -1),
    ivec2(-1,  0),
    ivec2(-1,  1)
);

// ------------------------------------------------------
// Edge normals for a unit "pointy" hex in local space.
// Each edge i is the line dot(p, EDGES[i]) = 1.0
// ------------------------------------------------------
const vec2 EDGE_NORMALS[6] = vec2[](
    vec2(  1.0 / sqrt(3.0),  1.0 ), // NE - Edge through corners (0,1) and (√3/2, 0.5)
    vec2(  2.0 / sqrt(3.0),  0.0 ), // E  - Edge through corners (√3/2, 0.5) and (√3/2, -0.5)
    vec2(  1.0 / sqrt(3.0), -1.0 ), // SE - Edge through corners (√3/2, -0.5) and (0, -1)
    vec2( -1.0 / sqrt(3.0), -1.0 ), // SW - Edge through corners (0, -1) and (-√3/2, -0.5)
    vec2( -2.0 / sqrt(3.0),  0.0 ), // W  - Edge through corners (-√3/2, -0.5) and (-√3/2, 0.5)
    vec2( -1.0 / sqrt(3.0),  1.0 )  // NW - Edge through corners (-√3/2, 0.5) and (0, 1)
);

// Distance to edge i in local hex coords:
//  edgeDist = dot( pos, EDGE_NORMALS[i] ) - 1.0
float edge_dist(vec2 pos, int edge_index) {
    return dot(pos, EDGE_NORMALS[edge_index]) - 1.0;
}

void fragment( )
{

	vec2 uv = UV - vec2(0.5, 0.5); 	// uv = [-0.5, +0.5]
	//uv *= 2.0; 	// uv = [-1.0, +1.0]

    ivec2 current_axial = uv_to_axial(uv);
	int hex_distance = axial_distance_from_origin(current_axial);

    // Decide the "fill" color:
    //  - If inside max distance, use background_color
    //  - else use outside_color
    bool is_inside = (hex_distance <= max_hex_distance);
    bool is_outer_ring = (hex_distance == (max_hex_distance + 1));
    bool is_too_far = (hex_distance > (max_hex_distance + 1));

	vec4 line_color = default_line_color;
	vec4 background_color = default_background_color;

	if (hex_distance > (max_hex_distance + 1)) {
		// outside
		ALBEDO = outside_color.rgb;
		ALPHA = outside_color.a;
	} else {

		bool current_hex_is_in = true;

	    if (hex_distance <= max_hex_distance) {

			// inside

			for (int i = 0; i < colored_hex_count; i++) {
				if(current_axial == colored_hex_indexes[i]) {
					int color_index = colored_hex_color_index[i];
					line_color = hex_line_colors[color_index];
					background_color = hex_background_colors[color_index];
					break;
				}
			}

	    } else {

			// outer ring
	        background_color = outside_color;
	        line_color       = outside_color;

			current_hex_is_in = false;

		}

	    vec2 current_center = axial_to_uv(current_axial);
	    vec2 offset_uv = (uv - current_center) / hex_outer_radius;

	    float px_size          = length(fwidth(UV)) * 5.0;
	    float scaled_line_size = line_size + (line_size * px_size);
	    float half_line        = 0.5 * scaled_line_size;
	    float fade_start       = half_line;
	    float fade_end         = half_line + px_size;

	    float line_alpha = 0.0;
	    for (int i = 0; i < 6; i++) {

	        bool neighbor_hex_is_in = false;
			if (!current_hex_is_in) {
	            ivec2 neighbor_axial = current_axial + AXIAL_NEIGHBORS[i];
	            int neighbor_dist = axial_distance_from_origin(neighbor_axial);
				if (neighbor_dist == max_hex_distance) {
					line_color = default_line_color;
					neighbor_hex_is_in = true;
				}
			}

	        if (current_hex_is_in || neighbor_hex_is_in) {
	            float d_edge = edge_dist(offset_uv, i);
	            float edge_fade = 1.0 - smoothstep(fade_start, fade_end, abs(d_edge));
	            line_alpha = max(line_alpha, edge_fade);
	        }
	    }

	    vec4 final_color = mix(background_color, line_color, line_alpha);

	    ALBEDO = final_color.rgb;
	    ALPHA  = final_color.a;
	}
}
