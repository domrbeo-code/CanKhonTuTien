extends Node2D

@export var ring_color := Color("#b8f3c8")
@export var ring_radius := 8.0
@export var ring_alpha := 0.95

func _ready() -> void:
	z_index = 1000
	var tween := create_tween().set_parallel(true)
	tween.tween_property(self, "ring_radius", 72.0, 0.6).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "ring_alpha", 0.0, 0.6).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.chain().tween_callback(queue_free)

func _process(_delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	var ring_tint := Color(ring_color, ring_alpha)
	draw_arc(Vector2.ZERO, ring_radius, 0.0, TAU, 48, ring_tint, 2.0, true)
	draw_arc(Vector2.ZERO, ring_radius * 0.72, 0.0, TAU, 36, Color(ring_color, ring_alpha * 0.28), 1.0, true)
	draw_circle(Vector2.ZERO, 3.0, Color(1.0, 0.96, 0.72, ring_alpha))
