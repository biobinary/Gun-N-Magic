extends Node2D

onready var audio_stream_player : AudioStreamPlayer = get_node( "MusicPlayer" )

var music_lib : Array = [ 
	preload("res://assets/Sound/SoundTrack/bleeding_out2.ogg"),
	preload("res://assets/Sound/SoundTrack/little town - orchestral.ogg")
]
enum MUSIC_TYPE { MAIN_MENU, GAMES }

var current_music_type : int = MUSIC_TYPE.GAMES setget _do_set_music_type
func _do_set_music_type( new_music_type : int ) -> void:
	new_music_type = clamp( new_music_type, 0, MUSIC_TYPE.size() )
	current_music_type = new_music_type
	
	audio_stream_player.stream = music_lib[ new_music_type ]
	audio_stream_player.play()

func do_set_music_volume_db( new_volume_db : float ) -> void:
	audio_stream_player.volume_db = new_volume_db
