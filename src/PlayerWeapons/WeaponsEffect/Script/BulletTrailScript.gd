extends Line2D

export(int) var MAX_POINTS : int = 20
onready var parent_node : Node2D = get_parent()

func _ready() -> void:
	set_as_toplevel( true )

func _physics_process(delta: float) -> void:
	
	add_point( parent_node.global_position )
	if get_point_count() > MAX_POINTS:
		remove_point( 0 )
