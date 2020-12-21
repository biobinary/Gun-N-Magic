extends Node2D

enum OWNER { PLAYER, ENEMY }
export(OWNER) var bullet_owner : int = OWNER.PLAYER

# Bullet Speed and Velocity variable
export(float) var BULLET_SPEED : float = 120.0
var _bullet_vel : Vector2
# --------------------------------------------

export(float) var BULLET_DAMAGE : float = 20.0

# Bullet AnimationPlayer
onready var animation_player : AnimationPlayer = get_node( "BulletAnimation" )
# -----------------------------------------------------------------------------

func _ready() -> void:
	GlobalGameDataScript.connect( "scene_changed", self, "queue_free" )

func DO_CONFIGURE_BULLET( new_direction : Vector2, speed : float = BULLET_SPEED ) -> void:
	
	if not new_direction.is_normalized():
		# Normalized the direction
		new_direction = new_direction.normalized()
	
	_bullet_vel = new_direction * speed # Set the Bullet velocity
	rotation = _bullet_vel.angle() # Set the rotation according to the given velocity

func _physics_process(delta: float) -> void:
	# Move the bullet
	translate( _bullet_vel * delta )

func _on_BulletVisibilityNotifer_screen_exited() -> void:
	queue_free()

func _on_HitBox_body_entered(body: Node) -> void:
	
	_do_check_is_opponet_hurt_box( body )
	
	if body.is_in_group( "Destroyable" ) and bullet_owner != OWNER.ENEMY:
		_do_bullet_hit_object( body )
	if body.is_in_group( "Projectile" ):
		if body.get_parent().bullet_owner != bullet_owner:
			_do_bullet_hit_object( body )

func _on_HitBox_area_entered(area: Area2D) -> void:
	
	_do_check_is_opponet_hurt_box( area )
	
	if area.is_in_group( "Destroyable" ) and bullet_owner != OWNER.ENEMY:
		_do_bullet_hit_object( area )
	if area.is_in_group( "Projectile" ):
		if area.get_parent().bullet_owner != bullet_owner:
			_do_bullet_hit_object( area )

func _do_bullet_hit_object(object_node : Node2D) -> void:
	
	_bullet_vel = Vector2.ZERO
	animation_player.play( "Destroyed" )
	
	if object_node is DestroyableWorldObjects:
		object_node.do_hurt_object( BULLET_DAMAGE )

func _do_check_is_opponet_hurt_box( node : Node2D ) -> void:
	
	if bullet_owner == OWNER.PLAYER:
		if node.is_in_group( "EnemyHurtBox" ):
			_do_bullet_hit_object( node )
	else:
		if node.is_in_group( "PlayerHurtBox" ):
			_do_bullet_hit_object( node )




