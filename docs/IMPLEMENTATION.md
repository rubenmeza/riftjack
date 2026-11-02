# Riftjack — implementation plan

Working checklist for **GitHub Game Off 2026** (theme **SHIFT**), hosted on itch.io.
Design lives in [DESIGN.md](DESIGN.md); this file tracks what is left to build.

Legend: `[x]` done, `[ ]` to do. Keep items small enough to finish in one sitting.

## Jam rules (confirmed 2 Nov 2026 from https://itch.io/jam/game-off-2026)

- **Deadline:** 1 Dec 2026, **13:37 PST** (= 21:37 UTC; itch.io lists 21:37:00).
  Aim to submit by **29 Nov**; the last two days are buffer, not work time.
- **Voting:** entrants vote on each other's games after submissions close; voting
  ends 1 Jan 2027, 13:37 PST.
- **Theme:** SHIFT, interpretation is up to us.
- **Source:** public GitHub repository holding the game's source code.
- **Tools:** any language, engine or library.
- **Submit:** join the jam on itch.io (GitHub sign-in works), push to the public
  repo, then submit the game on itch.io.
- **Judged categories:** Overall, Gameplay, Graphics, Audio, Innovation, Theme Interpretation.
- **Not stated anywhere on the page:** team size, asset rules, AI-use policy,
  licence requirements, starting from existing code, web-build requirement, prizes.
  There is no rules or FAQ page, only Overview and a Community tab (112 threads,
  plus a community-run Discord). Search the Community tab for these before
  submitting; until then assume the safest reading: all work started during the
  jam, own or clearly licensed assets, credit everything.

What the categories mean for scope: Graphics and Audio are scored on their own, so
polish weeks are not optional, and the build must be playable in the browser
because voters will click through many entries.

## Done

- [x] Project scaffold (Godot 4.7, GDScript), headless tests, balance sim
- [x] Core rules: `Realm`, `Law`, `Card`, `Hand`, `Deck`, `RoundState`, `Fight`
- [x] Laws: Mirror, Rot3, Void
- [x] Shift cost: charges (start 2, cap 3), refund on unshifted win, forced-shift rounds
- [x] Placeholder UI for the core loop

## Open decisions

Resolve these early; each affects later work.

- [ ] **Soft ace:** keep hard ace = 1 (current) or add 1/11 with a defined B-side rule
- [ ] **Mid-hand shift:** allowed now, but the sim only covered shift at deal time. Re-sim or restrict
- [ ] **Deck:** infinite-style reshuffle per fight (current) vs. finite shoe that players can learn
- [ ] **`SHIFT_FORCES_DRAW` toggle:** try it if charges alone feel too weak
- [ ] **Win condition per fight:** "4 of 7 rounds" is a placeholder. Alternatives: score target, chips, HP
- [ ] **Run length:** 3 acts × N fights, and how long a full run takes (target 15–20 min)

## Week 1 — core feel (to 8 Nov)

Goal: one round produces one tense decision.

- [ ] Playtest by hand across all three laws; note when shift feels free or useless
- [ ] Tune `start_charges`, `max_charges`, `win_refund`, `forced_rounds`
- [ ] Settle the soft-ace and mid-hand-shift decisions above
- [ ] Explain a disabled Shift button (no charge / would bust / already used)
- [ ] Show the other realm's total clearly, and what a shift would do before committing
- [ ] Shift animation (screen wipe or palette swap) and a placeholder sound
- [ ] Extend `tests/run_tests.gd` for any rule change

## Week 2 — run structure (to 15 Nov)

Goal: a full run from first fight to final boss.

- [ ] Run state: current act/fight, charges carried or reset, relics owned
- [ ] Run map: 3 acts, each ending in a boss dealer
- [ ] Dealer roster: law, stand threshold and one special rule per dealer
- [ ] Boss rules: telegraphed forced shifts, a two-law boss (A → B → C cycle)
- [ ] Reward screen after each fight: pick 1 of 3 relics
- [ ] About 8 relics, e.g. first shift free each fight, refund +2, peek at the hole card,
      dealer stands on 16, one per-card shift per fight
- [ ] Game over / victory screens and restart
- [ ] Extend `tools/sim.gd` to cover relics and boss rules

## Week 3 — presentation (to 22 Nov)

Goal: it looks and sounds like the theme.

- [ ] Pixel art: card faces and backs, table, realm backgrounds, dealer portraits
- [ ] Per-realm palette and shader or tint, with a clear A/B visual language
- [ ] Law strip styled as part of the table, not debug text
- [ ] Audio: shift, hit, stand, win, lose; music per realm
- [ ] Font and UI theme pass (single Godot `Theme` resource)
- [ ] Screen shake / particles on shift and on boss rule triggers

## Week 4 — ship (to 29 Nov, buffer to 1 Dec)

Goal: someone who has never seen it can play it.

- [ ] Tutorial: scripted first fight that teaches the two values, Stand locking the realm, and Shift
- [ ] Balance pass using the sim plus real playtests
- [ ] Bug pass: restart mid-fight, rapid clicks, empty deck, window resize
- [ ] Exports: Web (HTML5), Linux, Windows; test each build
- [ ] itch.io page: description, controls, screenshots, GIF
- [ ] Repo README final: how to play, how to build, credits and asset licences
- [ ] Repo is public and contains the source (it is today); itch.io page links to it
- [ ] Re-read the jam's rules/FAQ for asset and AI-use policy (see "Not stated" above)
- [ ] Join the jam on itch.io, upload the Web build, submit by 29 Nov

## Definition of done (per task)

- Rules change → a test in `tests/run_tests.gd` covers it, and `godot --headless --path . -s tests/run_tests.gd` exits 0
- Balance-affecting change → `tools/sim.gd` re-run, results noted in `DESIGN.md`
- UI change → boots headless without errors: `godot --headless --path . --quit-after 30`

## Cut list (drop in this order if time runs short)

1. Windows/Linux builds (keep Web, the one voters will play)
2. Music per realm (keep one track; Audio is a judged category, so keep sound effects)
3. Two-law boss
4. Relics beyond the first 5
5. Dealer portraits (keep names and rules)
