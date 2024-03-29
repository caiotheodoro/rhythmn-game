extends AudioStreamPlayer

@export var bpm := 100
@export var measures := 4

# Tracking the beat and song position
var song_position = 0.0
var song_position_in_beats = 1
var sec_per_beat = 60.0 / bpm
var last_reported_beat = 0
var beats_before_start = 0
var measure = 1

# Determine how close to the beat an event is
var closest = 0
var time_off_beat = 0.0
var total_length = 0
signal Beat(pos)
signal Measure(pos)

func _ready():
	sec_per_beat = 60.0 / bpm

func _physics_process(delta):
	if playing:
		song_position = get_playback_position() + AudioServer.get_time_since_last_mix()
		song_position -= AudioServer.get_output_latency()
		song_position_in_beats = int(floor(song_position / sec_per_beat)) + beats_before_start
		_report_beat()

func _report_beat():
	if last_reported_beat < song_position_in_beats:
		if measure > measures:
			measure = 1
		emit_signal("Beat", song_position_in_beats)
		emit_signal("Measure", measure)
		last_reported_beat = song_position_in_beats
		measure += 1

func play_with_beat_offset(num):
	beats_before_start = num
	$StartTimer.wait_time = sec_per_beat
	$StartTimer.start()
	
func closest_beat(nth):
	closest = int(round((song_position / sec_per_beat) / nth) * nth)
	time_off_beat = abs(closest * sec_per_beat - song_position)
	return Vector2(closest, time_off_beat)

func play_from_beat(beat, offset):
	play()
	seek(beat * sec_per_beat)
	beats_before_start = offset
	measure = beat % measures

func _on_start_timer_timeout():
	song_position_in_beats += 1
	if song_position_in_beats < beats_before_start - 1:
		$StartTimer.start()
	elif song_position_in_beats == beats_before_start - 1:
		$StartTimer.wait_time = $StartTimer.wait_time - (AudioServer.get_time_to_next_mix() + AudioServer.get_output_latency())
		$StartTimer.start()
	else:
		play()
		$StartTimer.stop()
	_report_beat()

func play_music(music: String):
	var player = AudioStreamPlayer.new()
	player.stream = load(music)
	
	player.play()
	total_length = player.stream.get_length()
	
func change_speed(speed: float):
	sec_per_beat = 60.0 / speed
	$StartTimer.wait_time = sec_per_beat
	$StartTimer.start()
	
func change_speed_ingame(speed: float):
	sec_per_beat = 60.0 / speed
	
func get_remaining_time():
	var remaining_seconds = total_length - song_position
	var minutes = int(remaining_seconds / 60)
	var seconds = int(int(remaining_seconds) % 60)
	return str(minutes) + ":" + str(seconds).pad_zeros(2)

func has_ended():
	var remaining_seconds = total_length - song_position
	return remaining_seconds <=0


func stop_music():
	stream_paused = true
	stop()
