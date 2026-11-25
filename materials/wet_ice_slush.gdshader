shader_type spatial;
render_mode diffuse_burley, specular_schlick_ggx;

uniform vec4 base_color : source_color = vec4(0.22, 0.31, 0.42, 1.0);
uniform vec4 fleck_color : source_color = vec4(0.11, 0.16, 0.23, 1.0);
uniform float wetness : hint_range(0.0, 1.0) = 0.78;
uniform float grain_scale : hint_range(2.0, 180.0) = 54.0;

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

void fragment() {
	float broad = noise21(UV * 7.0);
	float grit = noise21(UV * grain_scale);
	float sparkle = step(0.986, hash21(floor(UV * (grain_scale * 2.0))));
	float edge_wear = smoothstep(0.05, 0.82, broad);
	vec3 color = mix(base_color.rgb, fleck_color.rgb, grit * 0.30 + edge_wear * 0.08);
	ALBEDO = color + sparkle * wetness * 0.045;
	ROUGHNESS = mix(0.88, 0.19, wetness) + grit * 0.08;
	METALLIC = wetness * 0.09;
	SPECULAR = mix(0.18, 0.62, wetness);
}
