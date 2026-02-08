@tool
extends Control
## The actual dock node. Displays info from tracker.gd.

var Tracker:EditorPlugin

var out_of_date := true

# Left Side (Project)
@onready var project_name_lab    := %ProjectName
@onready var streak_lab          := %Streak
@onready var today_lab           := %Today
@onready var all_time_lab        := %AllTime
@onready var pie_chart           := %PieChart
@onready var language_box        := %LanguageBox
@onready var lang_entry_scene    := preload("res://addons/godot-hackatime/tracker/language_entry.tscn")

# Right Side (Goal)
@onready var goal_hours_edit     := %GoalHours
@onready var goal_date_edit      := %GoalDate
@onready var goal_today_bar      := %GoalTodayBar
@onready var goal_today_lab      := %GoalTodayLab
@onready var goal_overall_bar    := %GoalOverallBar
@onready var goal_overall_lab    := %GoalOverallLab
@onready var daily_average       := %DailyAverage
@onready var goal_time_remaining := %GoalTimeRemaining

func _ready() -> void:
	# Wire up the signals.
	goal_date_edit .text_changed.connect(_on_goal_parameter_changed)
	goal_hours_edit.text_changed.connect(_on_goal_parameter_changed)

func _on_entry_color_changed(_to:Color): pie_chart._update(language_box.get_children())

func _on_goal_parameter_changed(_to:String):
	
	Tracker.goal_hours = float(goal_hours_edit.text.replace("h", ""))
	Tracker.goal_date  = Time.get_unix_time_from_datetime_string(goal_date_edit.text)
	
	_update_contents()

func _update_contents():
	
	# Left side (Project)
	project_name_lab.text = Tracker.project_name
	streak_lab.text = str(int(Tracker.online_all_time["streak"])) + "d Streak" if Tracker.online_all_time["streak"] > 0 else ""
	
	today_lab.text    = unix_to_hms(Tracker.total_time())
	all_time_lab.text = unix_to_hms(Tracker.today_time())
	
	# Update the pie chart / language entries.
	
	var entries:Array[Node] = language_box.get_children()
	var langs:Array = Tracker.online_all_time["languages"]
	
	while len(entries) > len(langs):
		var cut:Node = entries.pop_front()
		cut.queue_free()
	
	for i in range(len(langs)):
		if len(entries) > i:
			entries[i]._update(langs[i]["name"], langs[i]["percent"], langs[i]["text"])
		else:
			var new = lang_entry_scene.instantiate()
			
			language_box.add_child(new)
			
			new.color.color_changed.connect(_on_entry_color_changed)
			
			
			new._update(langs[i]["name"], langs[i]["percent"], langs[i]["text"])
	
	pie_chart._update(entries)
	
	# Right side (Goal)
	goal_time_remaining.text = unix_to_readable(Tracker.goal_date - Time.get_unix_time_from_system())
	
	# All units in hours.
	
	# Time Overall
	var t1 = unix_to_hours(Tracker.total_time())
	# Goal Overall
	var g1 = Tracker.goal_hours
	
	var p = min(24,unix_to_hours(Tracker.goal_date - Time.get_unix_time_from_system())) / unix_to_hours(Tracker.goal_date - Time.get_unix_time_from_system())
	
	# Time Today
	var t2 = unix_to_hours(Tracker.today_time())
	# Goal Today
	var g2 = floor(p * g1 * 100) / 100
	
	goal_overall_bar.max_value = g1
	goal_overall_bar.value = t1
	
	goal_overall_lab.text = "Time Overall / Goal Overall (%sh / %sh) %s" % [t1, g1, unix_to_hours(Tracker.goal_date - Time.get_unix_time_from_system())]
	
	goal_today_bar.max_value = g2
	goal_today_bar.value = t2
	
	goal_today_lab.text = "Time Overall / Goal Overall (%sh / %sh)" % [t2, g2]
	
	# Note that the dock is up to date now.
	
	out_of_date = false

# Turns a count in seconds into one in hours, minutes, seconds
func unix_to_hms(seconds:float) -> String:
	
	var hours   = 0
	var minutes = 0
	
	while floor(seconds / 60) > 0:
		minutes += 1
		seconds -= 60
	
	while floor(minutes / 60) > 0:
		hours += 1
		minutes -= 60
	
	var response:String
	if hours > 0:   response += " %sh" % hours
	if minutes > 0: response += " %sm" % minutes
	if seconds > 0: response += " %ss" % int(seconds)
	
	return response

# Turns a count in seconds into one in a readable format.
func unix_to_readable(time:float) -> String:
	var dict := Time.get_datetime_dict_from_unix_time(time)
	
	dict["year"] -= 1970
	dict["month"] -= 1
	dict["day"] -= 1
	
	var response:String
	
	var suffixes := {
		"year": "y", "month": "m", "day": "d", "hour": "h", "minute": "m", "second": "s"
	}
	
	for unit in suffixes.keys():
		if dict[unit] > 0: response += str(dict[unit]) + suffixes[unit] + " "
	
	return response

func unix_to_hours(seconds:float) -> float: return floor(seconds / (60 * 60) * 100) / 100

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and out_of_date: _update_contents()
