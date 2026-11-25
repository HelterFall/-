shader_type spatial;
render_mode diffuse_burley, specular_schlick_ggx;

uniform vec4 base_color : source_color = vec4(0.18, 0.23, 0.29, 1.0);
uniform vec4 rust_color : source_color = vec4(0.20, 0.105, 0.055, 1.0);
uniform float metalness : hint_range(0.0, 1.0) = 0.68;
uniform float rust_strength : hint_range(0.0, 1.0) = 0.24;
uniform float wear_strength : hint_range(0.0, 1.0) = 0.35;

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
	float broad = noise21(UV * vec2(5.0, 7.0));
	float grain = hash21(floor(UV * vec2(180.0, 180.0)));
	float scratch_line = step(0.994, hash21(floor(vec2(UV.x * 240.0, UV.y * 16.0))));
	float rust_mask = smoothstep(0.64, 0.92, broad + grain * 0.16) * rust_strength;
	float wear = (grain - 0.5) * wear_strength;
	vec3 metal_color = base_color.rgb * (0.92 + broad * 0.10 + wear);
	metal_color = mix(metal_color, rust_color.rgb, rust_mask);
	metal_color *= 1.0 - scratch_line * 0.08;
	ALBEDO = metal_color;
	METALLIC = metalness * (1.0 - rust_mask * 0.92);
	ROUGHNESS = clamp(0.36 + rust_mask * 0.48 + grain * 0.08, 0.28, 0.92);
	SPECULAR = 0.42;
}