extends RigidBody2D

var in_floor : bool = true
var pickup : bool = false
var velocity: Vector2 = Vector2.ZERO

var player = null

# Called when the node enters the scene tree for the first time.
func _ready():
	var tree = get_tree()
# warning-ignore:return_value_discarded
	Signals.connect("pickup_box",self,"box_move")
# warning-ignore:return_value_discarded
	Signals.connect("drop_box",self,"box_stay")
	
	if tree.has_group("Player"):
		player = tree.get_nodes_in_group("Player")[0]
	
# warning-ignore:unused_argument
func _physics_process(delta):
	if pickup:
		position.x = player.global_position.x -20
		position.y = player.global_position.y
		$CollisionBox.disabled = true
		
	else:
		$CollisionBox.disabled = false

func box_move():
	pickup = true
	
func box_stay():
	pickup = false
	
