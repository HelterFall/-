shader_type spatial;
render_mode diffuse_burley, specular_schlick_ggx;

uniform vec4 base_color : source_color = vec4(0.36, 0.39, 0.44, 1.0);
uniform float normal_strength : hint_range(0.0, 2.0) = 0.62;
uniform float roughness_variation : hint_range(0.0, 0.4) = 0.12;

float hash21(vec2 p) {
	p = fract(p * vec2(123.34, 456.21));
	p += dot(p, p + 45.32);
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

float concrete_height(vec2 uv) {
	float large_pits = noise21(uv * vec2(34.0, 27.0));
	float fine_grit = noise21(uv * vec2(240.0, 190.0));
	float pores = hash21(floor(uv * vec2(520.0, 420.0)));
	return large_pits * 0.045 + fine_grit * 0.018 + pores * 0.008;
}

void fragment() {
	float broad = noise21(UV * vec2(10.0, 8.0));
	float grain = hash21(floor(UV * vec2(310.0, 190.0)));
	float damp_streaks = smoothstep(0.40, 0.86, noise21(vec2(UV.x * 48.0, UV.y * 5.0)));
	float streak_mask = damp_streaks * (1.0 - smoothstep(0.42, 0.96, UV.y));
	float panel_joint = step(0.986, fract(UV.x * 9.0));
	float shade = 0.82 + broad * 0.22 + (grain - 0.5) * 0.12 - streak_mask * 0.12;
	vec3 concrete_color = base_color.rgb * shade;
	concrete_color = mix(concrete_color, concrete_color * 0.62, panel_joint * 0.24);
	ALBEDO = concrete_color;
	float roughness_noise = noise21(UV * vec2(60.0, 50.0));
	ROUGHNESS = clamp(0.94 - streak_mask * 0.22 + (roughness_noise - 0.5) * roughness_variation, 0.62, 1.0);
	SPECULAR = 0.22;

	vec2 texel = vec2(0.0025, 0.0025);
	float h = concrete_height(UV);
	float hx = concrete_height(UV + vec2(texel.x, 0.0));
	float hy = concrete_height(UV + vec2(0.0, texel.y));
	vec3 tangent_normal = normalize(vec3((h - hx) * normal_strength * 42.0, (h - hy) * normal_strength * 42.0, 1.0));
	NORMAL_MAP = tangent_normal * 0.5 + vec3(0.5);
	NORMAL_MAP_DEPTH = 0.55;
}
