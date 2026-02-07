@tool
extends Control

func _draw() -> void:
	draw_circle_arc(size / 2, size.x / 2, 0, 90, Color.AQUA, 10)

func draw_circle_arc(center:Vector2, radius:float, angle_from:float, angle_to:float, color:Color, nb_points:int):
	var points_arc = PackedVector2Array()
	points_arc.push_back(center)
	var colors = PackedColorArray([color])
	
	for i in range(nb_points + 1):
		var angle_point = deg_to_rad(angle_from + i * (angle_to - angle_from) / nb_points - 90)
		points_arc.push_back(center + Vector2(cos(angle_point), sin(angle_point)) * radius)
	draw_polygon(points_arc, colors)

func _process(delta: float) -> void: queue_redraw()
