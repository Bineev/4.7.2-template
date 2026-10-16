extends Node
## Global data manager for the project.
##
## Holds all project data in dictionaries, keyed by enums from enum_manager.
## Access is provided through typed getter functions — one per domain.
##
## Autoload name: DataManager
## File:         res://scripts/autoload/data_manager.gd
## Load order:   third, after constant_manager and enum_manager,
##               before audio_manager and signal_manager.
##
## Structure:
## - Domains are separated into sections with comment headers.
## - Each domain has:
##     * a dictionary of assets (keyed by enum),
##     * a typed getter function.
## - Registration happens in _ready() via _register_* helpers.
##
## Loading:
## Assets are declared with preload() inside dictionaries or _ready().
## Paths are literals, so preload works. Everything loads once at
## autoload initialization — no lazy loading, no is_X_loaded flags.
## If a path is broken, the error appears immediately at startup.
##
## Missing entries:
## If a type has no registered asset, the getter pushes an error
## and returns null (or an empty array for playlists).
## Only types with real files are registered.

# ============================================================
# SOUNDS
# ============================================================

## Sound effect registry: SoundType -> AudioStream.
var sounds: Dictionary = {
	EnumManager.SoundType.UI_ACCEPT: preload("res://audio/sfx/ui_accept.wav"),
}


## Returns the AudioStream for the given sound type.
## If the type is not registered, pushes an error and returns null.
func get_sound(type: EnumManager.SoundType) -> AudioStream:
	if not sounds.has(type):
		push_error("DataManager.get_sound: sound type '%s' is not registered."
			% EnumManager.get_enum_key_name(EnumManager.SoundType, type))
		return null

	var stream: AudioStream = sounds[type]
	return stream


# ============================================================
# MUSIC
# ============================================================

## Music registry: MusicThemes -> Array of AudioStream (playlist).
## Arrays are untyped here on purpose — AudioManager only needs
## to iterate and play them, element typing adds no value.
var music: Dictionary = {
	EnumManager.MusicThemes.MENU_THEMES: [
		preload("res://audio/music/menu_theme_1.ogg"),
		preload("res://audio/music/menu_theme_2.ogg"),
	],
	EnumManager.MusicThemes.GAMEPLAY_THEMES: [
		preload("res://audio/music/gameplay_theme_1.ogg"),
		preload("res://audio/music/gameplay_theme_2.ogg"),
	],
}


## Returns the playlist (Array of AudioStream) for the given music theme.
## If the theme is not registered, pushes an error and returns an empty array.
func get_music(theme: EnumManager.MusicThemes) -> Array:
	if not music.has(theme):
		push_error("DataManager.get_music: music theme '%s' is not registered."
			% EnumManager.get_enum_key_name(EnumManager.MusicThemes, theme))
		return []

	var playlist: Array = music[theme]
	return playlist


# ============================================================
# UNIT RESOURCES
# ============================================================

## Unit resource registry: UnitType -> UnitResource.
## Populated in _ready() via _register_unit().
var unit_resources: Dictionary = {}


## Returns the UnitResource for the given unit type.
## If the type is not registered, pushes an error and returns null.
func get_unit_resource(type: EnumManager.UnitType) -> UnitResource:
	if not unit_resources.has(type):
		push_error("DataManager.get_unit_resource: unit type '%s' is not registered."
			% EnumManager.get_enum_key_name(EnumManager.UnitType, type))
		return null

	var resource: UnitResource = unit_resources[type]
	return resource


# ============================================================
# UNIT ASSETS
# ============================================================

## Unit asset registry: UnitType -> Texture2D.
## Populated in _ready() via _register_unit().
var unit_assets: Dictionary = {}


## Returns the Texture2D asset for the given unit type.
## If the type is not registered, pushes an error and returns null.
func get_unit_asset(type: EnumManager.UnitType) -> Texture2D:
	if not unit_assets.has(type):
		push_error("DataManager.get_unit_asset: unit type '%s' is not registered."
			% EnumManager.get_enum_key_name(EnumManager.UnitType, type))
		return null

	var asset: Texture2D = unit_assets[type]
	return asset


# ============================================================
# REGISTRATION
# ============================================================

func _ready() -> void:
	_register_unit(
		EnumManager.UnitType.KNIGHT,
		preload("res://resources/units/knight.tres"),
		preload("res://img/units/knight.png")
	)


## Registers a unit: links its resource and asset under the same type key.
## Single point of registration — add new units by calling this in _ready().
func _register_unit(type: EnumManager.UnitType, resource: UnitResource, asset: Texture2D) -> void:
	if unit_resources.has(type):
		push_error("DataManager._register_unit: unit type '%s' is already registered."
			% EnumManager.get_enum_key_name(EnumManager.UnitType, type))
		return

	unit_resources[type] = resource
	unit_assets[type] = asset
