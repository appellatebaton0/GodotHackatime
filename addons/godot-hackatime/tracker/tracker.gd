@tool
extends EditorPlugin

# Base plugin information
const BASE_PLUGIN_SCRIPT = &"res://addons/godot-hackatime/godot-hackatime.gd"
var base_plugin:EditorPlugin # The plugin that manages the heartbeats; ^location

# The values stored from the available data while online.
const STORED_KEYS = ["total_seconds", "languages", "daily_average", "streak"]

# Whether the dock is currently showing the wrong time, since it won't update the label while open.
var outdated_dock := false

# The info needed to get the time.
var project_name :StringName
var api_key      :StringName
var slack_id     :StringName

var online_time  :Dictionary # Stores the last gotten online time dict.
var offline_time :Dictionary # Stores the last gotten offline time.

func _enable_plugin() -> void:
	
	confirm_dependencies(true)
	
	print("API KEY: ", api_key, " SLACK_ID: ", slack_id)

func _disable_plugin() -> void:
	print("DISABLED")


## Every time a heartbeat is sent to Wakatime, try to update the dock.
func _on_heartbeat_sent():
	
	if confirm_dependencies(): # Ensure all the dependencies exist.
	
		# Get the start and end times needed to return the last 24h of time.
		var datetime_dict = Time.get_datetime_dict_from_system(true)
		datetime_dict["day"] = str(int(datetime_dict["day"]) - 1)
		
		var start_time = Time.get_datetime_string_from_datetime_dict(datetime_dict, false)
		var end_time = Time.get_datetime_string_from_system(true)
		
		# Curl the new time.
		var out = []
		var err := OS.execute("curl",  ["-X", "GET", "https://hackatime.hackclub.com/api/v1/users/" + slack_id + "/stats?filter_by_project=" + project_name + "&api_key=" + api_key, "-H", "accept: application/json"], out)
		
		if err: offline_update()   # If something goes wrong, assume the user is offline and use that.
		else:   online_update(out) # Otherwise, do the normal time updating.

func online_update(output): 
	
	# If the output doesn't exist, offline update instead.
	if output[0] == "":
		offline_update()
		return
	
	# Turn the output from an array with a string with the data into just the data.
	output = JSON.parse_string(output[0])["data"]
	
	# Take what's needed from the output, and store it in the online_time.
	var next_online_time:Dictionary
	
	for key in STORED_KEYS:
		next_online_time[key] = output[key]
	
	print(next_online_time)

func offline_update(): 
	print("OFFLINE HEARTBEAT")
	pass

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
func get_slack_id() -> StringName:
	if not api_key: return ""
	
	# Runs 
	# curl -H "Authorization: Bearer [key]" https://hackatime.hackclub.com/api/hackatime/v1/users/current/stats/last_7_days
	# And returns the [data][username] key from it.
	
	var out:Array
	var err := OS.execute("curl", ["-H", "Authorization: Bearer " + api_key, "https://hackatime.hackclub.com/api/hackatime/v1/users/current/stats/last_7_days"], out)
	
	if out[0] != "":
		var dict = JSON.parse_string(out[0])["data"]
		
		return dict["username"]
	
	if err:
		push_error("[Godot Hackatime]: Could not get Slack ID. Is Wakatime set up correctly?")
	
	return ""

## If any of the required data couldn't be found, try to find it again.
func confirm_dependencies(pushes_error := false) -> bool:
	
	if not project_name: project_name = ProjectSettings.get_setting("application/config/name")
	
	if not base_plugin: 
		base_plugin = get_base_plugin()
		base_plugin.heartbeat_sent.connect(_on_heartbeat_sent)
	
	if not api_key: api_key = base_plugin.get_api_key()
	
	if not slack_id: slack_id = get_slack_id()
	
	var confirmed = base_plugin and api_key and slack_id and project_name
	
	# If anything failed, and should push an error, do that.
	if not confirmed and pushes_error: push_error("[Godot Hackatime]: Could not find a dependency. Is Wakatime set up correctly? Does your project have a name?")
	
	return confirmed
