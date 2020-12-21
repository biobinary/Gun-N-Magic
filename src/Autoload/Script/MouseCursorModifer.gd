extends Node2D

var CURSOR_TEXTURE : Array = [ preload("res://assets/Crosshairs/crosshair173.png") ]
enum CURSOR { BATTLE_CROSSHAIR }

var current_crosshair : int
var hotspot_offset : Vector2

# Sprite and Animation Variable
onready var cursor_sprite : Sprite = get_node( "CursorLayer/Cursor" )
onready var cursor_animation : AnimationPlayer = get_node( "CursorLayer/Cursor/CursorAnimation" )
# ------------------------------------------------------------------------------------------------

func _ready() -> void:
	Input.set_mouse_mode( Input.MOUSE_MODE_HIDDEN ) # Make the cursor hidden
	DO_SET_NEW_CUSTOM_CURSOR( 
		CURSOR.BATTLE_CROSSHAIR,
		Vector2.ZERO, 
		Vector2.ONE * 0.25, 
		true )

func _input(event: InputEvent) -> void:
	
	if event is InputEventMouseMotion:
		# Update the cursor sprite position
		# cursor sprite position = mouse position + some offset
		cursor_sprite.position = event.position + hotspot_offset

func DO_SET_NEW_CUSTOM_CURSOR(new_cursor : int, 
		offset : Vector2 = Vector2.ZERO, 
		texture_scale : Vector2 = Vector2.ONE,
		add_rotation_animation : bool = false) -> void:
			
	current_crosshair = new_cursor
	hotspot_offset = offset
	
	cursor_sprite.texture = CURSOR_TEXTURE[ current_crosshair ]
	cursor_sprite.scale = texture_scale
	
	if add_rotation_animation:
		cursor_animation.play("Default")
		
	else:
		cursor_animation.stop()
		cursor_sprite.rotation = 0.0
