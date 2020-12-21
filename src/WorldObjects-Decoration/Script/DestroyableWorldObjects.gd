extends Area2D
class_name DestroyableWorldObjects

export(float) var OBJECT_HEALTH : float = 50.0
onready var _current_health : float = OBJECT_HEALTH

func do_hurt_object( damage_taken : float ) -> void:
	
	_current_health -= damage_taken
	
	if _current_health <= 0:
		_do_destroy_object()
	else:
		_do_init_object_hurt_effect()

func _do_init_object_hurt_effect() -> void:
	pass

func _do_destroy_object() -> void:
	queue_free()
