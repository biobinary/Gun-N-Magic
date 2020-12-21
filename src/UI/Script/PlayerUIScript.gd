extends Control

# All The Weapon Info
onready var weapon_texture : TextureRect = get_node( "WeaponInfo/WeaponTexture" )
onready var magazine_label : Label = get_node( "WeaponInfo/WeaponMagazineInfo" )
# ---------------------------------------------------------------------------------

onready var objective_label : Label = get_node( "ObjectiveLabel" )

func _ready() -> void:
	
	GlobalGameDataScript.connect( "player_objective_changed", self, "_do_update_objective")
	var current_player_objective : String = GlobalGameDataScript.current_objective
	if current_player_objective != "":
		_do_update_objective( current_player_objective )
	else:
		_do_update_objective( "" )

func do_update_ammo_status(new_text : String) -> void:
	magazine_label.text = new_text

func _do_update_objective( new_objective : String ) -> void:
	if new_objective != "":
		objective_label.text = "Objective : " + new_objective
	else:
		objective_label.text = 'Objective : ' + "None"
