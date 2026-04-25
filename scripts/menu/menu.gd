extends Node2D

@onready var play_button = $PlayButton
@onready var credits_button = $CreditsButton
@onready var delete_button = $DeleteButton

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.load_data()
	Global.sector_song = ""
	Music.stop()
	play_button.connect("pressed", _on_play_pressed)
	delete_button.connect("pressed", _on_delete_pressed)

func _on_play_pressed():
	get_tree().change_scene_to_file("res://scenes/levels/world1/test_level/test_level.tscn")

func _on_delete_pressed():
	Global.delete_data()
