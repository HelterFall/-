shader_type canvas_item;
render_mode unshaded;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_linear;
uniform float vignette_strength : hint_range(0.0, 0.5) = 0.22;
uniform float grain_strength : hint_range(0.0, 0.08) = 0.018;

void fragment() {
	vec3 color = texture(screen_texture, SCREEN_UV).rgb;
	vec2 centered = SCREEN_UV - vec2(0.5);
	float vignette = smoothstep(0.24, 0.78, length(centered));
	float noise_value = fract(sin(dot(FRAGCOORD.xy + vec2(TIME * 17.0, TIME * 11.0), vec2(12.9898, 78.233))) * 43758.5453);
	color *= 1.0 - vignette * vignette_strength;
	color += (noise_value - 0.5) * grain_strength;
	COLOR = vec4(color, 1.0);
}
