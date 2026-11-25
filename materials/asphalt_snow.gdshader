shader_type spatial;
render_mode diffuse_burley, specular_schlick_ggx;

uniform vec4 asphalt_color : source_color = vec4(0.105, 0.135, 0.18, 1.0);
uniform vec4 snow_color : source_color = vec4(0.57, 0.65, 0.76, 1.0);
uniform vec4 ice_color : source_color = vec4(0.16, 0.24, 0.36, 1.0);
uniform float snow_coverage : hint_range(0.0, 1.0) = 0.28;
uniform float wetness : hint_range(0.0, 1.0) = 0.22;
uniform float normal_strength : hint_range(0.0, 2.0) = 0.70;
varying vec3 world_position;

float hash21(vec2 p) {
	p = fract(p * vec2(127.1, 311.7));
	p += dot(p, p + 19.19);
	return fract(p.x * p.y);
}

float noise21(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	float a = hash21(i);
	float b = hash21(i + vec2(1.0, 0.0));
	float c = hash21(i + vec2(0.0, 1.0));
	float d = hash21(i + vec2(1.0, 1.0));
	return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}

float road_height(vec2 p) {
	float aggregate = noise21(p * 15.0);
	float grit = noise21(p * 90.0);
	float pebbles = hash21(floor(p * 185.0));
	return aggregate * 0.045 + grit * 0.020 + pebbles * 0.009;
}

void vertex() {
	world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	vec2 p = world_position.xz;
	float broad = noise21(p * 0.36);
	float medium = noise21(p * 3.8);
	float grit = noise21(p * 32.0);
	float flecks = hash21(floor(p * 96.0));
	float snow_mask = smoothstep(0.52 - snow_coverage * 0.28, 0.78 + snow_coverage * 0.12, broad);
	float thin_snow = smoothstep(0.60, 0.91, medium) * snow_coverage * 0.22;
	float ice_mask = smoothstep(0.62, 0.90, noise21(p * 0.72 + vec2(4.2, 8.1))) * wetness;

	vec3 asphalt = asphalt_color.rgb * (0.76 + medium * 0.18 + grit * 0.12 + (flecks - 0.5) * 0.08);
	vec3 snowy_aggregate = mix(asphalt, snow_color.rgb * (0.86 + grit * 0.13), clamp(snow_mask + thin_snow, 0.0, 0.88));
	vec3 final_color = mix(snowy_aggregate, ice_color.rgb * (0.87 + medium * 0.16), ice_mask * 0.66);
	ALBEDO = final_color;
	ROUGHNESS = mix(0.94, 0.27, ice_mask * 0.88);
	METALLIC = ice_mask * 0.08;
	SPECULAR = mix(0.18, 0.56, ice_mask);

	vec2 texel = vec2(0.018, 0.018);
	float h = road_height(p);
	float hx = road_height(p + vec2(texel.x, 0.0));
	float hy = road_height(p + vec2(0.0, texel.y));
	vec3 tangent_normal = normalize(vec3((h - hx) * normal_strength * 34.0, (h - hy) * normal_strength * 34.0, 1.0));
	NORMAL_MAP = tangent_normal * 0.5 + vec3(0.5);
	NORMAL_MAP_DEPTH = 0.48;
}
