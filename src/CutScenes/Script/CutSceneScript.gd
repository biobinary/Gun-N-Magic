extends Node2D

export(String) var next_objective : String = ""
export(String, FILE, "*.tscn") var next_scene : String
export(Dictionary) var dialog_dict : Dictionary = {
	0 : [ 
			{ 
			"actor" : "Player", 
			"dialog" : "Ah yes, here we go again, another game jam in the worse year ever. [enter] ",
			"color" : "22ffea"
			},
			{ 
			"actor" : "Player", 
			"dialog" : "This time i joined the Game Off 2020 with the theme 'MoonShot'. [enter] ",
			"color" : "22ffea"
			},
			{ 
			"actor" : "Player", 
			"dialog" : "Yes of course, a very cheesy theme. [enter] ",
			"color" : "22ffea"
			},
			{ 
			"actor" : "Player", 
			"dialog" : "Now everyone is going to make a very boring asteroid shooting game. [enter] ",
			"color" : "22ffea"
			} 
		]
}

onready var main_animation_player : AnimationPlayer = get_node( "AnimationNode/MainAnimation" )
onready var dialog_popup : Popup = get_node( "DialogLayer/DialogPopup" )
onready var actor_label : Label = get_node( "DialogLayer/DialogPopup/ColorRect/MarginContainer/VBoxContainer/ActorName" )
onready var dialog_label : Label = get_node( "DialogLayer/DialogPopup/ColorRect/MarginContainer/VBoxContainer/Dialog" )
onready var dialog_tween : Tween = get_node( "AnimationNode/DialogTween" )
onready var actor_dialog_sound : AudioStreamPlayer = get_node("DialogLayer/ActorDialogSound")

var _is_on_dialog : bool = false
var _dialog_dictionary_index : int
var _current_dialog_index : int = 0

func _input(event: InputEvent) -> void:
	if event.is_action_pressed( "ContinueDialog" ) and _is_on_dialog:
		_current_dialog_index = _current_dialog_index + 1
		_do_set_next_dialog( _current_dialog_index )

func _do_show_dialog(dialog_dictionary_index : int) -> void:
	
	main_animation_player.stop( false )
	_is_on_dialog = true
	_dialog_dictionary_index = dialog_dictionary_index
	
	dialog_popup.show()
	_do_set_next_dialog( _current_dialog_index )

func _do_set_next_dialog(dialog_index : int) -> void:
	
	if dialog_index == dialog_dict[ _dialog_dictionary_index ].size():
		
		_current_dialog_index = 0
		_is_on_dialog = false
		
		dialog_popup.hide()
		dialog_label.text = ""
		
		main_animation_player.play( "DefaultMainAnimation" )
		
	else:
		actor_label.add_color_override("font_color", Color(dialog_dict[_dialog_dictionary_index][_current_dialog_index]["color"]))
		actor_label.text = dialog_dict[_dialog_dictionary_index][_current_dialog_index]["actor"]
		
		dialog_label.percent_visible = 0
		dialog_label.text = dialog_dict[_dialog_dictionary_index][_current_dialog_index]["dialog"]
		
		_do_animate_dialog()

func _do_animate_dialog() -> void:
	
	if dialog_dict[_dialog_dictionary_index][_current_dialog_index]["actor"].to_lower() == "player":
		actor_dialog_sound.pitch_scale = 1.0
	else:
		actor_dialog_sound.pitch_scale = 0.9
		
	actor_dialog_sound.play()
	
	dialog_tween.interpolate_property(
		dialog_label, "percent_visible", 
		0.0, 1.0, 
		dialog_label.text.length() / 60.0, 
		Tween.TRANS_SINE, Tween.EASE_IN_OUT
	)
	
	dialog_tween.start()

func _cutscene_is_over() -> void:
	GlobalGameDataScript.current_objective = next_objective
	GlobalGameDataScript.do_change_scene( next_scene )
