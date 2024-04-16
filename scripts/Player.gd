extends KinematicBody2D
const SPEED = 100

var enemy_inattack_range = false
var enemy_attack_cooldown = true
var healt = 100
var player_alive = true

var attack_ip = false
var in_box = false
var velocity = Vector2()
var current_dir = "none"

var pickUp_box : bool = false
var drop_box : bool = false
var in_goal : bool = false

func _ready():
	$AnimatedSprite.play("front_idle")

func _physics_process(delta):
	player_movement(delta)
	enemy_attack()
	pickUp()
	attack()
	game_over()
	you_win()
	update_healt()

func player_movement(delta):
	if Input.is_action_pressed("ui_right"):
		current_dir = "right"
		play_anim(1)
		velocity.x = SPEED
		velocity.y = 0
	elif Input.is_action_pressed("ui_left"):
		current_dir = "left"
		play_anim(1)
		velocity.x = -SPEED
		velocity.y = 0
	elif Input.is_action_pressed("ui_down"):
		current_dir = "down"
		play_anim(1)
		velocity.y = SPEED
		velocity.x = 0
	elif Input.is_action_pressed("ui_up"):
		current_dir = "up"
		play_anim(1)
		velocity.y = -SPEED
		velocity.x = 0
	else:
		play_anim(0)
		velocity.x = 0
		velocity.y = 0
	
	move_and_slide(velocity,Vector2(0,0))
	
func play_anim(movement):
	var dir = current_dir
	var anim = $AnimatedSprite
	
	if dir == "right":
		anim.flip_h = false
		if movement == 1:
			anim.play("side_walk")
		elif movement == 0:
			if attack_ip == false:
				anim.play("side_idle")
	
	if dir == "left":
		anim.flip_h = true
		if movement == 1:
			anim.play("side_walk")
		elif movement == 0:
			if attack_ip == false:
				anim.play("side_idle")
	
	if dir == "down":
		anim.flip_h = true
		if movement == 1:
			anim.play("front_walk")
		elif movement == 0:
			if attack_ip == false:
				anim.play("front_idle")

	if dir == "up":
		anim.flip_h = false
		if movement == 1:
			anim.play("back_walk")
		elif movement == 0:
			if attack_ip == false:
				anim.play("back_idle")

func player():
	pass

func enemy_attack():
	if enemy_inattack_range and enemy_attack_cooldown == true:
		healt = healt - 10
		enemy_attack_cooldown = false
		$attack_cooldown.start()
		print("player took damage")

func _on_player_hitbox_area_entered(area):
	if area.is_in_group("enemy_hitbox"):
		enemy_inattack_range = true

func _on_player_hitbox_area_exited(area):
	if area.is_in_group("enemy_hitbox"):
		enemy_inattack_range = false

func _on_attack_cooldown_timeout():
	enemy_attack_cooldown = true

func attack():
	var dir = current_dir
	
	if Input.is_action_just_pressed("attack"):
		Global.player_current_attack = true
		attack_ip = true
		if dir == "right":
			$AnimatedSprite.flip_h = false
			$AnimatedSprite.play("side_attack")
			$deal_attack_timer.start()
		if dir == "left":
			$AnimatedSprite.flip_h = true
			$AnimatedSprite.play("side_attack")
			$deal_attack_timer.start()
		if dir == "down":
			$AnimatedSprite.play("front_attack")
			$deal_attack_timer.start()
		if dir == "up":
			$AnimatedSprite.play("back_attack")
			$deal_attack_timer.start()
			
func pickUp():
	if Input.is_action_just_pressed("pickUp") and in_box == true:
		Signals.emit_signal("pickup_box")
		pickUp_box = true
	else:
		pickUp_box = false	
		
	if Input.is_action_just_released("pickUp") and in_box == true:
		Signals.emit_signal("drop_box")
		drop_box = true

func _on_deal_attack_timer_timeout():
	$deal_attack_timer.stop()
	Global.player_current_attack = false
	attack_ip = false
		
func game_over():
	if healt == 0:
		get_tree().change_scene("res://GameOver.tscn")
	if drop_box == true and in_goal == false:
		get_tree().change_scene("res://GameOver.tscn")

func you_win():
	if in_goal == true and drop_box == true:
		get_tree().change_scene("res://YouWin.tscn")

func _on_collisions_area_area_entered(area):
	if area.is_in_group("Zone1"):
		print("zone1")
		Signals.emit_signal("zone1")
	
	#player is in goal
	if area.is_in_group("Goal"):
		in_goal = true
		
	#player touch the box	
	if area.is_in_group("box_enter"):
		in_box = true
	
	#player touch the fire
	if area.is_in_group("fire_area"):
		healt = 0
	if area.is_in_group("fire_area2"):
		healt = 0
	if area.is_in_group("fire_area3"):
		healt = 0
	if area.is_in_group("fire_area4"):
		healt = 0
	if area.is_in_group("fire_area5"):
		healt = 0
		
	#player touch the water
	if area.is_in_group("water_area"):
		healt = 0
	if area.is_in_group("water_area2"):
		healt = 0
	if area.is_in_group("water_area3"):
		healt = 0
	if area.is_in_group("water_area4"):
		healt = 0
		
	#player touch a transport zone
	if area.is_in_group("Transport"):
		position.x = 103	
		position.y = 91

	if area.is_in_group("Transport2"):
		position.x = 329	
		position.y = 205
	
	if area.is_in_group("Transport3"):
		position.x = 472	
		position.y = 170
	
	if area.is_in_group("Transport4"):
		position.x = 472	
		position.y = 458
	
	if area.is_in_group("Transport5"):
		position.x = 615	
		position.y = 161
	
	if area.is_in_group("Transport6"):
		position.x = 105	
		position.y = 267
	


func _on_collisions_area_area_exited(area):
	if area.is_in_group("Zone1"):
		Signals.emit_signal("out_zone1")


func update_healt():
	var healthbar = $healtBar
	healthbar.value = healt
	
	if healt >= 100:
		healthbar.visible = false
	else:
		healthbar.visible = true

func _on_regin_timer_timeout():
	if healt < 100:
		healt = healt + 20
		if healt > 100:
			healt = 100 
	if healt == 0:
		healt = 0
