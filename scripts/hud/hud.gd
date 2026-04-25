extends CanvasLayer

@onready var score_text = $Score
@onready var distro_text = $Distro
@onready var health_text = $Health

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	score_text.text = "Score: " + str(Global.score)
	distro_text.text = "Distros: " + str(Global.distros)
	health_text.text = "Health: " + str(TuxManager.health) + " / " + str(TuxManager.max_health)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	score_text.text = "Score: " + str(Global.score)
	distro_text.text = "Distros: " + str(Global.distros)
	health_text.text = "Health: " + str(TuxManager.health) + " / " + str(TuxManager.max_health)
