# Contributing

## Commits

[Conventional Commits](https://www.conventionalcommits.org/), short and imperative.

```
<type>(<scope>): <subject, max ~50 chars, no trailing period>

<optional body: why, not what>
```

- **Types:** `feat`, `fix`, `refactor`, `test`, `docs`, `chore`, `perf`, `style`
- **Scopes:** `core`, `ui`, `audio`, `art`, `sim`, `docs`, `build`
- Example: `feat(core): add shift charge economy`
- One logical change per commit. Rule changes include their test.
- No agent or tool trailers (`Co-Authored-By`, "Generated with…") and no agent or
  model names in commits, PRs or docs.

## Branches

- `main` stays playable.
- Work on short-lived branches named `<type>/<short-slug>`, e.g. `feat/run-map`.
- Rebase onto `origin/main` before pushing.

## Checks before pushing

```sh
godot --headless --path . --import
godot --headless --path . -s tests/run_tests.gd   # must exit 0
godot --headless --path . --quit-after 30         # main scene boots, no errors
```

Balance-affecting changes: also run `tools/sim.gd` and note the result in
[docs/DESIGN.md](docs/DESIGN.md).
