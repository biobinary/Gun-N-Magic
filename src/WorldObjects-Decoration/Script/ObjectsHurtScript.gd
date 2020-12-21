extends DestroyableWorldObjects

onready var parent_node : Node2D = get_parent()
onready var animation_player : AnimationPlayer = parent_node.get_node( "StaticBody2D/AnimationPlayer" )

func _do_init_object_hurt_effect() -> void:
	animation_player.play( "Hit" )

func _do_destroy_object() -> void:
	if animation_player.has_animation( "Destroyed" ):
		animation_player.play( "Destroyed" )
	else:
		parent_node.queue_free()
