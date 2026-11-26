shader_type spatial;
render_mode cull_disabled, diffuse_burley, specular_schlick_ggx;

uniform vec4 tile_color_light : source_color = vec4(0.77, 0.75, 0.68, 1.0);
uniform vec4 tile_color_warm : source_color = vec4(0.66, 0.62, 0.52, 1.0);
uniform vec4 grout_color : source_color = vec4(0.19, 0.20, 0.19, 1.0);
uniform vec4 dirt_color : source_color = vec4(0.34, 0.29, 0.21, 1.0);
uniform vec2 tile_scale = vec2(20.0, 8.0);
uniform float grout_width : hint_range(0.01, 0.12) = 0.045;
uniform float grime_strength : hint_range(0.0, 1.0) = 0.62;
uniform float damage_strength : hint_range(0.0, 1.0) = 0.58;

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
	vec2 grid_uv = UV * tile_scale;
	vec2 cell = floor(grid_uv);
	vec2 local_uv = fract(grid_uv);

	float tile_random = hash21(cell);
	float mottling = noise21(grid_uv * 1.45 + cell * 0.17);
	vec3 ceramic = mix(tile_color_warm.rgb, tile_color_light.rgb, 0.24 + tile_random * 0.55);
	ceramic *= 0.86 + mottling * 0.16 + (hash21(cell + 8.7) - 0.5) * 0.10;

	// Old beige water stains, dirt gathered around the grout and subtle age variation.
	vec2 stain_center = vec2(hash21(cell + 12.4), hash21(cell + 27.1));
	float stain_shape = 1.0 - smoothstep(0.12, 0.68, distance(local_uv, stain_center));
	float stain_mask = stain_shape * hash21(cell + 44.8) * grime_strength;
	ceramic = mix(ceramic, dirt_color.rgb, stain_mask * 0.48);

	float edge = min(min(local_uv.x, 1.0 - local_uv.x), min(local_uv.y, 1.0 - local_uv.y));
	float grout_mask = 1.0 - smoothstep(grout_width, grout_width + 0.025, edge);

	// Small missing corners and chipped edges, not a perfectly uniform checkerboard.
	vec2 damaged_corner = vec2(
		step(0.5, hash21(cell + 51.2)),
		step(0.5, hash21(cell + 73.9))
	);
	float corner_distance = distance(local_uv, damaged_corner);
	float chip_selector = step(0.79, hash21(cell + 91.6));
	float chip = (1.0 - smoothstep(0.025, 0.20, corner_distance)) * chip_selector * damage_strength;
	float edge_wear = (1.0 - smoothstep(grout_width, grout_width + 0.11, edge)) *
		step(0.87, hash21(cell + 35.4)) * damage_strength;
	float damage_mask = clamp(max(chip, edge_wear), 0.0, 0.88);

	// A few thin irregular hairline cracks in individual tiles.
	vec2 crack_start = vec2(0.12 + hash21(cell + 5.3) * 0.30, 0.08 + hash21(cell + 6.7) * 0.34);
	vec2 crack_end = vec2(0.56 + hash21(cell + 7.9) * 0.37, 0.55 + hash21(cell + 9.1) * 0.38);
	vec2 crack_delta = crack_end - crack_start;
	float crack_t = clamp(dot(local_uv - crack_start, crack_delta) / max(dot(crack_delta, crack_delta), 0.001), 0.0, 1.0);
	vec2 crack_point = crack_start + crack_delta * crack_t;
	float crack_line = 1.0 - smoothstep(0.008, 0.027, distance(local_uv, crack_point));
	float crack = crack_line * step(0.925, hash21(cell + 101.4)) * damage_strength;

	vec3 tile_surface = mix(ceramic, grout_color.rgb * 0.72, max(damage_mask, crack * 0.72));
	ALBEDO = mix(tile_surface, grout_color.rgb, grout_mask);
	ROUGHNESS = mix(0.74 + mottling * 0.12, 0.94, max(grout_mask, damage_mask * 0.7));
	SPECULAR = 0.20;
}
