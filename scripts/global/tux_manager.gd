extends CharacterBody2D

enum powerup_states {Normal, Fire}

var facing_direction:int = 1

var current_state:powerup_states = powerup_states.Normal

var max_health:int = 3
var health:int = 3
