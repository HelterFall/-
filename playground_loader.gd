extends Node3D

func _ready() -> void:
	call_deferred("_build_visuals")


func _build_visuals() -> void:
	var visuals_script: Script = load("res://playground_visuals.gd")
	var visuals: RefCounted = visuals_script.new()
	visuals.call("build", get_parent())
