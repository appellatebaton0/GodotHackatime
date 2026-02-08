@tool
extends HBoxContainer

@onready var label := %Label
@onready var color := %Color

var language:String
var percent:float

func _ready(): color.color = Color(randf(),randf(),randf())

func _update(set_lang:String, set_percent:float, set_label:String):
	language   = set_lang
	percent    = set_percent
	label.text = set_lang + " - " + set_label
