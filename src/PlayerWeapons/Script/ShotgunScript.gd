extends PlayerWeaponScript

export(float) var ANGLE_GAP : float = 20
export(int) var BULLET_AMOUNT : int = 3

func _do_spawn_bullet() -> void:
	
	if not ( BULLET_AMOUNT % 2 ):
		_do_spawn_even_bullet()
	else:
		_do_spawn_odd_bullet()

func _do_spawn_even_bullet() -> void:
	
	var normal_angle : float = muzzle_tip.global_transform.x.angle()
	var previous_angle : float = 0
	var half_gap : float = deg2rad( ANGLE_GAP ) / 2.0
	
	for idx in range( 1, BULLET_AMOUNT / 2 + 1 ):
		
		var current_angle : float = idx * half_gap + previous_angle
		
		var negative_angle : float = normal_angle - current_angle
		var positive_angle : float = normal_angle + current_angle
		
		var new_dir : Vector2 = Vector2( cos( positive_angle ), sin( positive_angle ) ).normalized()
		var new_dir_second : Vector2 = Vector2( cos( negative_angle ), sin( negative_angle ) ).normalized()
		
		var bullet_one : Node2D = _bullet_prefab.instance()
		var bullet_two : Node2D = _bullet_prefab.instance()
		
		bullet_one.DO_CONFIGURE_BULLET( new_dir )
		bullet_two.DO_CONFIGURE_BULLET( new_dir_second )

		main_scene_tree.root.add_child( bullet_one )
		main_scene_tree.root.add_child( bullet_two )
		
		bullet_one.global_position = muzzle_tip.global_position
		bullet_two.global_position = muzzle_tip.global_position
		
		previous_angle = idx * half_gap

func _do_spawn_odd_bullet() -> void:
	
	var normal_angle : float = muzzle_tip.global_transform.x.angle()
	var starting_angle : float = normal_angle + deg2rad( ANGLE_GAP ) * -floor( BULLET_AMOUNT / 2.0 )
	
	for i in range( BULLET_AMOUNT ):
		
		var new_direction : Vector2 = Vector2( cos( starting_angle ), sin( starting_angle ) ).normalized()
		
		var bullet : Node2D = _bullet_prefab.instance()
		bullet.DO_CONFIGURE_BULLET( new_direction )
	
		main_scene_tree.root.add_child(bullet)
		bullet.global_position = muzzle_tip.global_position
	
		starting_angle += deg2rad( ANGLE_GAP )
