extends Node
## Global audio manager for the project.
##
## Handles all sound playback: gameplay SFX, UI sounds, and music.
## Assets come from data_manager, playback rules from constant_manager.
##
## Autoload name: AudioManager
## File:         res://scripts/autoload/audio_manager.gd
## Load order:   fourth, after constant_manager, enum_manager, data_manager.
##
## Responsibilities:
## - Play gameplay SFX with cooldown and concurrency limit.
## - Play UI sounds without limits (rare and never stack).
## - Play music: single menu theme or shuffled gameplay playlist.
##
## Not responsible for:
## - Holding assets (data_manager does that).
## - Autostarting music on load (game_manager will trigger it).
## - Local 2D sounds (not needed yet).

# ============================================================
# STATE
# ============================================================

## Current music player. Created and destroyed as tracks change.
var _music_player: AudioStreamPlayer

## Active SFX players, tracked for the concurrency limit (FIFO).
var _active_sfx: Array[AudioStreamPlayer] = []

## Remaining tracks in the current gameplay playlist (shuffled).
var _remaining_tracks: Array = []

## True while the gameplay playlist is active (vs. menu or silence).
var _is_in_gameplay: bool = false

## Timestamps of the last play time per stream instance, for cooldown.
var _sound_cooldowns: Dictionary = {}

# ============================================================
# UI SOUNDS
# ============================================================

## Plays a UI sound. No cooldown, no concurrency limit, no pitch randomization.
## UI sounds are rare and should always play.
func play_ui(stream: AudioStream) -> void:
	if stream == null:
		return

	var player := AudioStreamPlayer.new()
	player.process_mode = Node.PROCESS_MODE_ALWAYS
	player.bus = "SFX"
	player.stream = stream
	player.volume_db = -10
	player.finished.connect(player.queue_free)
	add_child(player)
	player.play()


# ============================================================
# GAMEPLAY SFX
# ============================================================

## Plays a gameplay SFX.
## Applies cooldown against identical sounds, enforces the concurrency limit,
## and randomizes pitch to avoid mechanical repetition.
func play(stream: AudioStream) -> void:
	if stream == null:
		return

	# Cooldown: ignore the same sound if it played too recently.
	var now := Time.get_ticks_msec()
	var stream_id := stream.get_instance_id()
	if _sound_cooldowns.has(stream_id):
		if now - _sound_cooldowns[stream_id] < ConstantManager.B_SOUND_DELAY_MS:
			return
	_sound_cooldowns[stream_id] = now

	# Concurrency limit: stop the oldest player if we are at capacity.
	if _active_sfx.size() >= ConstantManager.B_SOUND_MAX_CONCURRENT:
		var oldest: AudioStreamPlayer = _active_sfx.pop_front()
		if is_instance_valid(oldest):
			oldest.queue_free()

	var player := AudioStreamPlayer.new()
	player.process_mode = Node.PROCESS_MODE_ALWAYS
	player.bus = "SFX"
	player.stream = stream
	player.volume_db = -20
	player.pitch_scale = randf_range(0.92, 1.08)
	player.finished.connect(_on_sfx_finished.bind(player))
	add_child(player)
	_active_sfx.append(player)
	player.play()


## Removes a finished SFX player from the active list and frees it.
func _on_sfx_finished(player: AudioStreamPlayer) -> void:
	_active_sfx.erase(player)
	if is_instance_valid(player):
		player.queue_free()


# ============================================================
# MUSIC — MENU
# ============================================================

## Starts menu music: a random track from the menu playlist.
## Stops any currently playing music first.
func play_menu_music() -> void:
	_is_in_gameplay = false
	_stop_music_player()

	var playlist := DataManager.get_music(EnumManager.MusicThemes.MENU_THEMES)
	if playlist.is_empty():
		push_warning("AudioManager.play_menu_music: menu playlist is empty.")
		return

	var track: AudioStream = playlist.pick_random()
	_create_music_player(track, true)


# ============================================================
# MUSIC — GAMEPLAY
# ============================================================

## Starts the gameplay playlist. If music is already playing,
## fades it out first, then starts the next random track.
func start_gameplay_playlist(fade_duration: float = 1.0) -> void:
	_is_in_gameplay = true
	_remaining_tracks.clear()

	if is_instance_valid(_music_player) and _music_player.playing:
		var tween := create_tween()
		tween.tween_property(_music_player, "volume_db", -80.0, fade_duration)
		tween.finished.connect(func() -> void:
			_stop_music_player()
			_play_next_random_track()
		)
	else:
		_play_next_random_track()


## Plays the next random track from the gameplay playlist.
## Reshuffles when the queue is exhausted.
func _play_next_random_track() -> void:
	if not _is_in_gameplay:
		return

	var playlist := DataManager.get_music(EnumManager.MusicThemes.GAMEPLAY_THEMES)
	if playlist.is_empty():
		push_warning("AudioManager._play_next_random_track: gameplay playlist is empty.")
		return

	if _remaining_tracks.is_empty():
		_remaining_tracks = playlist.duplicate()
		_remaining_tracks.shuffle()

	var next_track: AudioStream = _remaining_tracks.pop_front()
	_create_music_player(next_track, false)

	# Fallback timer: advance to the next track when this one physically ends,
	# even if the "finished" signal does not fire.
	var track_length := next_track.get_length()
	get_tree().create_timer(track_length, false).timeout.connect(func() -> void:
		if _is_in_gameplay and is_instance_valid(_music_player) and _music_player.stream == next_track:
			_play_next_random_track()
	)


# ============================================================
# MUSIC — INTERNAL
# ============================================================

## Creates and starts a music player for the given track.
## loop — if true, the track restarts when finished (menu music).
##        If false, playback stops and the caller handles the next track.
func _create_music_player(track: AudioStream, loop: bool) -> void:
	_music_player = AudioStreamPlayer.new()
	_music_player.stream = track
	_music_player.process_mode = Node.PROCESS_MODE_ALWAYS
	_music_player.bus = "Music"
	_music_player.volume_db = -15

	if loop:
		_music_player.finished.connect(_music_player.play)

	add_child(_music_player)
	_music_player.play()


## Stops and frees the current music player, if any.
func _stop_music_player() -> void:
	if is_instance_valid(_music_player):
		_music_player.stop()
		_music_player.queue_free()
	_music_player = null


# ============================================================
# LIFECYCLE
# ============================================================

func _ready() -> void:
	# Periodically clear cooldowns so the dictionary does not grow forever.
	var timer := Timer.new()
	timer.wait_time = 30.0
	timer.autostart = true
	timer.process_mode = Node.PROCESS_MODE_ALWAYS
	timer.timeout.connect(func() -> void: _sound_cooldowns.clear())
	add_child(timer)

	# Music is NOT started here on purpose.
	# game_manager will call play_menu_music() when entering MAIN_MENU.
