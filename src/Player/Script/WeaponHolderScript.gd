extends Node2D

export(float) var COOLDOWN : float = 0.75

onready var control_node : Control = get_node( "../../PlayerUserInterface/MainControl" )
onready var change_weapon_sound_effect : AudioStreamPlayer = get_node( "../../AudioNodes/GunCocking" )

var _weapon_list : Array = [  ]
var _current_weapon_index : int = 0
var _current_weapon : Sprite
var _is_can_change_weapon : bool = true

func _ready() -> void:
	
	# Get The Child Count
	var weapons_count : int = get_child_count()
	
	if not weapons_count:
		return
	
	# Setting Up The First Player's Weapon
	var first_weapon : Sprite = get_child( 0 )
	
	_weapon_list.append( first_weapon )
	_current_weapon = first_weapon
	_current_weapon.do_set_stats( true )
	
	control_node.weapon_texture.texture = _current_weapon.texture
	# ---------------------------------------------------------------
	
	# Loop through each weapon in weapon holder
	for index in range(1, weapons_count):
		
		var weapon : Sprite = get_child( index )
		weapon.do_set_stats( false )
		_weapon_list.append( weapon )

func _input(event: InputEvent) -> void:
	
	if event.is_action_pressed( "ChangeWeaponsRight" ) and _is_can_change_weapon and _weapon_list.size() > 1:
		_do_change_weapon( _current_weapon_index + 1 )
		
	elif event.is_action_pressed( "ChangeWeaponsLeft" ) and _is_can_change_weapon and _weapon_list.size() > 1:
		_do_change_weapon( _current_weapon_index - 1)

func _do_change_weapon(index : int) -> void:
	
	change_weapon_sound_effect.play()
	_is_can_change_weapon = false

	if index == _weapon_list.size():
		index = 0
	elif index < 0:
		index = _weapon_list.size() - 1

	_current_weapon.do_set_stats( false )

	_current_weapon_index = index
	_current_weapon = _weapon_list[index]
	control_node.weapon_texture.texture = _current_weapon.texture
	
	_current_weapon.rotation_degrees = -90 + (90 * (sign(position.x) * - 1))
	_current_weapon.is_ready = false
	_current_weapon.do_set_stats( true )

	yield( get_tree().create_timer( COOLDOWN ), "timeout" )
	
	_is_can_change_weapon = true
	_current_weapon.is_ready = true
