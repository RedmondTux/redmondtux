extends Node2D
class_name Sector

@export var sector_name:String = "main"
@export var sector_width:int = 100
@export var add_to_sector_height:int = 0
@export_file("*.ogg", "*.wav") var song = "res://data/music/chipdisko.ogg"

@onready var goal = $Goal

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("LevelSector")
	goal.connect("level_finished", _on_level_finished)

func _on_level_finished():
	Global.checkpoint_reached = false
	get_parent().finish_level()

func fade_tilemap(tilemap_to_fade:String):
	var tilemap = get_node(tilemap_to_fade)
	var fade_tween = create_tween()
	fade_tween.tween_property(tilemap, "modulate:a", 0.0, 1.0)
	fade_tween.tween_callback(tilemap.queue_free)
