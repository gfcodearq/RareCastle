extends KinematicBody2D


var speed = 40
var player_chase = false
var player = null
var player_spotted: bool = false

var healt = 100
var player_inattack_zone = false
var can_take_damage = true

#Path Finding
var path: Array = []
var levelNavigation :  Navigation2D = null
var velocity: Vector2 = Vector2.ZERO
onready var lineOfSight = $LineOfSight


func _ready():
	var tree = get_tree()
	if tree.has_group("LevelNavigation"):
		levelNavigation = tree.get_nodes_in_group("LevelNavigation")[0]
	if tree.has_group("Player"):
		player = tree.get_nodes_in_group("Player")[0]
		
func generate_path():
	if levelNavigation != null and player !=null:
		path = levelNavigation.get_simple_path(global_position,player.global_position,false)

func navigate():
	if path.size() > 0:
		velocity = global_position.direction_to(path[1]) * speed
	
		if global_position == path[0]:
			path.pop_front()


func _physics_process(delta):
	if player:
		lineOfSight.look_at(player.global_position)
		check_player_in_detection()
		if player_spotted: 
			generate_path()
			navigate()
	deal_with_damage()
	move()
	
func _on_detection_area_body_entered(body):
	player = body 
	player_chase = true

func _on_detection_area_body_exited(body):
	player = null
	player_chase = false

func enemy():
	pass

func _on_enemy_hitbox_area_entered(area):
	if area.is_in_group("player_hitbox"):
		player_inattack_zone = true

func _on_enemy_hitbox_area_exited(area):
	if area.is_in_group("player_hitbox"):
		player_inattack_zone = false
		
func deal_with_damage():
	if player_inattack_zone and Global.player_current_attack == true:
		if can_take_damage == true:
			healt = healt - 20
			$take_damage_cooldown.start()
			can_take_damage = false
			print ("slime healt = ",healt)
			if healt <= 0:
				self.queue_free()


func _on_take_damage_cooldown_timeout():
	can_take_damage = true
	
func move():
	velocity = move_and_slide(velocity)
	$AnimatedSprite.play("Walking")
	
	if(player.position.x - position.x) < 0:
		$AnimatedSprite.flip_h = true
	else:
		$AnimatedSprite.flip_h = false


func check_player_in_detection() -> bool:
	var collider = lineOfSight.get_collider()
	if collider and collider.is_in_group("Player"):
		player_spotted = true
		return true
	return false
