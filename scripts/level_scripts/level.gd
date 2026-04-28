extends Node2D
class_name Level

@export var level_name:String = "Unnamed"
@export var level_creator:String = "Level Creator"
@export var license:String = "CC-BY-SA 4.0"
@export var level_note:String
@export var main_sector:String = "main"
@export var main_spawnpoint:String = "main"
@export var next_level:String = "res://scenes/menu/menu.tscn"

var sector_name_to_use:String

@onready var tux = $Tux
@onready var tux_camera = $Tux/Camera

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.next_level_path = next_level
	LevelStart.show_thing()
	find_sector()
	activate_sector(sector_name_to_use)
	TuxManager.current_state = Global.tux_state
	print(TuxManager.current_state)
	print("Useful level debugging info, possibly:")
	print("Width in pixels: " + str(Global.width_of_level) + ". If this is 0, and you didn't set Level Width to 0, there's most likely a bug you should report.")
	print("Height in pixels: " + str(Global.height_of_level) + ". If this is 0, and you didn't set Level Height to 0, there's most likely a bug you should report.")
	print("No more useful level debugging info.")

func find_spawnpoint():
	if not Global.checkpoint_reached:
		for spawn in get_tree().get_nodes_in_group("LevelSpawnPoint"):
			if spawn.spawnpoint_name == main_spawnpoint:
				tux.global_position = spawn.global_position - Vector2(0, 24.5)
	else:
		tux.global_position = Global.checkpoint_position - Vector2(0, 24.5)

func find_sector():
	if Global.checkpoint_reached:
		sector_name_to_use = Global.checkpoint_sector
	else:
		sector_name_to_use = main_sector
	
	for sector in get_tree().get_nodes_in_group("LevelSector"):
		if sector.sector_name == sector_name_to_use:
			find_spawnpoint()

func switch_sector(sector_name:String, spawnpoint_name:String):
	activate_sector(sector_name)
	
	for sector in get_tree().get_nodes_in_group("LevelSector"):
		if sector.sector_name == sector_name:
			find_spawnpoint_in_sector(sector, spawnpoint_name)

func find_spawnpoint_in_sector(sector:Node2D, new_spawnpoint_name:String):
	for spawn in get_tree().get_nodes_in_group("LevelSpawnPoint"):
		if spawn.spawnpoint_name == new_spawnpoint_name:
			tux.call_deferred("reparent", sector)
			tux.global_position = spawn.global_position - Vector2(0, 24.5)
			tux.in_cutscene = false

func activate_sector(sector_name:String):
	for sector in get_tree().get_nodes_in_group("LevelSector"):
		if sector.sector_name == sector_name:
			sector.visible = true
			sector.process_mode = Node.PROCESS_MODE_PAUSABLE
			Global.width_of_level = sector.sector_width * 32
			Global.height_of_level = sector.add_to_sector_height * 32
			tux_camera.limit_top = -Global.height_of_level
			tux_camera.limit_right = Global.width_of_level
			if not Global.tux_herring_invincible:
				Music.stream = load(sector.song)
				Music.play()
			Global.sector_song = sector.song
		else:
			sector.visible = false
			sector.process_mode = Node.PROCESS_MODE_DISABLED

func finish_level():
	LevelFinish.show_thing()
