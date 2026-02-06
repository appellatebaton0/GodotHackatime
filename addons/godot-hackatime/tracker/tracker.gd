@tool
extends EditorPlugin

# Base plugin information
const BASE_PLUGIN_SCRIPT = &"res://addons/godot-hackatime/godot-hackatime.gd"
var base_plugin:EditorPlugin # The plugin that manages the heartbeats; ^location

# Whether the dock is currently showing the wrong time, since it won't update the label while open.
var outdated_dock := false

# The info needed to get the time.
var api_key:StringName
var slack_id:StringName

func _enable_plugin() -> void:
	
	base_plugin = get_base_plugin()
	base_plugin.heartbeat_sent.connect(_on_heartbeat_sent)
	
	api_key = base_plugin.get_api_key()
	slack_id = get_slack_id()
	
	print("API KEY: ", api_key, " SLACK_ID: ", slack_id)

func _disable_plugin() -> void:
	print("DISABLED")
	# Remove autoloads here.
	pass


## Every time a heartbeat is sent to Wakatime, try to update the dock.
func _on_heartbeat_sent():
	
	# Get the start and end times needed to return the last 24h of time.
	var datetime_dict = Time.get_datetime_dict_from_system(true)
	datetime_dict["day"] = str(int(datetime_dict["day"]) - 1)
	
	var start_time = Time.get_datetime_string_from_datetime_dict(datetime_dict, false)
	var end_time = Time.get_datetime_string_from_system(true)
	
	# Curl the new time.
	var out:Array
	var err := OS.execute("curl", ["-H", "Authorization: Bearer %s" % api_key, "https://hackatime.hackclub.com/api/v1/users/%s/stats?start_date=%s&end_date=%s&features=projects&filter_by_project=%s" % [slack_id, start_time, end_time, ProjectSettings.get_setting("application/config/name")]], out)
	
	#ProjectSettings.get_setting("application/config/name")
	print(Time.get_datetime_dict_from_system(true))
	
	# https://hackatime.hackclub.com/api/v1/users/{slack_id}/stats?start_date=[start_date]&end_date=[end_date]&features=projects&filter_by_project=[project_name]&api_key=[key]
	
	print("From %s to %s" % [start_time, end_time])
	#
	print(out)

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
