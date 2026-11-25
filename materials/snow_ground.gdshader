shader_type spatial;
render_mode diffuse_burley, specular_schlick_ggx;

uniform vec4 snow_color : source_color = vec4(0.53, 0.61, 0.72, 1.0);
uniform vec4 ice_color : source_color = vec4(0.18, 0.26, 0.38, 1.0);
uniform float ice_amount : hint_range(0.0, 1.0) = 0.2;
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

void vertex() {
	world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	vec2 p = world_position.xz;
	float broad = noise21(p * 0.62);
	float medium = noise21(p * 5.2);
	float grit = hash21(floor(p * 48.0));
	float icy_patch = smoothstep(0.54, 0.82, broad) * ice_amount;
	vec3 powder = snow_color.rgb * (0.84 + broad * 0.18 + medium * 0.11 + (grit - 0.5) * 0.045);
	ALBEDO = mix(powder, ice_color.rgb * (0.90 + medium * 0.15), icy_patch);
	ROUGHNESS = mix(0.96, 0.28, icy_patch);
	SPECULAR = mix(0.18, 0.52, icy_patch);
}