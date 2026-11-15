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
	sim_fights()
	quit()


# Compare charge budgets with a visible-information policy. It can shift after hits.
func sim_fights() -> void:
	for law in Law.all():
		for tuning in [[1, 3, 1, true], [2, 3, 1, true], [3, 3, 1, true], [2, 2, 1, true], [2, 3, 0, true], [2, 3, 1, false]]:
			var rng := RandomNumberGenerator.new()
			rng.seed = 71
			var won := 0
			var shifts := 0
			var late_shifts := 0
			var rounds := 0
			for i in 1000:
				var f := Fight.new(law, Deck.new(rng))
				f.start_charges = tuning[0]
				f.max_charges = tuning[1]
				f.win_refund = tuning[2]
				if not tuning[3]:
					f.forced_rounds = []
				while f.status() == Fight.Status.ACTIVE:
					var r := f.start_round()
					rounds += 1
					while r.phase == RoundState.Phase.PLAYER:
						var other := r.player.total(law, Realm.flip(r.realm))
						if f.can_shift() and other >= HIT_BELOW and other > r.player_total():
							if r.player.cards.size() > 2:
								late_shifts += 1
							f.shift()
							shifts += 1
						if r.player_total() < HIT_BELOW:
							f.hit()
						else:
							f.stand()
				if f.status() == Fight.Status.WON:
					won += 1
			print("%s tuning=%s fights won=%d/1000 shifts=%d late=%d rounds=%d" % [
				law.title, str(tuning), won, shifts, late_shifts, rounds])
