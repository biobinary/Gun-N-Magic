extends KinematicBody2D

export(float) var speed : float = 80.0 # 20.0
export(float) var acceleration : float = 5.0 # 2.0
export(float) var deceleration : float = 3.0 # 1.0
export(float) var wizzard_fire_rate : float = 0.5

enum WIZARD_STATE { IDLE, WALKING, ATTACK }
var _current_wizzard_state : int = WIZARD_STATE.IDLE
var _last_state : int = _current_wizzard_state

onready var main_scene_treee : SceneTree = get_tree()

# Sprite Container
onready var wizzard_sprite_container : Node2D = get_node( "SpriteContainer" )
onready var dust_particles : Particles2D = get_node( "SpriteContainer/DustParticles" )
onready var magic_spawner_location : Position2D = get_node( "SpriteContainer/MagicWand/MagicSpawnLocation" )
# ------------------------------------------------------------------------------------------------------------

onready var wizzard_healthbar_node : Node2D = get_node( "SpriteContainer/HealthBarNode" )

# Animation Property
onready var hurt_animation : AnimationPlayer = get_node( "HurtBox/HurtAnimation" )
onready var animation_tree : AnimationTree = get_node( "AnimationTree" )
onready var state_machine : AnimationNodeStateMachinePlayback = animation_tree["parameters/playback"]
# ------------------------------------------------------------------------------------------------------

onready var player_outside_area_timer : Timer = get_node( "TimerNode/PlayerOutsideAreaTimer" )

onready var magic_sound_effect : AudioStreamPlayer2D = get_node( "SpriteContainer/MagicWand/SpellSoundEffect" )

# Wizzard Projectile
var _wizzard_projectile_prefab : PackedScene = preload( "res://src/WizzardWeapons/WizzardProjectile.tscn" )
# ----------------------------------------------------------------------------------------------------------

var _is_can_shoot : bool = true
var _is_player_inside_the_area : bool = false
var _is_attacking : bool = false

var _target_path : PoolVector2Array = PoolVector2Array()
var _direction : Array = [ -1, 1 ]

var _max_walk_distance : float = 4.0
var _wizzard_linear_velocity : Vector2 = Vector2.ZERO
var _player_body_node : KinematicBody2D = null

var _max_collision_time : float = 3.0
var _current_collision_time : float = 0.0
var _escape_direction : Vector2
var _init_escape : bool = false

func _ready() -> void:
	
	randomize()
	
	GlobalGameDataScript.current_enemy_amount += 1
	GlobalGameDataScript.connect( "wizard_receive_new_path", self, "_do_update_new_path" )
	
	global_position = global_position.snapped( Vector2.ONE * 16 )
	global_position -= Vector2.RIGHT * 8

func _physics_process(delta: float) -> void:
	
	if _current_wizzard_state == WIZARD_STATE.WALKING:
		
		if state_machine.get_current_node() != "Walking":
			state_machine.travel(  "Walking" )
		if not dust_particles.emitting:
			dust_particles.emitting = true
		
		_do_make_the_wizzard_walk( delta )

	elif _current_wizzard_state == WIZARD_STATE.IDLE:
		
		if state_machine.get_current_node() != "Idle":
			state_machine.travel( "Idle" )
		if dust_particles.emitting:
			dust_particles.emitting = false

	if _player_body_node:
		
		var calculated_player_position : Vector2 = _player_body_node.global_position + Vector2(0, 8)
		var calculated_wizzard_position : Vector2 = global_position + Vector2(0, 8)
		
		_do_set_wizzard_facing( calculated_player_position )
		if _is_can_shoot and _is_player_inside_the_area:

			_is_can_shoot = false
			_do_shoot_projectile_toward_player( calculated_player_position )

			yield( main_scene_treee.create_timer( wizzard_fire_rate ), "timeout" )
			_is_can_shoot = true
		
		if not _is_player_inside_the_area and _target_path.size() == 0:
			
			var new_offset : Vector2 = Vector2(
				40 * _direction[ randi() % 2 ],
				40 * _direction[ randi() % 2 ]
			)
			var next_move : Vector2 = calculated_player_position + new_offset
			GlobalGameDataScript.emit_signal( "wizard_request_new_path", name, calculated_wizzard_position, next_move )

func _do_make_the_wizzard_walk( delta : float ) -> void:
	
	if _target_path.size() != 0:

		var current_distance : float = ( global_position + Vector2(0, 8) ).distance_to( _target_path[0] )

		# If the wizzard reach the current point
		# Delete the current point and set the position to the current point
		if current_distance < _max_walk_distance:
			_target_path.remove( 0 )
		
		else:
			
			if _init_escape:
				_init_escape = false
				move_and_collide( 80.0 * _escape_direction * delta )
				return
			
			# Move to the next given point
			var direction : Vector2 = ( global_position + Vector2(0, 8) ).direction_to( _target_path[0] )
			_do_calculate_wizzard_velocity( direction )
			
			var collision : KinematicCollision2D = move_and_collide( _wizzard_linear_velocity * delta )
			if collision:
				
				# If _current_collision_time more than _max_collision_time
				# Then the wizzard it's 100% stuck 
				if _current_collision_time > _max_collision_time:
					_escape_direction= _do_calculate_escape_direction( collision.normal, collision.position )
					_init_escape = true
					_current_collision_time = 0.0
					
				_current_collision_time += delta
	
			_do_set_wizzard_facing( _target_path[0] )
	
	# Smoothly stop the wizzard
	elif _target_path.size() == 0 and _wizzard_linear_velocity.length() != 0:
		_do_calculate_wizzard_velocity( Vector2.ZERO, deceleration )
		move_and_collide( _wizzard_linear_velocity * delta )
	
	else:
		_current_wizzard_state = WIZARD_STATE.IDLE

func _do_calculate_wizzard_velocity( new_direction : Vector2, acc : float = acceleration ) -> void:
	_wizzard_linear_velocity = _wizzard_linear_velocity.move_toward( new_direction * speed, acc )

func _do_calculate_escape_direction( normal : Vector2, collision_position : Vector2 ) -> Vector2:
	
	var direction : Vector2
	var current_wizzard_position : Vector2 = global_position + Vector2(0, 8)
	
	if normal.y == 0.0:
		direction = Vector2( 0.0, -1 if current_wizzard_position.y - collision_position.y < 0.0 else 1 )

	elif normal.x == 0.0:
		direction = Vector2( -1 if current_wizzard_position.x - collision_position.x < 0.0 else 1, 0.0 )
	
	return direction

func _do_update_new_path(wizard_name : String, new_path : PoolVector2Array) -> void:
	
	if name == wizard_name:
		_target_path = new_path
		_current_wizzard_state = WIZARD_STATE.WALKING

func _do_set_wizzard_facing( target  : Vector2 ) -> void:
	var facing : float = target.x - ( global_position + Vector2(0, 8) ).x
	wizzard_sprite_container.scale.x = -1.0 if facing < 0.0 else 1.0

func _do_shoot_projectile_toward_player( target : Vector2 ) -> void:
	
	magic_sound_effect.play()
	var new_direction : Vector2 = magic_spawner_location.global_position.direction_to( target )
	
	var bullet : Node2D = _wizzard_projectile_prefab.instance()
	bullet.DO_CONFIGURE_BULLET( new_direction )
	if new_direction.x < 0.0:
		bullet.scale.y = -1
	
	main_scene_treee.root.call_deferred( "add_child", bullet )
	bullet.global_position = magic_spawner_location.global_position

func _on_WizzardDetectArea_body_entered(body: Node) -> void:
	
	player_outside_area_timer.stop()
	_is_player_inside_the_area = true
	
	if _player_body_node == body:
		return
	
	_player_body_node = body
	_is_attacking = true

func _on_WizzardDetectArea_body_exited(body: Node) -> void:
	_is_player_inside_the_area = false
	player_outside_area_timer.start()

func _on_PlayerOutsideAreaTimer_timeout() -> void:
	
	player_outside_area_timer.stop()
	
	_current_wizzard_state = WIZARD_STATE.IDLE
	_target_path = PoolVector2Array()
	
	_is_attacking = false
	_player_body_node = null

func _on_WizzardDetectArea_area_entered(area: Area2D) -> void:
	if area.is_in_group( "Projectile" ) and _is_attacking and not _is_player_inside_the_area:
		var bullet_owner : int = area.get_parent().bullet_owner
		if bullet_owner == 0:
			_do_shoot_projectile_toward_player( area.global_position )

func _on_HurtBox_area_entered(area: Area2D) -> void:
	
	if not _player_body_node:
		
		player_outside_area_timer.start()
		
		var player_node_path : NodePath = GlobalGameDataScript.player_node_path
		_player_body_node = get_node( player_node_path )
		
		_is_attacking = true
	
	hurt_animation.play( "Hurt" )
	wizzard_healthbar_node._do_decrease_healthbar()

func init_death() -> void:
	set_physics_process( false )
	state_machine.travel( "Dead" )

func _do_decrease_enemy() -> void:
	GlobalGameDataScript.current_enemy_amount -= 1
	queue_free()














