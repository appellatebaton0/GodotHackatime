extends Control
## The actual dock node. Displays info from tracker.gd.

# Left Side (Project)
@onready var project_name_lab    := %ProjectName
@onready var streak_lab          := %Streak
@onready var today_lab           := %Today
@onready var all_time_lab        := %AllTime
@onready var pie_chart           := %PieChart
@onready var language_box        := %LanguageBox

# Right Side (Goal)
@onready var goal_hours_edit     := %GoalHours
@onready var goal_date_edit      := %GoalDate
@onready var goal_today_bar      := %GoalTodayBar
@onready var goal_today_lab      := %GoalTodayLab
@onready var goal_overall_bar    := %GoalOverallBar
@onready var goal_overall_lab    := %GoalOverallLab
@onready var daily_average       := %DailyAverage
@onready var goal_time_remaining := %GoalTimeRemaining
