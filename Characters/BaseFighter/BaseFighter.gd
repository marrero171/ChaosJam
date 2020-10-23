extends KinematicBody2D

#Onready Vars
onready var ground_raycasts = $GroundRaycasts
onready var body = $Body
onready var baseFSM = $BaseFSM

#Constants
const max_speed : int = 580
const max_strength : int = 100
const max_defence : int = 100
var jump_velocity : int = -620
var min_jump_velocity : int = -200

#Variables
var velocity : Vector2 = Vector2()
var speed : int
var strength : int
var defence : int
var is_grounded : bool = false

#these "can" be negative but not zero

export var speed_stat : int #make it 1-10
export var strength_stat : int #same as above make it 1-10 
export var defence_stat : int


func error_start_check():
	#returns false if is missing key components
	if speed_stat == 0 ||strength_stat == 0 ||defence_stat == 0:
		print("stats can not be zero!")
		return false
	elif !ground_raycasts:
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
		speed = max_speed * speed_stat/10
		strength = max_strength*strength_stat/10
		defence = max_defence*defence_stat/10
		set_physics_process(true)
	else:
		get_tree().quit()

func jump():
	velocity.y = jump_velocity

func _check_is_grounded():
	for raycast in ground_raycasts.get_children():
		return raycast.is_colliding()

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
	velocity.x = lerp(velocity.x,speed*move_direction,_get_h_weight())
	if move_direction != 0:
		body.scale.x = move_direction

func _get_h_weight():
	return 0.2 if is_grounded else 0.1
