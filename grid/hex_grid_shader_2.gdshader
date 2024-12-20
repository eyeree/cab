shader_type spatial;
render_mode unshaded;

//uniform float hex_radius: hint_range(0.001, 0.5, 0.01) = 0.05;
uniform vec4 line_color: source_color = vec4( 0.0, 1.0, 0.3, 1.0 );
uniform float line_size: hint_range(0.0001, 0.5, 0.001) = 0.001;
uniform int max_hex_distance = 5; 

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
ivec2 uv_to_axial(vec2 uv, float hex_radius) {
    float q = (sqrt(3.0)/3.0 * uv.x - 1.0/3.0 * uv.y) / hex_radius;
    float r = (2.0/3.0 * uv.y) / hex_radius;
    return axial_round(q, r);
}

// sqrt(3)/2
const float hex_factor = 0.8660254037844386;

// pointy_hex_to_pixel
vec2 axial_to_uv(ivec2 axial, float hex_radius) {
	float x = hex_radius * (sqrt(3.0) * float(axial.x) + sqrt(3.0)/2.0 * float(axial.y));
	float y = hex_radius * (3.0 / 2.0 * float(axial.y));
    return vec2(x, y);
}

//float hexDist(vec2 p) {
    //p = abs(p);
    //return max(dot(p, vec2(sqrt(3.0)/2.0, 0.5)), p.y) - 1.0;
//}
	
float hexDist(vec2 p) {
    p = abs(p);
    return max(dot(p, vec2(0.5, sqrt(3.0)/2.0)), p.x) - 1.0;
}
	
float is_in_hex(vec2 local_point, float hex_radius) {
	const vec2 AXIS[3] = {
		vec2(sqrt(3)*0.5, 0.5),
		vec2(0.0, 1.0),
		vec2(-sqrt(3)*0.5, 0.5)
	};
	float max_r = 0.0;
	for (int i = 0; i < 3; i++) {
		float r = dot(local_point, AXIS[i]);
		r /= (sqrt(3)*0.5*hex_radius);
		max_r = max(max_r, abs(r));
	}
	return max_r;
}
		
void fragment( )
{
		
	//vec2 uv = (UV * 2.0) - 1.0;
	vec2 uv = UV - vec2(0.5, 0.5);
	
	float hex_radius = (1.0 / ((float(max_hex_distance*2+1)) * sqrt(3)));
	float gridline_width = max(0.01, 0.125*hex_radius);

    ivec2 current_axial = uv_to_axial(uv, hex_radius);
	int hex_distance = axial_distance_from_origin(current_axial);

    if (hex_distance > max_hex_distance) {
        discard;
    }
	
	vec2 current_center = axial_to_uv(current_axial, hex_radius);
	vec2 offset_uv = (uv - current_center) / hex_radius;
	float d = abs(hexDist(offset_uv));
	//d = is_in_hex(offset_uv * hex_radius);

    vec3 c = line_color.rgb;

	if (current_axial == ivec2(0, 0)) {
		c = vec3(1.0, 0.0, 0.0);	
	}

	if(hex_distance == 4) {
		c = vec3(0.0, 1.0, 0.0);				
	}
		
    c *= smoothstep(hex_radius, 0.0, (d - line_size));
	
	//c = vec3(offset_uv.xy, 0);
	
	//if (current_center != vec2(0.0, 0.0)) {
		//c = vec3((current_center.x / 0.5) + 1.0);
	//}
		
	//if (d > 0.1) {
		//c = vec3(1.0);
	//}
	

	
//
	//if (current_axial == ivec2(3, 0)) {
		//c = vec3(0.0, 0.0, 1.0);	
	//}
		
	//if (abs(length(uv - current_center)) < 0.005) {
		//c = vec3(0.0, 0.0, 0.0);		
	//}
	
	ALBEDO = c;
	
}

