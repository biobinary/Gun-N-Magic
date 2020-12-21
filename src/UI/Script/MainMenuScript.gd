extends Node2D

onready var click_sound_effect : AudioStreamPlayer = get_node("SoundNodes/ClickSoundEffect")
onready var mouse_hover_sound_effect : AudioStreamPlayer = get_node("SoundNodes/MouseHoverSound")

onready var menu_animation : AnimationPlayer = get_node( "AnimationNode/TransitionAnimation" )

func _ready() -> void:
	
	GameMusic.current_music_type = GameMusic.MUSIC_TYPE.MAIN_MENU
	GameMusic.do_set_music_volume_db( -6 )
	
	menu_animation.play( "Open" )

func _on_Play_mouse_entered() -> void:
	mouse_hover_sound_effect.play()

func _on_Quit_mouse_entered() -> void:
	mouse_hover_sound_effect.play()

func _on_Play_pressed() -> void:
	
	click_sound_effect.play()
	yield( click_sound_effect, "finished" )
	
	menu_animation.play( "Close" )

func _on_Quit_pressed() -> void:
	
	click_sound_effect.play()
	yield( click_sound_effect, "finished" )
	
	get_tree().quit()

func _on_TransitionAnimation_animation_finished(anim_name: String) -> void:
	if anim_name == "Open":
		if get_tree().paused:
			get_tree().paused = false
	else:
		
		GameMusic.current_music_type = GameMusic.MUSIC_TYPE.GAMES
		GameMusic.do_set_music_volume_db( -9.5 )
		
		GlobalGameDataScript.do_change_scene( "res://src/CutScenes/PrologueCutScene.tscn" )
