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

float hexDist1(vec2 p) {
    p = abs(p);
    return max(dot(p, vec2(0.5, sqrt(3.0)/2.0)), p.x) - 1.0;
}

float hexDist2(vec2 p) {
    const vec2 s = vec2(1.0, sqrt(3.0));
    p = abs(p);
    return max(p.x * 2.0, dot(p, s));
}

float sdHexagon( vec2 p, float s, float r ) 
{
    const vec3 k = vec3(-0.866025404,0.5,0.577350269);
    p = abs(p);
    p -= 2.0*min(dot(k.xy,p),0.0)*k.xy;
    p -= vec2(clamp(p.x, -k.z*s, k.z*s), s);
    return length(p)*sign(p.y) - r;
}

float hexDist(vec2 p) {
	return hexDist1(p);
	//return (hexDist2(p) / 2.0) - 1.0;
}

void fragment( )
{

	// uv [-0.5, 0.5]
	vec2 uv = UV - vec2(0.5, 0.5);
	// uv [-1.0, 1.0]
	uv *= 2.0;

    ivec2 current_index = uv_to_axial(uv);
	int hex_distance = axial_distance_from_origin(current_index);

    if (hex_distance > max_hex_distance) {
        ALBEDO = outside_color.rgb;
		ALPHA = outside_color.a;
    } else {

		vec4 line_color = normal_line_color;
		vec4 background_color = normal_background_color;

		for (int i = 0; i < highlighted_index_count; i++) {
			if(current_index == highlighted_indexes[i]) {
				line_color = highlight_line_color;
				background_color = highlight_background_color;
				break;
			}
		}

		if (current_index == selected_index) {
			line_color = selected_line_color;
			background_color = selected_background_color;
		}
		
		
		// offset_uv ranges from -1 to 1 for each hex
		vec2 current_center = axial_to_uv(current_index);	
		current_center = vec2(0.0, 0.0);
		vec2 offset_uv = (uv - current_center) / hex_outer_radius;

		//offset_uv = (offset_uv * 0.5) + 0.5;
		
	    // d = -1.0 at center, 0.0 at edge, > 1.0 outside
	    float d = hexDist(offset_uv);  
	    // negative => inside the hex
	    // positive => outside
	    // zero => boundary

	    // fwidth(d) ~ approximate derivative of 'd' in screen space
	    float dist_deriv = fwidth(d);

	    // We want a line_size thickness in *pixels* around d=0.
	    // Because d changes by dist_deriv over 1 pixel of screen, 
	    // we must scale line_size by dist_deriv to get that many “SDF units”.
	    //
	    // If we want a total line thickness in pixels to be `line_size`,
	    // half should be inside, half should be outside => band of ± line_size/2.
	    // We'll do a soft transition with smoothstep to reduce aliasing.

	    float half_line = 0.5 * line_size * dist_deriv;

	    // We’ll fade from background_color to line_color whenever |d| < half_line.
	    float fade_start = half_line;        // where line begins
	    float fade_end   = half_line + dist_deriv; // small band for AA
	    float edge_alpha = 1.0 - smoothstep(fade_start, fade_end, abs(d));
	    
	    // - If abs(d) < half_line, edge_alpha ~ 1.0 => fully line_color
	    // - If abs(d) > fade_end, edge_alpha ~ 0.0 => fully background
		
		vec4 final_color = mix(background_color, line_color, edge_alpha);
	
	    ALBEDO = final_color.rgb;
	    //ALPHA  = final_color.a;

		// d -1 ... 0 ... 1
		float d2 = d;
		//ALBEDO = vec3(offset_uv.x, 0.0, 0.0);
		//ALBEDO = vec3(d2, 0.0, 0.0);
		if (d2 == 0.0) {
			ALBEDO = vec3(1.0, 0.0, 0.0);
		}
		//if (abs(d2) < 0.5) {
			//ALBEDO = vec3(1.0, 0.0, 0.0);
		//} else if (d2 < 0.0) {
			//ALBEDO = vec3(0.0, 1.0, 0.0);
		//} else if (d2 > 0.0) {
			//ALBEDO = vec3(0.0, 0.0, 1.0);			
		//}
		
		//ALBEDO = vec3(offset_uv.x, 0.0, 0.0);
		//if (offset_uv.y == 0.0) {
			//ALBEDO = vec3(1.0, 0.0, 0.0);
		//} else if (offset_uv.y < 0.0) {
			//ALBEDO = vec3(0.0, 1.0, 0.0);
		//} else if (offset_uv.y > 1.0) {
			//ALBEDO = vec3(0.0, 0.0, 1.0);			
		//}
		
		ALPHA = 1.0;
	    //vec4 c = background_color;
	    //c = mix(c, line_color, smoothstep(hex_outer_radius, 0.0, (d - line_size)));
//
		//ALBEDO = c.rgb;
		//ALPHA = c.a;
	}
	
}
