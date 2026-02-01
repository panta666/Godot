extends CanvasLayer

@onready var rect: ColorRect = $ColorRect
@onready var shader := rect.material

func _ready():
	if not rect:
		push_error("FadeTransition: ColorRect nicht gefunden!")
		return
	
	if rect.material == null:
		push_error("FadeTransition: ColorRect hat KEIN Material! Shader fehlt!")

func fade_out(duration := 1.0) -> void:
	if not rect or rect.material == null:
		return

	rect.visible = true
	var t = 0.0
	while t < duration:
		t += get_process_delta_time()
		var r = lerp(1.0, 0.0, t / duration)
		rect.material.set_shader_parameter("radius", r)
		await get_tree().process_frame
	
	rect.material.set_shader_parameter("radius", 0.0)

func fade_in(duration := 1.0) -> void:
	if not rect or rect.material == null:
		return

	rect.visible = true
	var t = 0.0
	while t < duration:
		t += get_process_delta_time()
		var r = lerp(0.0, 1.0, t / duration)
		rect.material.set_shader_parameter("radius", r)
		await get_tree().process_frame
	
	rect.material.set_shader_parameter("radius", 1.0)
	rect.visible = false
