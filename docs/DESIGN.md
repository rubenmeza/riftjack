# Riftjack — design

GitHub Game Off 2026 (itch.io), theme **SHIFT**. Deadline: 1 Dec 2026, 13:37 PST.
Solo, Godot 4.7, GDScript. Rules and judging categories: [IMPLEMENTATION.md](IMPLEMENTATION.md).

Blackjack where every card has two values — one per realm. You can shift the
whole table between realms, but it costs a scarce charge.

## Round

1. Deal two cards each; the dealer's hole card is hidden. Every card shows its
   Realm A and Realm B value. The table starts in A (or in B on a forced round).
2. Player acts: **Hit**, **Stand**, or **Shift**.
3. **Stand locks the realm.** The dealer reveals the hole card and draws to 17
   *in the locked realm*. Everything resolves there.
4. A bust in the active realm ends the round immediately, so Shift must be
   pre-emptive. Shift is refused if it would put you over 21.

Because the dealer's hand is scored in the same realm, shifting never favours the
player for free: you commit to a realm without seeing the hole card.

Hard values only in v1: ace = 1, faces = 10, no soft ace.

## Reality laws

Each dealer has one law mapping a card's A value `v` (1..10) to its B value.
The law is shown on screen as a strip (`1→10 2→9 …`).

| Law | B value | Notes |
|---|---|---|
| Mirror | `11 − v` | High/low swap. A and B totals are anti-correlated. Act 1. |
| Rot3 | `((v + 2) % 10) + 1` | +3 wrapping. Hardest to read, biggest swing. |
| Void | `10 → 0`, rest unchanged | Faces are worthless in B; free hitting. |

Ideas: boss with two laws (A → B → C cycle), suit-based law (red mirrors, black
stays) for a per-card shift.

## Shift cost

Free world choice is worth roughly +6 to +7.5 points of win rate (simulated), so
the cost has to be real.

- **Charges:** start 2, cap 3. Shift costs 1; max 1 shift per round.
- **Refund:** winning a round *without* shifting gives +1 charge.
- **Forced shifts:** bosses flip the table to B on telegraphed rounds (3 and 6 by
  default). Costs nothing and doesn't count as a player shift.
- **Playtest toggle (not implemented):** shifting also forces a draw.

Tuning knobs live on `Fight`: `start_charges`, `max_charges`, `win_refund`,
`rounds_total`, `wins_needed`, `forced_rounds`; plus `RoundState.DEALER_STAND`.

## Simulation (hard aces, infinite deck, world picked at deal)

| Law | A only | B only | Pick best world | Shift worth ≥3% | Gain per useful shift |
|---|---|---|---|---|---|
| Mirror | .503 | .487 | .564 | 44% of rounds | +13.8 pts |
| Rot3 | .506 | .485 | .578 | 46% | +15.2 pts |
| Void | .501 | .489 | .567 | 47% | +13.6 pts |

Caveats: shift tested only at deal time, simple stand thresholds, infinite deck.
`tools/sim.gd` re-checks A-only vs B-only balance against the real game code.

## Plan

1. Core loop + shift cost; playtest until a round has one tense decision. *(scaffolded)*
2. Run structure: 3 dealers, rewards, ~8 modifiers (relics).
3. Art, audio, shift juice.
4. Tutorial, balance, submit before the deadline.

Task-level checklist, open decisions and cut list: [IMPLEMENTATION.md](IMPLEMENTATION.md).


## Week 1 decisions and validation (14 Nov 2026)

Keep hard aces: A is always 1, B uses the law (Mirror 10, Rot3 4,
Void 1). Keep one voluntary shift at any time before standing or busting,
including after a hit. The preview exposes only the dealer upcard, never the
hole card. A shift also forfeits the unshifted-win refund.

Retain start 2, cap 3, refund 1, forced rounds 3 and 6 after comparing six
configurations. The first-deal initialization now honors configured
`start_charges`; previously changing that knob after construction did nothing.

Godot 4.7.2, `tools/sim.gd`: seed 7, 10,000 fresh-deck rounds per law/realm,
hit below 16, push worth half a win. Observed A/B scores: Mirror .454/.454,
Rot3 .455/.441, Void .459/.448. These are smoke-test scores, not the
earlier best-world estimates above.

Fight experiment: seed 71 restarted per configuration, 1,000 fights per row,
real charge accounting and reshuffles. Policy shifts when legal if the other
total is at least 16 and greater than the current total; otherwise hits below
16 and stands. It uses no hole-card information. Configuration columns below
vary one setting from the retained defaults.

| Law | Default | Start 1 | Start 3 | Cap 2 | Refund 0 | No forced rounds |
|---|---:|---:|---:|---:|---:|---:|
| Mirror | 416 | 401 | 422 | 410 | 397 | 397 |
| Rot3 | 348 | 346 | 348 | 345 | 336 | 335 |
| Void | 352 | 352 | 352 | 352 | 352 | 317 |

Values are fights won out of 1,000, not round win percentages. Default
mid-hand shifts: Mirror 1,050 of 1,797 shifts; Rot3 819 of 1,624;
Void 404 of 862. This verifies the policy exercises mid-hand decisions.
Small differences are not evidence of statistical superiority; paths consume
different draws after decisions diverge. The defaults retain room to save a
charge without eliminating the refund incentive. No forced-draw rule added.

Void needs human attention: B cannot increase a hand's total, so this policy
only shifts back from forced B rounds. Its identical budget results do not
show that shifting into B is useless; hitting safely in B is outside this
policy's strategy. Mirror can turn a weak hand into a stand; Rot3 demands
reading individual mappings. These are rule observations, not human feedback.

Automated UI smoke exercises all three laws, shift previews, palette completion,
disabled reasons, standing and advancing. Human feel, visual layout and audible
sound quality still need an actual play session. The generated mono PCM shift
chirp is original project audio; no third-party asset licence is required.
