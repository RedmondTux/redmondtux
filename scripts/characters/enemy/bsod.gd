extends BadGuy
class_name BSOD

@export var fall_jump = 256

func _ready() -> void:
	tux_detector.connect("area_entered", _on_tux_detector_area_entered)
	tux_detector.connect("body_entered", _on_tux_detector_body_entered)
	image.play("walk")
	super()

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if current_state == EnemyStates.Alive:
		velocity.x = direction * speed
	else:
		velocity.x = 0
	
	if is_on_wall() and not was_on_wall:
		flip_direction()
	
	if direction == -1:
		image.flip_h = false
		ground_detector.position.x = ground_detector_pos_x_left
	else:
		image.flip_h = true
		ground_detector.position.x = ground_detector_pos_x_right
	
	if smart and not current_state == EnemyStates.Dead and is_on_floor():
		if not ground_detector.is_colliding():
			flip_direction()
	
	was_on_wall = is_on_wall()
	
	move_and_slide()

func flip_direction():
	direction = -direction

func death(fall:bool):
	current_state = EnemyStates.Dead
	tux_detector.set_deferred("monitoring", false)
	tux_detector.set_deferred("monitorable", false)
	
	if fall:
		velocity.x = 0
		velocity.y = -fall_jump
		$Collision.set_deferred("disabled", true)
		image.play("fall")
		fall_sound.play()
	else:
		set_collision_layer_value(4, true)
		set_collision_layer_value(3, false)
		set_collision_mask_value(3, false)
		squish_sound.play()
		image.play("squished")
		await get_tree().create_timer(death_time).timeout
		queue_free()

func _on_tux_detector_area_entered(area):
	if area.is_in_group("Stomp"):
		var tux_stomp = area.get_parent().get_real_velocity().y > 0
		
		if current_state == EnemyStates.Dead:
			return
		
		if tux_stomp:
			Global.score += score_amount
			
			if not Global.tux_herring_invincible:
				area.get_parent().stomp_bounce()
				death(false)
			else:
				death(true)

func _on_tux_detector_body_entered(body):
	if body.is_in_group("Player"):
		if not Global.tux_herring_invincible:
			body.damage(1)
		else:
			death(true)
