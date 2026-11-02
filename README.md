# Riftjack

Blackjack across two realities. Every card has two values; shift the table
between realms, but charges are scarce. Made for GitHub Game Off 2026
(theme: **SHIFT**) with Godot 4.7.

Design notes: [docs/DESIGN.md](docs/DESIGN.md)  
Implementation checklist: [docs/IMPLEMENTATION.md](docs/IMPLEMENTATION.md)

## Run

```sh
godot --path .            # play
godot --headless --path . -s tests/run_tests.gd   # rule tests
godot --headless --path . -s tools/sim.gd         # balance smoke test
```

First time (or after adding a `class_name`), import once so global classes
register: `godot --headless --path . --import`.

## Layout

```
scripts/core/   rules: Realm, Law, Card, Hand, Deck, RoundState, Fight
scripts/ui/     placeholder UI
scenes/         main.tscn
tests/          headless rule tests
tools/          balance sim
docs/           design notes
```
