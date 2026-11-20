## The one owner of engine state that outlives a screen (AD-51, AD-59). Nothing carries over
## between nights (AD-4), but the tree pause and the mouse mode are global, so they are set
## here and only here. Main calls enter_screen() at every screen change; the pause overlay calls
## set_paused(). Pause is not a screen change (AD-67): set_paused() resets nothing else.
## The bus values and the window join this script in epics 2 and 5.
class_name EngineGlobals
extends RefCounted

## What a screen needs from the mouse.
enum ScreenKind {
	MENU,          ## Pointed at: the mouse is visible.
	FIRST_PERSON,  ## Mouse look (the lesson, the night): the mouse is captured.
}


## Clears the tree pause and sets the mouse for the kind of screen being entered.
static func enter_screen(tree: SceneTree, kind: ScreenKind) -> void:
	tree.paused = false
	Input.mouse_mode = mouse_mode_for(kind)


static func set_paused(tree: SceneTree, on: bool) -> void:
	tree.paused = on


static func mouse_mode_for(kind: ScreenKind) -> Input.MouseMode:
	return Input.MOUSE_MODE_CAPTURED if kind == ScreenKind.FIRST_PERSON else Input.MOUSE_MODE_VISIBLE
