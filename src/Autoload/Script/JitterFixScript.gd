extends Node

onready var viewport = get_viewport()
onready var content_width = ProjectSettings.get("display/window/size/width")
onready var content_height = ProjectSettings.get("display/window/size/height")

func _ready():
	viewport.connect("size_changed", self, "window_resize")
	window_resize()

func window_resize():
	
	var window_size = OS.get_window_size()
	var multiple = min( floor( window_size.x / content_width ) , floor( window_size.y / content_height ) )
	
	if multiple < 1:
		multiple = 1
		
	var target_size = window_size / multiple
	viewport.set_size_override(true, target_size)
