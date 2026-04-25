extends CanvasLayer

@onready var score_text = $Score
@onready var distro_text = $Distros

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false

func show_thing():
	Music.stop()
	visible = true
	score_text.text = "Score: " + str(Global.score)
	distro_text.text = "Distros: " + str(Global.distros)
	get_tree().paused = true
	await get_tree().create_timer(3).timeout
	get_tree().paused = false
	visible = false
