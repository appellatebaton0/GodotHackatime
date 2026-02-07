@tool
extends EditorPlugin

# Base plugin information
const BASE_PLUGIN_SCRIPT = &"res://addons/godot-hackatime/godot-hackatime.gd"
var base_plugin:EditorPlugin # The plugin that manages the heartbeats; ^location

# The values stored from the available data while online.
const STORED_KEYS = ["total_seconds", "languages", "daily_average", "streak"]

# The bottom dock and its scene.
@onready var DOCK_SCENE := preload("res://addons/godot-hackatime/tracker/tracker_dock.tscn")
var Dock:Panel

# Whether the dock is currently showing the wrong time, since it won't update the label while open.
var outdated_dock := false

# The info needed to get the time.
var project_name :StringName
var api_key      :StringName
var slack_id     :StringName
var wakatime_cli :StringName

var online_time     :Dictionary # Stores the last gotten online time dict. (Last 24h)
var online_all_time :Dictionary # Stores the last gotten online time dict. (All time)
var offline_time    :float      # Stores the last gotten offline time, in seconds.

## -- ENABLE / DISABLE -- ##

func _ready() -> void: 
	
	_on_heartbeat_sent()
	
	print("API KEY: ", api_key, " SLACK_ID: ", slack_id)

func _disable_plugin() -> void:
	
	if Dock: 
		remove_control_from_bottom_panel(Dock)
		Dock.queue_free()
	print("DISABLED")


## Every time a heartbeat is sent to Wakatime, try to update the dock.
func _on_heartbeat_sent(): 
	if confirm_dependencies(): # Ensure all the dependencies exist.
	
		# Get the start and end times needed to return the last 24h of time.
		var datetime_dict = Time.get_datetime_dict_from_system(true)
		datetime_dict["day"] = str(int(datetime_dict["day"]) - 1)
		
		var start_time = Time.get_datetime_string_from_datetime_dict(datetime_dict, false)
		var end_time = Time.get_datetime_string_from_system(true)
		
		var url:String = "https://hackatime.hackclub.com/api/v1/users/" + slack_id + "/stats?filter_by_project=" + project_name + "&api_key=" + api_key
		
		# Curl the new time.
		var out = []
		var err :=  OS.execute("curl",  ["-X", "GET", url + "&start_date=" + start_time + "&end_date=" + end_time, "-H", "accept: application/json"], out)
		if not err: OS.execute("curl",  ["-X", "GET", url, "-H", "accept: application/json"], out)
		
		if err: offline_update()   # If something goes wrong, assume the user is offline and use that.
		else:   online_update(out) # Otherwise, do the normal time updating.
	else: offline_update()
	
	dock_update()

## -- TIME UPDATES -- ##

func online_update(output) -> bool: 
	
	# If the output doesn't exist, offline update instead.
	if output[0] == "" or output[1] == "":
		offline_update()
		return false
	
	# Turn the output from an array with a string with the data into just the data.
	output = [JSON.parse_string(output[0])["data"], JSON.parse_string(output[1])["data"]]
	
	# Take what's needed from the output, and store it in the online_time vars.
	var next_online_time:Dictionary
	var next_online_all_time:Dictionary
	
	for key in STORED_KEYS:
		next_online_time[key]     = output[0][key]
		next_online_all_time[key] = output[1][key]
	
	online_time = next_online_time
	online_all_time = next_online_all_time
	
	return true

func offline_update() -> bool: 
	# Curl the offline time.
	var out = []
	var err := OS.execute(wakatime_cli, ["--print-offline-heartbeats", "1000"], out)
	
	if err: push_warning("[Godot Hackatime]: Could not get offline heartbeats. Is Wakatime set up correctly?")
	
	if out == [""]: return false
	
	# Parse it into a dict array.
	var arr:Array = JSON.parse_string(out[0])
	
	# Update the offline time to the distance in time from the first to last offline heartbeat. (In seconds)
	offline_time = arr.back()["time"] - arr.front()["time"]
	
	return true

## Update the actual control dock.
func dock_update():
	
	if not Dock:
		Dock = DOCK_SCENE.instantiate()
		add_control_to_bottom_panel(Dock, "_")
	
	print("updating")
	print(Dock.get_parent().visible)
	
	if not Dock.get_parent().visible:
		print("RE")
		
		
		if Dock.get_parent(): remove_control_from_bottom_panel(Dock)
		add_control_to_bottom_panel(Dock, unix_to_readable(online_all_time["total_seconds"]))
	
	
	pass


## -- MANAGING DEPENDENCIES -- ##

## Locate and return the plugin that handles the heartbeats.
func get_base_plugin() -> EditorPlugin:
	
	## Step up the tree, to find the parent of all the plugins.
	
	var parent = get_parent()
	
	## Search all the plugins within its children for the base.
	
	for plugin in parent.get_children(): if plugin is EditorPlugin:
		var script = plugin.get_script()
		
		if script is Script: if script.resource_path == BASE_PLUGIN_SCRIPT: return plugin
	
	push_error("[Godot Hackatime - Tracker]: Could not find base plugin @ ", BASE_PLUGIN_SCRIPT)
	return null

## Curl the Slack ID using the API key.
func get_slack_id(warn = false) -> StringName:
	if not api_key: return ""
	
	# Runs 
	# curl -H "Authorization: Bearer [key]" https://hackatime.hackclub.com/api/hackatime/v1/users/current/stats/last_7_days
	# And returns the [data][username] key from it.
	
	var out:Array
	var err := OS.execute("curl", ["-H", "Authorization: Bearer " + api_key, "https://hackatime.hackclub.com/api/hackatime/v1/users/current/stats/last_7_days"], out)
	
	if out[0] != "":
		var dict = JSON.parse_string(out[0])["data"]
		
		return dict["username"]
	
	if err and warn:
		push_warning("[Godot Hackatime]: Could not get Slack ID. Is Wakatime set up correctly?")
	
	return ""

## If any of the required data couldn't be found, try to find it again.
func confirm_dependencies(warn := false) -> bool:
	
	
	
	if not project_name: project_name = ProjectSettings.get_setting("application/config/name")
	
	if not base_plugin: 
		base_plugin = get_base_plugin()
	
	# Set up everything dependent on the base plugin.
	if base_plugin:
		if not base_plugin.heartbeat_sent.is_connected(_on_heartbeat_sent):
			base_plugin.heartbeat_sent.connect(_on_heartbeat_sent)
		if not wakatime_cli:
			wakatime_cli = base_plugin.wakatime_cli
		if not api_key: api_key = base_plugin.get_api_key()
	
	if not slack_id: slack_id = get_slack_id(warn)
	
	var confirmed = base_plugin and api_key and slack_id and project_name
	
	# If anything failed, and should push an error, do that.
	if not confirmed and warn: push_warning("[Godot Hackatime]: Could not find a dependency. Is Wakatime set up correctly? Does your project have a name?")
	
	return confirmed

## Turns a time amount (of seconds) into a readable string - xy, xm, xd, xh, xm, xs.
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
	
	print(dict)
	
	return response
	
	pass
