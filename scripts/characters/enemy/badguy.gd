extends CharacterBody2D
class_name BadGuy

enum EnemyStates {Alive, Dead}
var current_state:EnemyStates = EnemyStates.Alive

@export var speed:int = 80
@export var death_time:int = 2

var was_on_wall:bool = false

@export var direction:int = -1
var flammable:bool = true

var smart:bool = false

@export var ground_detector_pos_x_left:float = 2.0
@export var ground_detector_pos_x_right:float = 27.0

@export var score_amount:int = 50

@onready var image = $Image
@onready var collision = $Collision
@onready var tux_detector = $TuxDetector
@onready var fall_sound = $FallSound
@onready var squish_sound = $SquishSound
@onready var ground_detector = $GroundDetector

func _ready() -> void:
	add_to_group("Enemy")
	tux_detector.add_to_group("EnemyTuxDetector")
