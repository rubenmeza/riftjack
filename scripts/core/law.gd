class_name Law
extends Resource
## A dealer's reality law: how a card's Realm A value maps to its Realm B value.
##
## Stored as a lookup table (index = A value 1..10) so the UI can show the whole
## law as a strip and so every law is plain data.

@export var id: StringName
@export var title: String
@export var b_map: PackedInt32Array


func value(a_value: int, realm: int) -> int:
	return a_value if realm == Realm.A else b_map[a_value]


func strip_text() -> String:
	var parts := PackedStringArray()
	for v in range(1, 11):
		parts.append("%d→%d" % [v, b_map[v]])
	return " ".join(parts)


static func from_fn(p_id: StringName, p_title: String, fn: Callable) -> Law:
	var law := Law.new()
	law.id = p_id
	law.title = p_title
	law.b_map = PackedInt32Array([0])
	for v in range(1, 11):
		law.b_map.append(fn.call(v))
	return law


## High and low swap. Easy to read; A and B totals are anti-correlated.
static func mirror() -> Law:
	return from_fn(&"mirror", "Mirror", func(v: int) -> int: return 11 - v)


## +3 wrapping around 1..10. Hardest to read, strongest world swing.
static func rot3() -> Law:
	return from_fn(&"rot3", "Rot3", func(v: int) -> int: return ((v + 2) % 10) + 1)


## Tens are worth nothing in B; everything else is unchanged.
static func void_law() -> Law:
	return from_fn(&"void", "Void", func(v: int) -> int: return 0 if v == 10 else v)


static func all() -> Array[Law]:
	var laws: Array[Law] = [mirror(), rot3(), void_law()]
	return laws
