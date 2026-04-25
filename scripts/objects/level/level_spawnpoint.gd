extends Marker2D

@export var spawnpoint_name:String = "main"

@onready var image = $Image

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("LevelSpawnPoint")
	image.visible = false
