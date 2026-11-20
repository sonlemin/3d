## The game's screen text, in one place so that wording changes never touch a screen's code.
## Constants only. Epic 5 adds the title's entries, the key card and the settings rows.
class_name UiText
extends RefCounted

## The working title (the user folder does not follow it: it is pinned to `mourning_watch`).
const GAME_NAME: String = "The Mourning Watch"

## The start page when nothing was found wrong at start (AD-28).
const NO_SETUP_PROBLEMS: String = "No setup problems."
## Above the list when something was (AD-28: setup problems are shown on the title).
const SETUP_PROBLEMS_HEADING: String = "Setup problems found at start:"

## Printed names of the two mouse buttons the game binds (InputActions.key_name).
const MOUSE_LEFT: String = "Left mouse"
const MOUSE_RIGHT: String = "Right mouse"
