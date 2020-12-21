extends Control

onready var mouse_hover_sound_effect : AudioStreamPlayer = get_node("SoundEffect/MouseHoverSoundEffect")
onready var mouse_click_sound_effect : AudioStreamPlayer = get_node( "SoundEffect/ClickSound" )

onready var parent_node : Node2D = get_node("../../")

func _on_Restart_pressed() -> void:
	
	mouse_click_sound_effect.play()
	yield( mouse_click_sound_effect, "finished" )
	
	parent_node._do_level_completed( false )

func _on_Exit_pressed() -> void:
	
	mouse_click_sound_effect.play()
	yield( mouse_click_sound_effect, "finished" )
	
	get_tree().quit()

func _on_Exit_mouse_entered() -> void:
	mouse_hover_sound_effect.play()

func _on_Restart_mouse_entered() -> void:
	mouse_hover_sound_effect.play()
