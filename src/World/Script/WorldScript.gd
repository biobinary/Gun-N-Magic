extends Node2D

export(String) var next_objective : String
export(String, FILE, "*.tscn") var next_scene : String

onready var transition_animation_player : AnimationPlayer = get_node( "TransitionLayer/AnimationPlayer" )
onready var next_player_scene : String = next_scene

func _ready() -> void:
	
	GlobalGameDataScript.connect( "all_enemies_vanished", self, "_do_level_completed", [false] )
	GlobalGameDataScript.connect( "player_died", self, "_do_level_completed", [true] )
	
	transition_animation_player.connect( "animation_finished", self, "_do_animation_finished" )
	transition_animation_player.play( "Open" )

func _do_level_completed( is_player_died : bool ) -> void:
	
	if is_player_died:
		
		GameMusic.current_music_type = GameMusic.MUSIC_TYPE.MAIN_MENU
		GameMusic.do_set_music_volume_db( -6 )
		
		next_player_scene = "res://src/UI/DeadMenu.tscn"
	
	get_tree().paused = true
	transition_animation_player.play( "Close" )

func _do_animation_finished(anim_name : String) -> void:
	if anim_name == "Open":
		if get_tree().paused:
			get_tree().paused = false
	else:
		GlobalGameDataScript.current_objective = next_objective
		GlobalGameDataScript.do_change_scene( next_player_scene )
