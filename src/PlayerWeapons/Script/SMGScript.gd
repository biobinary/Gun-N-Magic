extends PlayerWeaponScript

export(float, 0.0, 1.0) var ACCURACY : float = 1.0

func _do_spawn_bullet() -> void:
	
	var direction : Vector2 = muzzle_tip.global_transform.x
	direction += Vector2(
		rand_range( ACCURACY - 1.0, 1.0 - ACCURACY),
		rand_range( ACCURACY - 1.0, 1.0 - ACCURACY )
	)
	
	var bullet : Node2D = _bullet_prefab.instance()
	bullet.DO_CONFIGURE_BULLET( direction.normalized() )
	
	main_scene_tree.root.add_child(bullet)
	bullet.global_position = muzzle_tip.global_position
