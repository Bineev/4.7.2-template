extends Node
## Global signal bus for the project.
##
## Autoload name: SignalManager
## File:         res://scripts/autoload/signal_manager.gd
##
## Purpose:
## All game signals are declared here and accessible from anywhere in the code
## without direct dependencies between systems.
##
## Signal naming:
## Flat list with domain prefixes (game_, ui_, sys_, etc.).
## Prefixes are for search and grouping, not for structure.
##
## Debug mode:
## Controlled by constant_manager.SYS_IS_DEBUG.
## - subscribe() in debug mode maintains a text registry of subscribers.
## - emit() in debug mode logs the subscriber list before emitting
##   and raises a warning if there are no subscribers.
## In release mode both wrappers degrade to native connect/emit.
##
## Registry:
## Dictionary[String, Array[String]] — text only, no object references.
## Entry format: "ClassName.method_name".
## This is a static analysis system: it reflects who subscribed,
## and does not track node lifecycle. Duplicates are not created.

# ============================================================
# INTERNAL STATE
# ============================================================

## Subscriber registry. Populated only in debug mode.
## Key — signal name, value — array of "ClassName.method" identifiers.
var _subscribers: Dictionary = {}

# ============================================================
# PUBLIC METHODS
# ============================================================

## Wrapper around native connect.
## Passes the Callable as-is (including bind), and in debug mode
## records the subscriber's text identifier in the registry.
##
## If the subscription already exists — repeated call does nothing
## (neither native connect nor registry write).
##
## signal_name — signal name (e.g. "game_quit_requested").
## callable    — handler method, including bind(...).
func subscribe(signal_name: String, callable: Callable) -> void:
	if not has_signal(signal_name):
		push_error("SignalManager.subscribe: signal '%s' is not declared." % signal_name)
		return

	# Native subscription — only if not already connected.
	var sig: Signal = get(signal_name)
	if not sig.is_connected(callable):
		sig.connect(callable)
	else:
		return

	# Debug registry write — only in debug mode.
	if not ConstantManager.SYS_IS_DEBUG:
		return

	var entry := _describe_callable(callable)
	if entry.is_empty():
		return

	if not _subscribers.has(signal_name):
		_subscribers[signal_name] = []

	var list: Array = _subscribers[signal_name]
	if not list.has(entry):
		list.append(entry)


## Wrapper around native emit.
## In debug mode logs subscribers before emitting.
## If there are no subscribers — prints a prominent warning.
##
## signal_name — signal name.
## args        — signal arguments (if any).
func emit(signal_name: String, ...args) -> void:
	if not has_signal(signal_name):
		push_error("SignalManager.emit: signal '%s' is not declared." % signal_name)
		return

	if ConstantManager.SYS_IS_DEBUG:
		_log_emit(signal_name)

	get(signal_name).emit.callv(args)


## Manually prints the subscriber list of a signal to the console.
## Works regardless of SYS_IS_DEBUG — this is a debug tool
## that is called intentionally.
func print_subscribers(signal_name: String) -> void:
	if not has_signal(signal_name):
		push_error("SignalManager.print_subscribers: signal '%s' is not declared." % signal_name)
		return

	print("--- Subscribers of signal '%s' ---" % signal_name)
	if not _subscribers.has(signal_name) or _subscribers[signal_name].is_empty():
		print("  (none)")
		return

	for entry in _subscribers[signal_name]:
		print("  %s" % entry)


# ============================================================
# INTERNAL METHODS
# ============================================================

## Extracts a text identifier of the subscriber from a Callable.
## Primary format: "ClassName.method".
## Fallback if the script has no class_name: node name or script path.
func _describe_callable(callable: Callable) -> String:
	var obj: Object = callable.get_object()
	if obj == null:
		# Lambda or detached Callable — skip.
		return ""

	var method_name := callable.get_method()
	var class_name_str := _get_class_name(obj)

	if class_name_str.is_empty():
		return method_name

	return "%s.%s" % [class_name_str, method_name]


## Tries to get the class name of an object.
## First via script's class_name, then via node name, then via script path.
func _get_class_name(obj: Object) -> String:
	var script: Script = obj.get_script()
	if script != null:
		var global_name := script.get_global_name()
		if not global_name.is_empty():
			return global_name

	# Fallback 1: node name.
	if obj is Node:
		var node_name := (obj as Node).name
		if not node_name.is_empty():
			return str(node_name)

	# Fallback 2: script path.
	if script != null:
		return script.resource_path.get_file().get_basename()

	return ""


## Logs a signal emission: subscriber list or a warning if none.
func _log_emit(signal_name: String) -> void:
	var list: Array = _subscribers.get(signal_name, [])

	if list.is_empty():
		print("!!!!! SignalManager: signal '%s' has no subscribers !!!!!" % signal_name)
		return

	print("SignalManager: emit '%s' -> %s" % [signal_name, ", ".join(list)])


# ============================================================
# SIGNALS
# ============================================================

# --- game: game loop ---

## Request to quit the game.
## Emitted when the player initiates quit (window close, "Quit" button).
## Listeners may intercept the event: save progress, show
## confirmation, cancel the quit.
signal game_quit_requested()

# --- ui: interface ---
# (to be added as needed)

# --- sys: system ---
# (to be added as needed)
