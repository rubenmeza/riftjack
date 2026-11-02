class_name Hand
extends RefCounted

var cards: Array[Card] = []


func add(card: Card) -> void:
	cards.append(card)


## Total in a realm. `limit` counts only the first N cards (-1 = all), used for
## the dealer's visible upcard.
func total(law: Law, realm: int, limit: int = -1) -> int:
	var n := cards.size() if limit < 0 else mini(limit, cards.size())
	var sum := 0
	for i in n:
		sum += cards[i].value_in(law, realm)
	return sum
