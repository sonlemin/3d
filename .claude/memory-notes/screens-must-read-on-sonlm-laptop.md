---
name: screens-must-read-on-sonlm-laptop
description: "DESIGN.md's text sizes and planning colours were too small and too dim on Sonlm's laptop; for a choice about how a screen looks, render the options and publish them as a page"
metadata:
  node_type: memory
  type: feedback
  originSessionId: 5b516bf1-65ea-428d-9af6-d975e909dbd2
  modified: 2026-11-27T17:56:13.973Z
---

On 2026-11-27 Sonlm ran story 1.7's read-out (built exactly to `DESIGN.md`) with the window filling the laptop's screen and found every part hard to read: section numbers, strengths, planks and the end words, "both" too small and too dim. Shown three versions rendered at 1080p, Sonlm chose the brighter and larger one: strengths 72 px (not 48), labels 40 px (not 28), planks `#8d8982`, rails `#ddd6c8`, labels in `ink`, heavier lines. The laptop's screen is 13 to 14 inch (Sonlm, epic 1 retrospective, 2026-11-27) at 1920×1080 (Sonlm, 2026-11-27), so a 1080p capture is the laptop's own pixels. On 2026-11-28, shown five screens at three scales rendered in Godot, Sonlm chose B for every screen: floor 42 px, body 42, value 48, heading 60, title 108, number 72, all text `ink` or brighter (UX-42, UX-43; `DESIGN.md` now says so).

**Why:** `DESIGN.md` was written before anything was seen on Sonlm's screen; its `label` floor of 28 px and its `muted` and `dim` colours did not survive the first look.

**How to apply:**
- For any new screen (epic 5), build to `DESIGN.md`'s scale B, measure it at 1080p with its real text (the ledger and the key card are near full), and expect to show it.
- When a choice is about how something looks, do not ask in words. Render the options (scratch copies of `game/`, captured at 1920×1080), publish them on one private Artifact page with a click-to-full-screen on each picture, and put the choice in the option window with the link. Sonlm opened the page on the laptop and picked from it on 2026-11-27. My reading: this worked; Sonlm did not comment on the method itself.
- A choice made from pictures is not a check in the game: list it as NOT verified until Sonlm runs it.

Related: [[recommended-option-is-the-decision]], [[explain-purpose-before-options]], [[end-of-story-chores-automatic]].
