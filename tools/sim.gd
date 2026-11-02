extends SceneTree
## Balance smoke test using the real game code: win rate of a fixed policy
## (hit below 16) when the whole round is played in realm A vs. realm B.
##   godot --headless --path . -s tools/sim.gd
## Neither world should be dominant; if one is, retune the law.

const ROUNDS := 10000
const HIT_BELOW := 16


func _initialize() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 7
	for law in Law.all():
		var line := "%-8s" % law.title
		for start in [Realm.A, Realm.B]:
			var score := 0.0
			for i in ROUNDS:
				var r := RoundState.new(law, Deck.new(rng), start == Realm.B)
				while r.phase == RoundState.Phase.PLAYER and r.player_total() < HIT_BELOW:
					r.hit()
				if r.phase == RoundState.Phase.PLAYER:
					r.stand()
				match r.outcome:
					RoundState.Outcome.WIN: score += 1.0
					RoundState.Outcome.PUSH: score += 0.5
			line += "   %s-only %.3f" % [Realm.name_of(start), score / ROUNDS]
		print(line)
	quit()
