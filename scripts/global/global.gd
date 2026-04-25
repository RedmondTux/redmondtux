extends Node

var level_name:String
var level_creator:String
var width_of_level:int = 0
var height_of_level:int = 0
var next_level_path:String

var score:int = 0
var distros:int = 0
var tux_state:TuxManager.powerup_states = TuxManager.powerup_states.Normal

var global_spawn_name:String = "main"
var use_spawn_point:bool = false

var worldmap_name:String
var width_of_worldmap:int = 0
var height_of_worldmap:int = 0

var dot_level_name:String

var tux_wm_x:float = 0.0
var tux_wm_y:float = 0.0

var current_level:String
var current_worldmap:String

var completed_levels:Array = []
var completed_worldmaps:Array = []

var save_file = "user://save"

var checkpoint_reached:bool = false
var checkpoint_position:Vector2 = Vector2(0, 0)
var checkpoint_sector:String

var sector_song:String
var tux_herring_invincible:bool = false

func save_data():
	var file = FileAccess.open(save_file, FileAccess.WRITE)
	file.store_var(score)
	file.store_var(distros)
	file.store_var(tux_state)
	file.store_var(completed_levels)

func load_data():
	if FileAccess.file_exists(save_file):
		print("Save file exists! Loading data...")
		var file = FileAccess.open(save_file, FileAccess.READ)
		score = file.get_var()
		distros = file.get_var()
		tux_state = file.get_var()
		completed_levels = file.get_var()
		print("score: ", score)
		print("distros: ", distros)
		print("tux_state: ", tux_state)
		print("completed_levels: ", completed_levels)
	else:
		print("Save file doesn't exist, saving data...")
		save_data()

func delete_data():
	DirAccess.remove_absolute(save_file)
	get_tree().quit()
