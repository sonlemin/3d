# Validation Report — 3d_game (The Mourning Watch, one-night game)

2026-11-19. Two reviewers read `DESIGN.md` and `EXPERIENCE.md` before they were marked final. Their full findings are in `review-rubric.md` and `review-accessibility.md`; this file records what was done about them. No HTML report was rendered.

## Verdicts

| Reviewer | Verdict | Critical | High | Medium | Low |
|---|---|---|---|---|---|
| Rubric walker | Usable contract, close to ready. Shape fit strong; the other seven categories adequate. | 0 | 2 | 14 | 23 |
| Accessibility | Screens sound; the night is where the promise slips for a player who cannot hear. | 0 | 7 | 19 | 9 |

## High findings

| Finding | Outcome |
|---|---|
| Rubric: "GDD impacts" incomplete | Fixed. Split into "changes a GDD statement" and "adds to the GDD" and completed. |
| Rubric: a lost night with no new hint is undefined | Decided (UX-41): the same hint is shown again. |
| A11y H1: the dead on the deck have no visual in the dark | Decided (UX-38): footsteps and bowing planks glow in Cues everywhere; cue lifetime stated. |
| A11y H2: the way into deaf play is hidden | Decided (UX-38): "I can't hear it", ring again, Cues everywhere offered. |
| A11y H3: the flame is a weak direction-finder | Partly addressed (UX-38): a shuttered lantern's seam glow still leans. Carrying height and minimum lean angle are left to the art pass. Not verified by play. |
| A11y H4: captions reach a deaf player late from wave 4 | Decided (UX-38): every cry called all night in Cues everywhere. |
| A11y H5: hands and forearm need light to be seen | Fixed: minimum brightness rule in both spines. |
| A11y H6: press-instead-of-hold worth adding | Decided (UX-39): Holds: Hold / Press once. |
| A11y H7: keyboard layout unaddressed | Fixed: keys bound by physical position, labelled by layout. Godot specifics to be confirmed by architecture. |

## Also fixed

Two places where the draft contradicted the decision log (Leave the bridge asks first; Tomas takes the swap); restored clauses for ten decisions; ledger line formats; hover equals chosen in both spines; a warm rule under the chosen item, because warm against ink is only 1.12:1; flicker limits; caption halo sizes and sizes as tokens; the two-line planning tray; key card conditions and a Signs group; the last plan kept after a lost night (UX-40); Brightness, Field of view and Mono sound settings (UX-39).

## Not addressed

- The remaining medium and low findings in both review files were not walked one by one. Those not listed above stand as written there.
- Optional caption backing and a "Reduce camera motion" setting were not taken up.
- Cues everywhere has not been played muted. EXPERIENCE.md, Accessibility Floor, asks for one muted test night before any deaf-playable claim.
- Without hearing, the hum, the tune and a window going out behind the warden remain hard to reach. Stated as a known gap.
- The reviews were of the documents only; nothing was run in Godot.
