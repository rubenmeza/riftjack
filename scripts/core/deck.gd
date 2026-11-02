class_name Deck
extends RefCounted

const RESHUFFLE_BELOW := 15

var rng: RandomNumberGenerator
var cards: Array[Card] = []
## Tests turn this off so a stacked deck is never reshuffled under them.
var auto_reshuffle := true


func _init(p_rng: RandomNumberGenerator = null) -> void:
	rng = p_rng if p_rng != null else RandomNumberGenerator.new()
	shuffle()


func shuffle() -> void:
	cards.clear()
	for suit in 4:
		for rank in range(1, 14):
			cards.append(Card.new(rank, suit))
	for i in range(cards.size() - 1, 0, -1):
		var j := rng.randi_range(0, i)
		var tmp := cards[i]
		cards[i] = cards[j]
		cards[j] = tmp


func draw() -> Card:
	if cards.is_empty():
		shuffle()
	return cards.pop_back()


## Deterministic deck for tests. `draw_order[0]` is drawn first.
static func stacked(draw_order: Array[Card]) -> Deck:
	var deck := Deck.new()
	deck.auto_reshuffle = false
	deck.cards.clear()
	var i := draw_order.size() - 1
	while i >= 0:
		deck.cards.append(draw_order[i])
		i -= 1
	return deck
