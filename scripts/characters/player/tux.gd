extends CharacterBody2D

# code from godottux
# i'm still actually too lazy to add comments right now, wow!

# movement
@export var speed:int = 320
@export_range(0, 0.1) var acceleration:float = 0.06
@export_range(0, 0.1) var deceleration:float = 0.06
@export var max_jump_height:int = 576
@export var min_jump_height:float = 512.0
@export var decelerate_on_jump_release:int = 0

var in_cutscene:bool = false
var auto_walk:bool = false
var auto_walk_speed:int = 0;

var inv_seconds:int = 1
var invincible:bool = false

var held_object:CharacterBody2D = null

var was_on_floor = false

var can_shoot_bullets:bool = true
var max_fireballs_allowed:int = 2

var rock_above:bool = false

var duck:bool = false

var show_stars:bool = false

@export var invincible_music = "res://data/music/salcon.ogg"

@onready var image = $Image
@onready var fire_image = $FireImage
@onready var collision = $Collision
@onready var duck_collision = $DuckCollision
@onready var stomp = $Stomp
@onready var camera = $Camera
@onready var ceiling_detector = $CeilingDetector
@onready var jump_sound = $JumpSound
@onready var invincible_sound = $InvincibleSound
@onready var tux_hurt_sound = $TuxHurtSound
@onready var tux_yay_sound = $TuxYaySound
@onready var coyote_timer = $CoyoteTimer
@onready var tile_timer = $TileTimer
@onready var herring_timer = $HerringTimer

func _ready() -> void:
	add_to_group("Player")
	stomp.add_to_group("Stomp")
	reload_player()
	stomp.connect("area_entered", _on_stompable_object_detected)
	herring_timer.connect("timeout", _on_herring_timer_done)
	TuxManager.health = TuxManager.max_health

func _physics_process(delta: float) -> void:
	
	if position.x < camera.limit_left:
		position.x = 0
	
	if position.y > camera.limit_bottom and not in_cutscene:
		die()
	
	if position.x > camera.limit_right - collision.shape.size.x:
		position.x = camera.limit_right - collision.shape.size.x
	
	if not is_on_floor() and tile_timer.is_stopped():
		velocity += get_gravity() * delta
	
	if auto_walk:
		velocity.x = TuxManager.facing_direction * auto_walk_speed
	
	if get_tree().get_nodes_in_group("FireBullet").size() >= max_fireballs_allowed:
		can_shoot_bullets = false
	else:
		can_shoot_bullets = true
	
	move()
	animate()
	
	if Input.is_action_just_released("player_action") and not held_object == null and not held_object.held_by == null:
		throw_object()
	
	if not held_object == null and not held_object.held_by == null:
		throw_object()
	
	move_and_slide()
	
	if was_on_floor and not is_on_floor() and not Input.is_action_just_pressed("player_jump"):
		coyote_timer.start()
		tile_timer.start()

func die():
	get_tree().call_deferred("reload_current_scene")

func move():
	was_on_floor = is_on_floor()
	
	var direction := Input.get_axis("player_left", "player_right")
	var duck_on_floor = duck and is_on_floor()
	
	if direction and not duck_on_floor:
		velocity.x = move_toward(velocity.x, direction * speed, speed * acceleration)
	else:
		velocity.x = move_toward(velocity.x, 0, speed * deceleration)
	
	if direction == -1:
		TuxManager.facing_direction = -1
	elif direction == 1:
		TuxManager.facing_direction = 1

	var on_floor_or_coyote = is_on_floor() or not coyote_timer.is_stopped()
	if Input.is_action_just_pressed("player_jump") and on_floor_or_coyote:
		jump_sound.play()
		if abs(velocity.x) == speed:
			velocity.y = -max_jump_height
		else:
			velocity.y = -min_jump_height
	
	if Input.is_action_just_released("player_jump") and velocity.y < 0:
		velocity.y *= decelerate_on_jump_release
	
	if Input.is_action_pressed("player_down") and is_on_floor():
		duck = true
	elif not Input.is_action_pressed("player_down") and not ceiling_detector.is_colliding():
		duck = false
	
	if duck:
		duck_collision.set_deferred("disabled", false)
		collision.set_deferred("disabled", true)
	else:
		duck_collision.set_deferred("disabled", true)
		collision.set_deferred("disabled", false)

func animate():
	if Global.tux_herring_invincible:
		pass # placeholder
	else:
		pass # placeholder

	if not duck:
		if not is_on_floor():
			image.play("jump")
			fire_image.play("jump")
		elif is_on_floor() and velocity.x == 0:
			image.play("stand")
			fire_image.play("stand")
		elif not abs(velocity.x) == 0 and not is_on_wall() and is_on_floor():
			image.play("walk")
			fire_image.play("walk")
		
		if is_on_wall() and is_on_floor():
			image.play("stand")
			fire_image.play("stand")
	elif duck:
		image.play("duck")
		fire_image.play("duck")
	
	if TuxManager.facing_direction == -1:
		image.flip_h = true
		fire_image.flip_h = true
	else:
		image.flip_h = false
		fire_image.flip_h = false

func damage(amount:int):
	if invincible or Global.tux_herring_invincible:
		return
	
	if not invincible or not Global.tux_herring_invincible:
		if TuxManager.health <= 1:
			die()
			return
		
		invincible = true
		print("Tux damaged!")
		TuxManager.health -= amount
		tux_hurt_sound.play()
		if TuxManager.current_state == TuxManager.powerup_states.Fire:
			TuxManager.current_state = TuxManager.powerup_states.Normal
		await get_tree().create_timer(inv_seconds).timeout
		invincible = false

func heal(amount:int):
	if TuxManager.health >= TuxManager.max_health:
		return
	
	tux_yay_sound.play()
	TuxManager.health += amount

func reload_player():
	if TuxManager.current_state == TuxManager.powerup_states.Fire:
		Global.tux_state = TuxManager.current_state
		image.visible = false
		fire_image.visible = true
	elif TuxManager.current_state == TuxManager.powerup_states.Normal:
		Global.tux_state = TuxManager.current_state
		image.visible = true
		fire_image.visible = false

func stomp_bounce():
	if Input.is_action_pressed("player_jump"):
		velocity.y = -min_jump_height
	else:
		velocity.y = -min_jump_height / 2

func hold_object(object):
	if held_object == null:
		held_object = object
		object.pick_up(self)

func throw_object():
	if not held_object == null:
		held_object.throw(TuxManager.facing_direction)
		held_object = null

func grow(powerup:String):
	if powerup == "coffee":
		TuxManager.current_state = TuxManager.powerup_states.Fire
		reload_player()
	else:
		print("Not a valid powerup.")

func shoot():
	if TuxManager.current_state == TuxManager.powerup_states.Fire and Input.is_action_just_pressed("player_action") and can_shoot_bullets:
		pass # placeholder

func _on_stompable_object_detected(area):
	if area.is_in_group("BouncingEnemyTuxDetector"):
		invincible = true
		await get_tree().create_timer(0.1).timeout
		invincible = false

func get_star():
	if not in_cutscene:
		Global.tux_herring_invincible = true
		invincible_sound.play()
		Music.stream = load(invincible_music)
		Music.play()
		herring_timer.start()

func _on_herring_timer_done():
	if not in_cutscene:
		Global.tux_herring_invincible = false
		Music.stream = load(Global.sector_song)
		Music.play()
