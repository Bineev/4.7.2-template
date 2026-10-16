extends Node
class_name Main

func _ready() -> void:
	print("=== 1. Playlists loaded ===")
	var menu_tracks := DataManager.get_music(EnumManager.MusicThemes.MENU_THEMES)
	var gameplay_tracks := DataManager.get_music(EnumManager.MusicThemes.GAMEPLAY_THEMES)
	print("Menu tracks: ", menu_tracks.size())
	print("Gameplay tracks: ", gameplay_tracks.size())

	print("")
	print("=== 2. Start menu music ===")
	AudioManager.play_menu_music()
	print("Menu music started. Listen...")

	await get_tree().create_timer(3.0).timeout

	print("")
	print("=== 3. Switch to gameplay playlist (with fade) ===")
	AudioManager.start_gameplay_playlist(1.5)
	print("Switching to gameplay. Listen...")

	await get_tree().create_timer(3.0).timeout

	print("")
	print("=== 4. UI sound ===")
	AudioManager.play_ui(DataManager.get_sound(EnumManager.SoundType.UI_ACCEPT))
	print("UI sound played.")

	await get_tree().create_timer(1.0).timeout

	print("")
	print("=== 5. Gameplay SFX (with pitch randomization) ===")
	AudioManager.play(DataManager.get_sound(EnumManager.SoundType.UI_ACCEPT))
	print("SFX played (should sound slightly different pitch).")

	await get_tree().create_timer(1.0).timeout

	print("")
	print("=== 6. SFX cooldown test ===")
	print("Firing same SFX 5 times rapidly — only 1 should play.")
	for i in range(5):
		AudioManager.play(DataManager.get_sound(EnumManager.SoundType.UI_ACCEPT))
	print("Done. Only the first should be audible.")

	await get_tree().create_timer(2.0).timeout

	print("")
	print("=== 7. Unknown theme test ===")
	var bad := DataManager.get_music(99)
	print("Unknown theme result: ", bad)

	print("")
	print("=== Test complete ===")
