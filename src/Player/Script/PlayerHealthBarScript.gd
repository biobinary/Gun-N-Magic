extends Node2D

export(NodePath) var parent_node_nodepath : NodePath
onready var parent_node : Node2D = get_node( parent_node_nodepath )

export(NodePath) var health_timer_nodepath : NodePath
onready var increase_health_timer : Timer = get_node( health_timer_nodepath )

export(NodePath) var health_delay : NodePath
onready var health_delay_timer : Timer = get_node(health_delay)

var sprite_texture_region : Array = [
	Rect2( Vector2( 289, 258 ), Vector2( 13, 12 ) ),
	Rect2( Vector2( 305, 258 ), Vector2( 13, 12 ) ),
	Rect2( Vector2( 321, 258 ), Vector2( 13, 12 ) )
]
var current_healthbar_list : Array = []

func _ready() -> void:
	
	increase_health_timer.connect( "timeout", self, "_on_increase_timer_timeout" )
	health_delay_timer.connect( "timeout", self, "_on_delay_timer_timeout" )

	for _i in get_child_count():
		current_healthbar_list.append( 2 )

func _do_decrease_healthbar() -> void:
	
	health_delay_timer.start()
	increase_health_timer.stop()
	
	for idx in range( current_healthbar_list.size() - 1, -1, -1 ):
		if current_healthbar_list[ idx ] > 0:
			current_healthbar_list[ idx ] -= 1
			_do_update_healthbar_sprite( idx )
			return
			
	parent_node.init_death()

func _do_increase_healthbar() -> void:
	for idx in current_healthbar_list.size():
		if current_healthbar_list[ idx ] != 2:
			current_healthbar_list[ idx ] += 1
			_do_update_healthbar_sprite( idx )
			return
	
	increase_health_timer.stop()

func _do_update_healthbar_sprite( sprite_index : int ) -> void:
	var child_sprite : Sprite = get_child( sprite_index )
	var current_health : int = current_healthbar_list[ sprite_index ]
	child_sprite.region_rect = sprite_texture_region[ sprite_texture_region.size() - 1 - current_health ]

func _on_delay_timer_timeout() -> void:
	health_delay_timer.stop()
	increase_health_timer.start()
	
func _on_increase_timer_timeout() -> void:
	_do_increase_healthbar()

















