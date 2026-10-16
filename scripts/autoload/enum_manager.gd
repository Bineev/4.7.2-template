extends Node
## Global enum manager for the project.
##
## Single source of truth for all enums: states, types, and other
## enumerations. Loaded second in the Autoload list, after
## constant_manager, before data_manager and signal_manager.
##
## Autoload name: EnumManager
## File:         res://scripts/autoload/enum_manager.gd
##
## Structure:
## - Utility functions come first (fixed header), so new enums can be
##   appended at the bottom without touching code.
## - Enums follow below, flat list.
##
## Content rules:
## - All project enums live here, no exceptions for "locality".
## - No logging, no state — pure data and utilities.
## - New enums are added as real needs appear, not in advance.
##
## Naming:
## - Enum names in PascalCase (GameSection, PlayerState, EnemyType).
## - Enum values in SCREAMING_SNAKE_CASE (MAIN_MENU, PLAYING).
##
## Usage:
##   var section: EnumManager.GameSection = EnumManager.GameSection.MAIN_MENU
##   var name := EnumManager.get_enum_key_name(EnumManager.GameSection, section)

# ============================================================
# UTILITIES
# ============================================================

## Returns the key name of an enum by its integer value.
## Example:
##   EnumManager.get_enum_key_name(EnumManager.GameSection, 0) -> "MAIN_MENU"
##
## If the value is not found in the enum, pushes an error and returns "".
func get_enum_key_name(enum_dict: Dictionary, value: int) -> String:
	for key in enum_dict:
		if enum_dict[key] == value:
			return key

	push_error("EnumManager.get_enum_key_name: value %d not found in enum." % value)
	return ""


## Returns all key names of an enum as a typed Array[String].
## Example:
##   EnumManager.get_enum_keys(EnumManager.GameSection) -> ["MAIN_MENU", "LOBBY", "LEVEL"]
##
## If the enum is empty, returns an empty array.
func get_enum_keys(enum_dict: Dictionary) -> Array[String]:
	var result: Array[String] = []
	for key in enum_dict:
		result.append(key)
	return result


# ============================================================
# ENUMS
# ============================================================

# --- Game navigation ---

## Which section of the game the user is currently in.
## Navigation dimension, orthogonal to technical game state
## (paused / playing), which will be introduced separately later.
##
## - MAIN_MENU — main menu.
## - LOBBY     — level selection, character selection, etc.
## - LEVEL     — actual gameplay.
enum GameSection {
	MAIN_MENU,
	LOBBY,
	LEVEL,
}

# --- Audio ---

## Sound effect types. Keys for the sfx registry in data_manager.
## New sound types are added here as real needs appear.
##
## - UI_ACCEPT — UI confirmation sound.
enum SoundType {
	UI_ACCEPT,
}

## Music theme categories. Keys for the music registry in data_manager.
## Each category maps to an array of tracks (a playlist).
##
## - MENU_THEMES     — main menu music.
## - GAMEPLAY_THEMES — gameplay background music.
enum MusicThemes {
	MENU_THEMES,
	GAMEPLAY_THEMES,
}

# --- Units ---

## Unit class types. Keys for the unit registries in data_manager.
## New unit types are added here as real needs appear.
##
## - KNIGHT — melee, high health.
## - ROGUE  — agile, high attack.
## - MAGE   — ranged, low health, high attack.
enum UnitType {
	KNIGHT,
	ROGUE,
	MAGE,
}

# ============================================================
# FUTURE ENUMS
# ============================================================
# Examples for future use (uncomment / add as needed):
#
# enum GameState { BOOT, MENU, PLAYING, PAUSED, GAME_OVER }
# enum PlayerState { IDLE, RUN, JUMP, FALL, ATTACK }
# enum EnemyType { GOBLIN, ORC, DRAGON }
