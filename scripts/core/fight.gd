class_name Fight
extends RefCounted
## A run of rounds against one dealer (one Law). Owns the shift-charge economy.
##
## Placeholder win condition: win `wins_needed` of `rounds_total` rounds.
## All numbers are tuning knobs; see docs/DESIGN.md.

enum Status { ACTIVE, WON, LOST }

var law: Law
var deck: Deck

var start_charges := 2
var max_charges := 3
var win_refund := 1 # charges gained for winning a round without shifting
var rounds_total := 7
var wins_needed := 4
var forced_rounds: Array[int] = [3, 6] # 1-based rounds where the table starts in B

var charges: int
var round_index := 0
var wins := 0
var losses := 0
var pushes := 0
var current: RoundState

var _settled := true


func _init(p_law: Law, p_deck: Deck) -> void:
	law = p_law
	deck = p_deck
	charges = start_charges


func start_round() -> RoundState:
	assert(status() == Status.ACTIVE and _settled, "previous round still in progress")
	if deck.auto_reshuffle and deck.cards.size() < Deck.RESHUFFLE_BELOW:
		deck.shuffle()
	round_index += 1
	current = RoundState.new(law, deck, round_index in forced_rounds)
	_settled = false
	return current


## Telegraph for the UI: will the next round start with a forced shift?
func next_round_forced() -> bool:
	return (round_index + 1) in forced_rounds


func can_shift() -> bool:
	return current != null and current.can_shift(charges)


func shift() -> bool:
	if not can_shift():
		return false
	charges -= 1
	return current.shift()


func hit() -> void:
	current.hit()
	_settle()


func stand() -> void:
	current.stand()
	_settle()


func status() -> Status:
	if wins >= wins_needed:
		return Status.WON
	var in_progress := 1 if (round_index > 0 and not _settled) else 0
	var best_possible := wins + (rounds_total - round_index) + in_progress
	if best_possible < wins_needed:
		return Status.LOST
	return Status.ACTIVE


func _settle() -> void:
	if _settled or current.phase != RoundState.Phase.RESOLVED:
		return
	_settled = true
	match current.outcome:
		RoundState.Outcome.WIN:
			wins += 1
			if current.shifts_used == 0:
				charges = mini(max_charges, charges + win_refund)
		RoundState.Outcome.LOSE:
			losses += 1
		RoundState.Outcome.PUSH:
			pushes += 1
