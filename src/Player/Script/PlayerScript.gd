# 25131a
extends KinematicBody2D

export(float) var SPEED : float = 80.0
export(float) var ACCELERATION : float = 5.0
export(float) var FRICTION : float = 3.0
export(float) var GAMEPAD_SENSITIVITY : float = 5.0

# Node that contains sprite thats why i named it sprite contaier. Make sense?
onready var sprite_container : Node2D = get_node( "SpriteContainer" )
onready var dust_particles : Particles2D = get_node( "SpriteContainer/DustParticles" )

# Node that holds weapons. so make sense right
onready var weapon_holder : Node2D = get_node( "MovingObjects/WeaponHolder" )

onready var player_healthbar : Node2D = get_node( "MovingObjects/HealthBar" )

# Player Animation PropErtY
onready var hurt_animation : AnimationPlayer = get_node( "HurtBox/HurtAnimation" )
onready var player_animation_tree : AnimationTree = get_node( "AnimationStateMachine" )
onready var state_machine : AnimationNodeStateMachinePlayback = player_animation_tree["parameters/playback"]
# -----------------------------------------------------------------------------------------------------------

onready var health_timer : Timer = get_node( "TimerNode/IncreaseHealthTimer" )
onready var health_timer_delay : Timer = get_node( "TimerNode/IncreaseHealthDelay" )

var _velocity : Vector2 = Vector2.ZERO

func _ready() -> void:
	
	# Customize The Mouse Cursor With MouseCursorModifer Autoload
	MouseCursorModifer.DO_SET_NEW_CUSTOM_CURSOR(
		MouseCursorModifer.CURSOR.BATTLE_CROSSHAIR,
		Vector2.ZERO,
		Vector2.ONE * 0.25,
		true
	)
	
	GlobalGameDataScript.player_node_path = get_path()
	
func _physics_process(delta: float) -> void:

	var mouse_x_position : float = get_local_mouse_position().x
	var new_scale : int = -1 if mouse_x_position < 0.0 else 1
	
	sprite_container.scale.x = new_scale
	weapon_holder.position.x = abs( weapon_holder.position.x ) * new_scale

	_do_get_input_movement()
	_velocity = move_and_slide( _velocity )

func _do_get_input_movement() -> void:

	# Player Input Movement
	# Make Player Go brrrrrrrr
	
	var new_dir : Vector2 = Vector2(
		Input.get_action_strength("Right") - Input.get_action_strength("Left"), 
		Input.get_action_strength("Down") - Input.get_action_strength("Up")
	).normalized()
	
	var acc : float
	var new_horizontal_dir : int = sign( new_dir.x )

	if new_dir != Vector2.ZERO:

		acc = ACCELERATION

		var is_opposite_direction : bool = false
		if new_horizontal_dir != sprite_container.scale.x and new_horizontal_dir != 0:
			is_opposite_direction = true
		
		if not is_opposite_direction and state_machine.get_current_node() != "Walking":
			state_machine.travel("Walking")

		elif is_opposite_direction and state_machine.get_current_node() != "ReverseWalking":
			state_machine.travel("ReverseWalking")

		if not dust_particles.emitting:
			dust_particles.emitting = true

	else:
		
		acc = FRICTION
		
		if state_machine.get_current_node() != "Idle":
			state_machine.travel("Idle")
		
		if dust_particles.emitting:
			dust_particles.emitting = false

	_velocity = _velocity.move_toward( new_dir * SPEED, acc )

func _on_HurtBox_area_entered(area: Area2D) -> void:
	GlobalGameDataScript.emit_signal( "shake_camera", 5, 2, 0.25 )
	hurt_animation.play( "Hurt" )
	player_healthbar._do_decrease_healthbar()

func init_death() -> void:
	
	if GlobalGameDataScript.current_enemy_amount <= 0:
		return
	
	set_physics_process( false )
	weapon_holder.set_process_input( false )
	
	state_machine.travel( "Dead" )

func _do_destroy_player() -> void:
	GlobalGameDataScript.emit_signal( "player_died" )
