extends TileMap

onready var tilemap_cell_center : Vector2 = cell_size / 2
onready var used_tile : PoolVector2Array = get_used_cells()

var tile_dictionary : Dictionary = {}
var astar : AStar2D = AStar2D.new()

func _ready() -> void:
	
	GlobalGameDataScript.connect( "wizard_request_new_path", self, "_do_request_new_path" )
	
	_do_add_point()
	_do_connect_point()
	
	hide()
	
func _do_add_point() -> void:
	for tile in used_tile:
		var unique_id : int = astar.get_available_point_id()
		tile_dictionary[tile] = unique_id
		astar.add_point( unique_id, tile )

func _do_connect_point() -> void:
	
	for tile in used_tile:

		for rotation_scale in 4:
			var neighbour_point : Vector2 = tile + Vector2( cos(deg2rad(90.0 * rotation_scale)), sin(deg2rad(90.0 * rotation_scale)) )
			if not tile_dictionary.has( neighbour_point ):
				continue
			astar.connect_points( tile_dictionary[tile], tile_dictionary[neighbour_point] )

func _do_request_new_path(wizard_name : String, start : Vector2 = Vector2.ZERO, end : Vector2 = Vector2.ZERO) -> void:
	
	var start_at_map : Vector2 = world_to_map(start)
	var end_at_map : Vector2 = world_to_map(end)
	
	if not tile_dictionary.has( start_at_map ) or not tile_dictionary.has( end_at_map ):
		GlobalGameDataScript.emit_signal( "wizard_receive_new_path", wizard_name, [] )
		return
		
	var get_simple_path : PoolVector2Array = astar.get_point_path( tile_dictionary[start_at_map], tile_dictionary[end_at_map] )
	var world_map : PoolVector2Array = []
	
	for pos in get_simple_path:
		var world_map_position : Vector2 = map_to_world(pos) + tilemap_cell_center
		world_map.append( world_map_position )
	
	GlobalGameDataScript.emit_signal( "wizard_receive_new_path", wizard_name, PoolVector2Array( world_map ) )

