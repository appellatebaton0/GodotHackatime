@tool
extends HBoxContainer

@onready var label := %Label
@onready var color := %Color

var language:String
var percent:float

func _ready(): 
	# Base the initial color off the editor's base color.
	# Keeps the colors close to base - cool colors = cool accents, etc.
	
	var settings := EditorInterface.get_editor_settings()
	var editor_base:Color = settings.get_setting("interface/theme/base_color")
	
	editor_base.h += (randf() / 5) - 0.1
	editor_base.s = 0.7 + (randf() / 5) 
	editor_base.v = 0.7
	
	color.color = editor_base

func _update(set_lang:String, set_percent:float, set_label:String):
	language   = set_lang
	percent    = set_percent
	label.text = set_lang + " - " + set_label
