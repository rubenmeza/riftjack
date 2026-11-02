class_name Card
extends RefCounted

const SUITS := "♠♥♦♣"

var rank: int # 1 (ace) .. 13 (king)
var suit: int # 0..3


func _init(p_rank: int, p_suit: int) -> void:
	rank = p_rank
	suit = p_suit


## Realm A value. Hard ace = 1, faces = 10 (no soft ace in v1).
func base_value() -> int:
	return mini(rank, 10)


func value_in(law: Law, realm: int) -> int:
	return law.value(base_value(), realm)


func label() -> String:
	var r: String
	match rank:
		1: r = "A"
		11: r = "J"
		12: r = "Q"
		13: r = "K"
		_: r = str(rank)
	return r + SUITS[suit]
