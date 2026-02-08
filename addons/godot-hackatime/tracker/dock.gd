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
@onready var lang_entry_scene    := %LanguageEntryInstance

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

func _on_goal_parameter_changed(_to:String):
	
	Tracker.goal_hours = float(goal_hours_edit.text.replace("h", ""))
	Tracker.goal_date  = Time.get_unix_time_from_datetime_string(goal_date_edit.text)

func _update_contents():
	
	project_name_lab.text = Tracker.project_name
	streak_lab.text = str(int(Tracker.online_all_time["streak"]))
	
	today_lab.text    = unix_to_hms(Tracker.online_time["total_seconds"])
	all_time_lab.text = unix_to_hms(Tracker.online_all_time["total_seconds"])
	
	out_of_date = false
	
	print("UPDATE")
	
	print(Tracker.online_time["total_seconds"], " -> ", unix_to_hms(Tracker.online_time["total_seconds"]))
	pass

# Turns a count in seconds into one in hours, minutes, seconds
func unix_to_hms(time:float) -> String:
	
	var hours   = 0
	var minutes = 0
	var seconds = 0
	
	while floor(seconds / 60) > 0:
		minutes += 1
		seconds -= 60
	
	while floor(minutes / 60) > 0:
		hours += 1
		minutes -= 60
	
	var response:String
	if hours > 0:   response += " %sh" % hours
	if minutes > 0: response += " %sm" % minutes
	if seconds > 0: response += " %ss" % seconds
	
	return response


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and out_of_date: _update_contents()
