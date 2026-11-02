class_name RoundState
extends RefCounted
## One hand of Riftjack.
##
## Deal order: player, dealer (upcard), player, dealer (hole).
## The player may Hit, Stand or Shift. Standing locks the realm; the dealer then
## reveals the hole card and draws to DEALER_STAND *in the locked realm*.
## A bust in the active realm ends the hand at once, so Shift is pre-emptive:
## it is refused if it would put the player over TARGET.

enum Phase { PLAYER, RESOLVED }
enum Outcome { NONE, WIN, LOSE, PUSH }

const TARGET := 21
const DEALER_STAND := 17
const MAX_SHIFTS := 1

var law: Law
var deck: Deck
var player := Hand.new()
var dealer := Hand.new()
var realm: int = Realm.A
var phase: Phase = Phase.PLAYER
var outcome: Outcome = Outcome.NONE
var dealer_revealed := false
## True when a boss rule flipped the table to realm B before the player acted.
var forced := false
## Player-initiated shifts this round (forced flips don't count).
var shifts_used := 0


func _init(p_law: Law, p_deck: Deck, p_forced: bool = false) -> void:
	law = p_law
	deck = p_deck
	forced = p_forced
	if forced:
		realm = Realm.B
	player.add(deck.draw())
	dealer.add(deck.draw())
	player.add(deck.draw())
	dealer.add(deck.draw())


func player_total() -> int:
	return player.total(law, realm)


## Dealer upcard only, scored in the given realm.
func dealer_visible_total(in_realm: int) -> int:
	return dealer.total(law, in_realm, 1)


func can_shift(charges: int) -> bool:
	if phase != Phase.PLAYER or shifts_used >= MAX_SHIFTS or charges <= 0:
		return false
	return player.total(law, Realm.flip(realm)) <= TARGET


## Flips the realm. The caller is responsible for paying the charge.
func shift() -> bool:
	if not can_shift(1):
		return false
	realm = Realm.flip(realm)
	shifts_used += 1
	return true


func hit() -> void:
	if phase != Phase.PLAYER:
		return
	player.add(deck.draw())
	if player_total() > TARGET:
		dealer_revealed = true
		_finish(Outcome.LOSE)


func stand() -> void:
	if phase != Phase.PLAYER:
		return
	dealer_revealed = true
	while dealer.total(law, realm) < DEALER_STAND:
		dealer.add(deck.draw())
	var p := player_total()
	var d := dealer.total(law, realm)
	if d > TARGET or p > d:
		_finish(Outcome.WIN)
	elif p == d:
		_finish(Outcome.PUSH)
	else:
		_finish(Outcome.LOSE)


func _finish(result: Outcome) -> void:
	outcome = result
	phase = Phase.RESOLVED
