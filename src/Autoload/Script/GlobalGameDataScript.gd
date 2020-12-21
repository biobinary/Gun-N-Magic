extends Node

signal shake_camera( priority, power, duration )
signal scene_changed()
signal all_enemies_vanished()
signal player_objective_changed( objective )
signal player_died()

# Pathfinding Signal
signal wizard_request_new_path( wizard_name, start_point, end_point )
signal wizard_receive_new_path( wizard_name, new_path )

# Emitted When The TileMap Change
signal wizard_pathfinding_tile_updated()
# -------------------------------------------------------------------

func _ready() -> void:
	pause_mode = Node.PAUSE_MODE_PROCESS

var player_node_path : NodePath

var current_objective : String = "" setget _do_update_player_objective
func _do_update_player_objective( new_objective : String ) -> void:
	current_objective = new_objective
	emit_signal( "player_objective_changed", current_objective)

var current_enemy_amount : int = 0 setget _do_update_enemy_amount
func _do_update_enemy_amount( new_amount : int ) -> void:
	current_enemy_amount = new_amount
	if current_enemy_amount <= 0:
		emit_signal( "all_enemies_vanished" )

func _do_reset_data() -> void:
	current_enemy_amount = 0

func do_change_scene( new_scene : String ) -> void:
	
	emit_signal( "scene_changed" )
	_do_reset_data()
	
	if not get_tree().paused:
		get_tree().paused = true
	
	get_tree().change_scene( new_scene )
