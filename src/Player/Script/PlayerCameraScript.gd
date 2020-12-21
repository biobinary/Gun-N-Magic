extends Camera2D

export(float) var DEAD_ZONE : float = 120.0 # The dead zone. There's no safe zone here

onready var shake_tween : Tween = get_node( "ShakeTween" )
onready var root : Viewport = get_tree().root

var _origin_position : Vector2 = position
var _origin_offset : Vector2 = offset
var _dead_zone_squared : float
var _current_priority : int = 0

var SHAKE_POWER : float = 3.0
var SHAKE_DURATION : float = 1.0

func _ready() -> void:
	GlobalGameDataScript.connect( "shake_camera", self, "DO_CONFIGURE_SHAKE_CAMERA" )
	DEAD_ZONE *= (zoom.x + zoom.y) / 2.0

func _input(event: InputEvent) -> void:
	
	if event is InputEventMouseMotion:

		var direction_to_mouse : Vector2 = _origin_position.direction_to( get_local_mouse_position() )
		var distance_to_mouse : float = _origin_position.distance_to( get_local_mouse_position() )
		var target_position : Vector2 = Vector2.ZERO

		if distance_to_mouse > DEAD_ZONE:
			target_position = direction_to_mouse * ( distance_to_mouse - DEAD_ZONE ) * 0.1

		position = target_position

func _do_shake_camera(offst_scale : float) -> void:
	
	# Shake the camera
	offset = _origin_offset + Vector2(
		rand_range(-offst_scale, offst_scale),
		rand_range(-offst_scale, offst_scale)
	)

func _do_init_camera_tween(power : float, duration : float) -> void:
	
	shake_tween.interpolate_method(
		self, "_do_shake_camera", power, 0.0, duration, 
		Tween.TRANS_SINE, Tween.EASE_IN_OUT
	)
	
	shake_tween.start()

func DO_CONFIGURE_SHAKE_CAMERA(priority : int, 
				shake_power : float = SHAKE_POWER, 
				shake_duration : float = SHAKE_DURATION) -> void:
	
	if _current_priority >= priority:
		return

	_do_init_camera_tween(shake_power, shake_duration)
