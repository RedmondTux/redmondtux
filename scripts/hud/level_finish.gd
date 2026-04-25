extends CanvasLayer

@onready var score_text = $Score
@onready var distro_text = $Distros

func _ready() -> void:
	visible = false

func show_thing():
	visible = true
	score_text.text = "Score: " + str(Global.score)
	distro_text.text = "Distros: " + str(Global.distros)
	get_tree().paused = true
	await get_tree().create_timer(3).timeout
	get_tree().change_scene_to_file(Global.next_level_path)
	get_tree().paused = false
	visible = false
