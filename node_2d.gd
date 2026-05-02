extends Node2D

enum ArmPosition { NEUTRAL, POINT_LEFT, POINT_RIGHT, BOTH_UP }
var sequence_steps = []
var player_input = []

enum GamePhase { SHOW_SEQUENCE, RESPONSE }
var game_phase = GamePhase.SHOW_SEQUENCE

const ARM_TO_ARROW_MAPPING = {
	ArmPosition.BOTH_UP: 0,
	ArmPosition.POINT_RIGHT: 1,
	ArmPosition.POINT_LEFT: 3,
}
const STEP_DELAY = 0.8 #seconds
const BETWEEN_STEP_DELAY = 0.2 #seconds

@onready var right_arm: AnimatedSprite2D = $sRightArmV66
@onready var left_arm: AnimatedSprite2D = $sLeftArmV65
@onready var arrow: AnimatedSprite2D = $Arrow
@onready var animation_player: AnimationPlayer = $AnimationPlayer


@export var current_position: ArmPosition = ArmPosition.NEUTRAL:
	set(value):
		if current_position == value: 
			return
		current_position = value
		if is_inside_tree():
			_update_arm_positions()

func _update_arm_positions() -> void:
	match current_position:
		ArmPosition.NEUTRAL:
			left_arm.frame = 0
			right_arm.frame = 0
			
		ArmPosition.POINT_LEFT:
			left_arm.frame = 1
			right_arm.frame = 0
			
		ArmPosition.POINT_RIGHT:
			left_arm.frame = 0
			right_arm.frame = 1
			
		ArmPosition.BOTH_UP:
			left_arm.frame = 2
			right_arm.frame = 2

func _show_sequence() -> void:
	for step in sequence_steps:
		arrow.visible = true
		arrow.frame = ARM_TO_ARROW_MAPPING[step]
		await get_tree().create_timer(STEP_DELAY).timeout
		arrow.visible = false
		await get_tree().create_timer(BETWEEN_STEP_DELAY).timeout
	
func _generate_sequence(len: int = 4):
	var valid_positions = [ArmPosition.POINT_LEFT, ArmPosition.POINT_RIGHT, ArmPosition.BOTH_UP]
	sequence_steps.clear()
	for i in range(len):
		sequence_steps.append(valid_positions.pick_random())

func _ready() -> void:
	_generate_sequence()
	await _show_sequence()
	print(sequence_steps)
	game_phase = GamePhase.RESPONSE
	
func _input_arm_position(arm_position: ArmPosition):
	player_input.append(arm_position)
	
	if len(player_input) == len(sequence_steps):
		print(player_input == sequence_steps)
		if player_input == sequence_steps:
			animation_player.play("correct_response")
		player_input.clear()

# Input Polling (as discussed)
func _process(_delta: float) -> void:
	if Engine.is_editor_hint(): return # Don't poll in the editor
	
	if game_phase == GamePhase.RESPONSE:
		var next_pos = ArmPosition.NEUTRAL
		if Input.is_action_just_pressed("ui_up"):
			_input_arm_position(ArmPosition.BOTH_UP)
		elif Input.is_action_just_pressed("ui_left"):
			_input_arm_position(ArmPosition.POINT_LEFT)
		elif Input.is_action_just_pressed("ui_right"):
			_input_arm_position(ArmPosition.POINT_RIGHT)
	
		if Input.is_action_pressed("ui_up"):
			next_pos = ArmPosition.BOTH_UP
		elif Input.is_action_pressed("ui_left"):
			next_pos = ArmPosition.POINT_LEFT
		elif Input.is_action_pressed("ui_right"):
			next_pos = ArmPosition.POINT_RIGHT
		
		current_position = next_pos
