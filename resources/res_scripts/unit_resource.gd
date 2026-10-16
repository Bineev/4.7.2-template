extends Resource
class_name UnitResource
## Data container for a unit type.
##
## File: res://resources/res_scripts/unit_resource.gd
##
## Stored as .tres files in res://resources/units/.
## Loaded and registered by data_manager.
##
## Fields are edited via the Godot inspector when creating .tres files.
## The unit_type field links the resource to the corresponding enum key
## in enum_manager.UnitType, which data_manager uses as a dictionary key.

## Unit class type. Matches a key in EnumManager.UnitType.
@export var unit_type: EnumManager.UnitType = EnumManager.UnitType.KNIGHT

## Display name of the unit.
@export var unit_name: String = ""

## Flavor or gameplay description.
@export_multiline var description: String = ""

## Base health points.
@export var health: int = 100

## Base attack value.
@export var attack: int = 10
