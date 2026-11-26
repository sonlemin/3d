---
name: screens-must-read-on-sonlm-laptop
description: "DESIGN.md's text sizes and planning colours were too small and too dim on Sonlm's laptop; for a choice about how a screen looks, render the options and publish them as a page"
metadata:
  type: feedback
---

On 2026-11-27 Sonlm ran story 1.7's read-out (built exactly to `DESIGN.md`) with the window filling the laptop's screen and found every part hard to read: section numbers, strengths, planks and the end words, "both" too small and too dim. Shown three versions rendered at 1080p, Sonlm chose the brighter and larger one: strengths 72 px (not 48), labels 40 px (not 28), planks `#8d8982`, rails `#ddd6c8`, labels in `ink`, heavier lines. The laptop's screen size and resolution are not recorded.

**Why:** `DESIGN.md` was written before anything was seen on Sonlm's screen; its `label` floor of 28 px and its `muted` and `dim` colours did not survive the first look. DW-54 tracks the UX update.

**How to apply:**
- For any new screen (epic 5), do not assume `DESIGN.md`'s sizes and dim colours read. Start from what Sonlm chose for the read-out (`watch_theme.gd` says where it differs) and expect to show it.
- When a choice is about how something looks, do not ask in words. Render the options (scratch copies of `game/`, captured at 1920×1080), publish them on one private Artifact page with a click-to-full-screen on each picture, and put the choice in the option window with the link. Sonlm opened the page on the laptop and picked from it on 2026-11-27. My reading: this worked; Sonlm did not comment on the method itself.
- A choice made from pictures is not a check in the game: list it as NOT verified until Sonlm runs it.

Related: [[recommended-option-is-the-decision]], [[explain-purpose-before-options]], [[end-of-story-chores-automatic]].
