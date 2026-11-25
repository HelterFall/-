extends CanvasLayer

func _ready() -> void:
	layer = 4
	var overlay := ColorRect.new()
	overlay.name = "FilmGrainAndVignette"
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var material := ShaderMaterial.new()
	material.shader = load("res://materials/film_grain.gdshader")
	material.set_shader_parameter("vignette_strength", 0.20)
	material.set_shader_parameter("grain_strength", 0.012)
	overlay.material = material
	add_child(overlay)
