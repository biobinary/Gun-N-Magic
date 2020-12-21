extends Node2D

onready var animated_sprite : AnimatedSprite = get_node( "TorchAnimatedSprite" )
onready var torch_light : Light2D = get_node( "TorchLight" )

func _on_VisibilityNotifier2D_screen_entered() -> void:
	animated_sprite.play( "DefaultAnimation" )
	torch_light.enabled = true

func _on_VisibilityNotifier2D_screen_exited() -> void:
	animated_sprite.stop()
	torch_light.enabled = false
