extends Area2D

signal level_finished

@onready var image = $Image

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	image.play("default")
	connect("body_entered", _on_body_entered)

func _on_body_entered(body):
	if body.is_in_group("Player"):
		level_finished.emit()
		Signals.level_actually_done.emit()
