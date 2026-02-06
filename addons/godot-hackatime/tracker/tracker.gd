@tool
extends EditorPlugin


func _enable_plugin() -> void:
	print("ENABLED")
	# Add autoloads here.
	pass


func _disable_plugin() -> void:
	print("DISABLED")
	# Remove autoloads here.
	pass


func _enter_tree() -> void:
	# Initialization of the plugin goes here.
	pass


func _exit_tree() -> void:
	# Clean-up of the plugin goes here.
	pass
