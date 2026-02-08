@tool
extends Control

var langs:Dictionary[Color, float]

func _draw() -> void:
	var current_angle = 0
	
	print(langs)
	
	for lang in langs.keys():
		draw_circle_arc(size / 2, size.x / 2, current_angle, current_angle + (360 * langs[lang] / 100), lang, langs[lang] / 2)
		current_angle += (360 * langs[lang] / 100)


func draw_circle_arc(center:Vector2, radius:float, angle_from:float, angle_to:float, color:Color, nb_points:int):
	var points_arc = PackedVector2Array()
	points_arc.push_back(center)
	var colors = PackedColorArray([color])
	
	for i in range(nb_points + 1):
		var angle_point = deg_to_rad(angle_from + i * (angle_to - angle_from) / nb_points - 90)
		points_arc.push_back(center + Vector2(cos(angle_point), sin(angle_point)) * radius)
	draw_polygon(points_arc, colors)

func _update(with:Array = []):
	
	print("W:", with)
	
	langs.clear()
	
	for entry in with:
		langs[entry.color.color] = entry.percent
	
	queue_redraw()
