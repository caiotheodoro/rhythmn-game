extends AnimatedSprite2D

var perfect = false
var good = false
var okay = false
var current_note = null
var is_touching = false  # New variable to track touch state

@export var input = ""
func _unhandled_input(event):
	if event.is_action(input):
		if event is InputEventScreenTouch:
			is_touching = event.pressed  # Set the touch state

			if is_touching:  # Handle only pressed event
				_on_button_pressed()
		elif event is InputEventKey and event.pressed:
			match event.keycode:
				KEY_LEFT, KEY_RIGHT, KEY_UP:
					_on_button_pressed()
			
		elif event.is_action_released(input):
			$PushTimer.start()

func _on_button_pressed():
	if current_note != null:
		if perfect:
			get_parent().increment_score(3)
			current_note.destroy(3)
		elif good:
			get_parent().increment_score(2)
			current_note.destroy(2)
		elif okay:
			get_parent().increment_score(1)
			current_note.destroy(1)
		_reset()
	else:
		get_parent().increment_score(0)

func _reset():
	current_note = null
	perfect = false
	good = false
	okay = false

func _on_perfect_area_area_entered(area):
	if area.is_in_group("note"):
		perfect = true

func _on_perfect_area_area_exited(area):
	if area.is_in_group("note"):
		perfect = false

func _on_good_area_area_entered(area):
	if area.is_in_group("note"):
		good = true

func _on_good_area_area_exited(area):
	if area.is_in_group("note"):
		good = false

func _on_okay_area_area_entered(area):
	if area.is_in_group("note"):
		okay = true
		current_note = area

func _on_okay_area_area_exited(area):
	if area.is_in_group("note"):
		okay = false
		current_note = null

func _on_push_timer_timeout():
	frame = 0

func _on_perfect_area_pressed():
	_on_button_pressed()

func _on_good_area_pressed():
	_on_button_pressed()

func _on_okay_area_pressed():
	_on_button_pressed()

func _on_okay_area_2_pressed():
	_on_button_pressed()

func _on_good_area_2_pressed():
	_on_button_pressed()
