# warning-ignore-all:return_value_discarded
# ############################################################################ #
# Copyright © 2019-present Frédéric Maquin <fred@ephread.com>
# Licensed under the MIT License.
# See LICENSE in the project root for license information.
# ############################################################################ #

# Use test/performance/ink/generate_ipsuminious.py to generate the story before
# running this test. This test profiles how long it takes to create a story.

extends Node

# ############################################################################ #
# Imports
# ############################################################################ #

var ErrorType = preload("res://addons/inkgd/runtime/enums/error.gd").ErrorType
var InkGDProfiler = preload("res://examples/scenes/common/profiler.gd")


# ############################################################################ #
# Private Properties
# ############################################################################ #

var _profiler: InkGDProfiler = InkGDProfiler.new()
var _current_story_index: int = -1

var _creation_results: PoolStringArray = ["Created stories:"]
var _stories: Array = [
	"res://test/performance/ink/ipsuminious.1.ink.json",
	"res://test/performance/ink/ipsuminious.6.ink.json",
	"res://test/performance/ink/ipsuminious.12.ink.json"
]


# ############################################################################ #
# Node
# ############################################################################ #

onready var _created_label = $MarginContainer/CenterContainer/Label
onready var _loading_label = $LoadingAnimationPlayer/CenterContainer/VBoxContainer/Label
onready var _loading_animation_player = $LoadingAnimationPlayer
onready var _ink_player = $InkPlayer


# ############################################################################ #
# Lifecycle
# ############################################################################ #

func _ready():
	_ink_player.connect("loaded", self, "_loaded")
	_current_story_index = 0

	create_story()


# ############################################################################ #
# Signal Receivers
# ############################################################################ #

func _loaded(successfully: bool):
	var filename = _stories[_current_story_index].get_file()

	if !successfully:
		printerr("Could not create %s." % filename)
		return

	_profiler.stop()

	var text = "%s | %d ms." % [filename, _profiler.milliseconds_elaspsed]
	_creation_results.append("        • " + text)
	print(text)

	_current_story_index += 1

	if _current_story_index < _stories.size():
		create_story()
	else:
		end()


func create_story():
	if _current_story_index < 0 || _current_story_index >= _stories.size():
		return

	var filename = _stories[_current_story_index].get_file()
	_loading_label.text = "Loading \"%s\"…" % filename

	_profiler.start()
	_ink_player.ink_file = load(_stories[_current_story_index])
	_ink_player.create_story()

func end():
	_created_label.text = _creation_results.join("\n")
	_created_label.show()

	remove_child(_loading_animation_player)
	_loading_animation_player.queue_free()
	_loading_animation_player = null

	_ink_player.destroy()
