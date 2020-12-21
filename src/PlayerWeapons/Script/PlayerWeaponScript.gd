extends Sprite
class_name PlayerWeaponScript

export(float) var FIRE_RATE : float = 0.25
export(int) var MAGAZINE_SIZE : int = 32
export(float) var RELOAD_TIME : float = 0.3
export(float) var WEAPON_ROTATE_SPEED : float = 12.5

export(NodePath) var GUN_SOUND : NodePath
onready var gun_sound_effect : AudioStreamPlayer2D = get_node( GUN_SOUND )

export(NodePath) var RELOAD_SOUND : NodePath
onready var gun_reload_sound : AudioStreamPlayer2D = get_node( RELOAD_SOUND )

onready var muzzle_tip : Position2D = get_node( "MuzzleTip" )
onready var PLAYER_NODE : KinematicBody2D = get_node( "../../../" )
onready var control_node : Control = get_node( "../../../PlayerUserInterface/MainControl" )
onready var main_scene_tree : SceneTree = get_tree()

# Timer Node
onready var reload_timer : Timer = get_node( "WeaponTimerNode/ReloadTimer" )
# --------------------------------------------------------------------------

onready var _current_ammo : int = MAGAZINE_SIZE

var _last_direction : int
var _is_can_fire : bool = true
var _is_reloading : bool = false

var is_ready : bool = true

# DIs is bullet prefab
# In nutshell its just store the bullet scene in the _bullet_prefab variable
var _bullet_prefab : PackedScene = preload("res://src/PlayerWeapons/Bullet/Bullet.tscn")

func _ready() -> void:
	
	# Stop da process if there's no player node
	if not PLAYER_NODE:
		set_process( false )
		
	reload_timer.wait_time = RELOAD_TIME
	reload_timer.connect( "timeout", self, "_do_reload_timer_timeout" )

func _process(delta: float) -> void:
	
	if not _is_reloading:
		control_node.do_update_ammo_status( str(_current_ammo) + " / " + str(MAGAZINE_SIZE))
	else:
		control_node.do_update_ammo_status( "reloading" )
	
	_do_update_facing_direction( delta )

	# Make Da GuN go BrrrRrrRRrrr
	if Input.is_action_pressed( "Shoot" ) and _is_can_fire and is_ready:
		
		if _current_ammo > 0 and not _is_reloading:
			GlobalGameDataScript.emit_signal( "shake_camera", 1, 1.25, 0.25 )
			gun_sound_effect.play()
			_do_fire_gun()

		elif not _is_reloading:
			_do_reload_gun()

	# Reload Da Gun
	if Input.is_action_just_pressed( "Reload" ) and _current_ammo != MAGAZINE_SIZE and not _is_reloading and is_ready:
		_do_reload_gun()

func _do_update_facing_direction(delta : float) -> void:
	
	# Rotate The Weapon With Lerp Angle
	rotation = lerp_angle(
		rotation,
		global_position.angle_to_point( get_global_mouse_position() ) + PI, 
		WEAPON_ROTATE_SPEED * delta
	)
	# -----------------------------------------------------------------------
	
	# Get Mouse x-axis Position Relative To Main Player Node
	var current_x_mouse_direction : float = PLAYER_NODE.get_local_mouse_position().x
	var new_scale : int = -1 if current_x_mouse_direction < 0.0 else 1
	
	# Set New y-axis Weapon Scale
	scale.y = abs( scale.y ) * new_scale

func _do_fire_gun() -> void:
	
	_is_can_fire = false
	_current_ammo -= 1 # Decrese the gun's ammo
	_do_spawn_bullet() # Spawn the gun's bullet
	
	yield( main_scene_tree.create_timer( FIRE_RATE ), "timeout" )
	_is_can_fire = true

func _do_spawn_bullet() -> void:
	
	var bullet : Node2D = _bullet_prefab.instance()
	bullet.DO_CONFIGURE_BULLET( muzzle_tip.global_transform.x )
	
	main_scene_tree.root.add_child(bullet)
	bullet.global_position = muzzle_tip.global_position

func _do_reload_gun() -> void:
	
	_is_reloading = true
	reload_timer.start()
	gun_reload_sound.play()

func _do_reload_timer_timeout() -> void:
	
	reload_timer.stop()
	
	_current_ammo = MAGAZINE_SIZE
	_is_reloading = false

	gun_reload_sound.stop()

func do_set_stats(is_active : bool) -> void:
	
	if is_active:
		set_process( true )
		show()
	
	else:
		
		if not reload_timer.is_stopped():
			_is_reloading = false
			reload_timer.stop()
			gun_reload_sound.stop()
		
		set_process( false )
		hide()



















