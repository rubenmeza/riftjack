extends SceneTree
## Headless tests for the core rules.
##   godot --headless --path . -s tests/run_tests.gd
## Exit code = number of failed checks.

var _failures := 0
var _checks := 0


func _initialize() -> void:
	test_laws()
	test_card_and_hand()
	test_bust_ends_round()
	test_shift_refused_when_it_would_bust()
	test_dealer_draws_in_locked_realm()
	test_shift_changes_resolution_realm()
	test_fight_charges()
	test_forced_round()
	print("%d checks, %d failed" % [_checks, _failures])
	quit(_failures)


func check(cond: bool, msg: String) -> void:
	_checks += 1
	if not cond:
		_failures += 1
		printerr("FAIL: " + msg)


## Deck that deals these ranks in order (suit is irrelevant).
func stack(ranks: Array) -> Deck:
	var order: Array[Card] = []
	for r in ranks:
		order.append(Card.new(r, 0))
	return Deck.stacked(order)


func test_laws() -> void:
	var m := Law.mirror()
	check(m.value(10, Realm.B) == 1 and m.value(1, Realm.B) == 10, "mirror swaps ends")
	check(m.value(7, Realm.A) == 7, "realm A is identity")
	var r3 := Law.rot3()
	check(r3.value(1, Realm.B) == 4 and r3.value(8, Realm.B) == 1 and r3.value(10, Realm.B) == 3, "rot3 wraps")
	var v := Law.void_law()
	check(v.value(10, Realm.B) == 0 and v.value(9, Realm.B) == 9, "void zeroes tens only")
	for law in Law.all():
		check(law.b_map.size() == 11, "%s map covers 0..10" % law.title)


func test_card_and_hand() -> void:
	check(Card.new(13, 0).base_value() == 10, "king is 10")
	check(Card.new(1, 0).base_value() == 1, "ace is 1")
	var h := Hand.new()
	h.add(Card.new(1, 0))
	h.add(Card.new(13, 0))
	check(h.total(Law.mirror(), Realm.A) == 11, "A+K = 11 in A")
	check(h.total(Law.mirror(), Realm.B) == 11, "A+K = 10+1 in B under mirror")
	check(h.total(Law.mirror(), Realm.A, 1) == 1, "limit counts first card only")


func test_bust_ends_round() -> void:
	# player 10,6 ; dealer 5,5 ; hit draws 10 -> 26
	var r := RoundState.new(Law.mirror(), stack([10, 5, 6, 5, 10]))
	r.hit()
	check(r.phase == RoundState.Phase.RESOLVED and r.outcome == RoundState.Outcome.LOSE, "bust loses at once")
	check(r.dealer_revealed, "bust reveals the dealer")


func test_shift_refused_when_it_would_bust() -> void:
	# player A,A then hits A: 3 in A, 30 in B under mirror
	var r := RoundState.new(Law.mirror(), stack([1, 5, 1, 5, 1]))
	r.hit()
	check(r.player_total() == 3, "three aces = 3 in A")
	check(not r.can_shift(1), "shift into 30 is refused")
	check(not r.shift(), "shift() returns false when refused")


func test_dealer_draws_in_locked_realm() -> void:
	# player K,Q = 20 ; dealer 10,6 = 16 -> draws 5 = 21 -> dealer wins
	var r := RoundState.new(Law.mirror(), stack([13, 10, 12, 6, 5]))
	r.stand()
	check(r.dealer.total(r.law, Realm.A) == 21, "dealer drew to 21 in A")
	check(r.outcome == RoundState.Outcome.LOSE, "20 loses to 21")


func test_shift_changes_resolution_realm() -> void:
	# player 2,3 -> A:5 B:17 ; dealer 10,7 -> B:5 then nines (B:2 each) to 17
	var r := RoundState.new(Law.mirror(), stack([2, 10, 3, 7, 9, 9, 9, 9, 9, 9, 9, 9]))
	check(r.player_total() == 5, "A total 5")
	check(r.shift(), "shift allowed")
	check(r.player_total() == 17, "B total 17")
	check(not r.can_shift(1), "only one shift per round")
	r.stand()
	check(r.dealer.total(r.law, Realm.B) == 17, "dealer resolved in B")
	check(r.outcome == RoundState.Outcome.PUSH, "17 v 17 pushes")


func test_fight_charges() -> void:
	# round 1: K,Q (20) v 10,7 (17) -> unshifted win ; round 2: shifted
	var deck := stack([13, 10, 12, 7, 2, 10, 3, 7, 9, 9, 9, 9, 9, 9, 9, 9])
	var f := Fight.new(Law.mirror(), deck)
	f.forced_rounds = []
	f.start_round()
	f.stand()
	check(f.wins == 1, "round 1 won")
	check(f.charges == 3, "unshifted win refunds a charge (cap 3)")
	f.start_round()
	check(f.shift(), "fight shift works")
	check(f.charges == 2, "shift costs one charge")
	check(not f.shift(), "no second shift in a round")


func test_forced_round() -> void:
	var f := Fight.new(Law.mirror(), stack([5, 5, 5, 5]))
	f.forced_rounds = [1]
	var r := f.start_round()
	check(r.realm == Realm.B and r.forced, "forced round starts in B")
	check(r.shifts_used == 0, "forced flip is not a player shift")
	check(f.charges == f.start_charges, "forced flip costs nothing")
