extends Node2D

enum ArmPosition { NEUTRAL, POINT_LEFT, POINT_RIGHT, BOTH_UP }

@onready var right_arm: Sprite2D = $Marker2D/sRightArmV66
@onready var left_arm: Sprite2D = $Marker2D2/sLeftArmV65

# 1. Add a variable to track the "Active Brain" of the animation
var active_tween: Tween

@export var current_position: ArmPosition = ArmPosition.NEUTRAL:
	set(value):
		if current_position == value: 
			return
		current_position = value
		if is_inside_tree():
			_update_arm_positions()

func _update_arm_positions() -> void:
	# 2. CRITICAL: Kill any existing tween so they don't fight!
	if active_tween:
		active_tween.kill()

	# 3. Create the new one and store it
	active_tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	match current_position:
		ArmPosition.NEUTRAL:
			active_tween.tween_property(right_arm, "rotation_degrees", 0, 0.3)
			active_tween.tween_property(left_arm, "rotation_degrees", 0, 0.3)
			active_tween.tween_property(right_arm, "position:y", 0, 0.3)
			active_tween.tween_property(left_arm, "position:y", 0, 0.3)
			
		ArmPosition.POINT_LEFT:
			active_tween.tween_property(right_arm, "rotation_degrees", -90, 0.3)
			active_tween.tween_property(left_arm, "rotation_degrees", -90, 0.3)
			active_tween.tween_property(right_arm, "position:y", 0, 0.3)
			active_tween.tween_property(left_arm, "position:y", 0, 0.3)
			
		ArmPosition.POINT_RIGHT:
			active_tween.tween_property(right_arm, "rotation_degrees", 90, 0.3)
			active_tween.tween_property(left_arm, "rotation_degrees", 90, 0.3)
			active_tween.tween_property(right_arm, "position:y", 0, 0.3)
			active_tween.tween_property(left_arm, "position:y", 0, 0.3)
			
		ArmPosition.BOTH_UP:
			# Sequence: Rotate first, THEN slide up
			active_tween.tween_property(right_arm, "rotation_degrees", 0, 0.2)
			active_tween.tween_property(left_arm, "rotation_degrees", 0, 0.2)
			
			active_tween.tween_property(right_arm, "position:y", -50, 0.2)
			active_tween.tween_property(left_arm, "position:y", -50, 0.2)

# Input Polling (as discussed)
func _process(_delta: float) -> void:
	if Engine.is_editor_hint(): return # Don't poll in the editor
	
	var next_pos = ArmPosition.NEUTRAL
	if Input.is_action_pressed("ui_up"):
		next_pos = ArmPosition.BOTH_UP
	elif Input.is_action_pressed("ui_left"):
		next_pos = ArmPosition.POINT_LEFT
	elif Input.is_action_pressed("ui_right"):
		next_pos = ArmPosition.POINT_RIGHT
		
	current_position = next_pos
