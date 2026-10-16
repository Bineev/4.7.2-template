extends Node
## Global constants manager for the project.
##
## Stores values that are identical across the whole project and do not
## change at runtime. Loaded first in the Autoload list, because other
## managers (e.g. enum_manager, data_manager, signal_manager) may read
## values from here during initialization.
##
## Autoload name: ConstantManager
## File:         res://scripts/autoload/constant_manager.gd
##
## Content rules:
## - Numbers and booleans only. Text constants must not live here.
## - Naming uses domain prefixes (SYS_, B_, etc.) for file navigation.
## - New domains are added as real needs appear, not in advance.
##
## Domains:
## - SYS_ — system constants (technical flags, engine behavior).
## - B_   — balance constants (gameplay values: speed, damage, ammo).

# --- SYS: system ---

## Main debug/release switch.
## true  — debug mode: signal_manager maintains a subscriber registry
##         and logs emissions.
## false — release mode: debug logic is disabled, no overhead.
##
## WARNING: before building a release, switch this to false manually.
##
## Related systems:
## - constant_manager.SYS_IS_DEBUG — this flag.
## - signal_manager.subscribe() — reads the flag on every subscription.
## - signal_manager.emit() — reads the flag on every emission.
const SYS_IS_DEBUG := true

# --- B: balance ---

## Sound effects: minimum delay between two identical sounds, in milliseconds.
## Prevents the same sound from stacking when many events fire at once.
const B_SOUND_DELAY_MS := 50

## Sound effects: maximum number of concurrently playing sound players.
## When exceeded, the oldest sound is stopped.
const B_SOUND_MAX_CONCURRENT := 16

# Examples for future use (uncomment as needed):
#
# const B_PLAYER_START_SPEED := 200.0
# const B_PLAYER_MAX_HEALTH := 100
# const B_ENEMY_BASE_DAMAGE := 10
