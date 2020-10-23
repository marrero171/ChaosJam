extends KinematicBody2D

onready var ground_raycasts = $GroundRaycasts
onready var body = $Body
onready var baseFSM = $BaseFSM


var velocity = Vector2()
var max_speed = 580
var max_strength = 100
var max_defense = 100
var speed
var strength
var defense
var jump_velocity = -620
var min_jump_velocity = -200
var is_grounded = false

export var stats = {
	"speed" : 0, #make it 1-10
	"strength" : 0, #same as above, make it 1-10
	"defense" : 0
}

#these "can" be negative but not zero



func error_start_check():
	#returns false if is missing key components
	for i in stats.values():
		if i == 0:
			print("stats can not be zero!")
			return false
	if !ground_raycasts:
		print("You must add ground raycasts to player. Use Node2d named 'GroundRaycasts' with raycast2ds as children")
	elif !body:
		print("Please Store all visual nodes such as sprites inside a Node2D named 'Body'")
		return false
	elif !baseFSM:
		print("Please create a node named BaseFSM that inherits from res://Characters/BaseFighter/BaseStateMachine.gd ")
	else:
		return true

func _ready():
	set_physics_process(false)
	if error_start_check():
		stats.speed = max_speed * stats.speed / 10
		stats.strength = max_strength * stats.strength / 10
		stats.defense = max_defense * stats.defense / 10
		set_physics_process(true)
	else:
		get_tree().quit()


func jump():
	velocity.y = jump_velocity

func _check_is_grounded():
	for raycast in ground_raycasts.get_children():
		if raycast.is_colliding():
			return true
	
	
	return false

func _apply_gravity(delta):
	velocity.y += Globals.gravity*delta

func _input(event):
	if event.is_action_pressed("player_jump") and is_grounded:
		jump()
	
	
	
	if event.is_action_released("player_jump") && velocity.y < min_jump_velocity:
		velocity.y = min_jump_velocity




func _physics_process(delta):
	_apply_gravity(delta)
	_handle_sideways_movement()
	
	
	velocity = move_and_slide(velocity,Vector2.UP)
	
	
	is_grounded = _check_is_grounded()




func _handle_sideways_movement():
	var move_direction = -int(Input.is_action_pressed("player_left"))+int(Input.is_action_pressed("player_right"))
	velocity.x = lerp(velocity.x, stats.speed * move_direction,_get_h_weight())
	if move_direction != 0:
		body.scale.x = move_direction


func _get_h_weight():
	if is_grounded:
		return 0.2
	else:
		return 0.1




