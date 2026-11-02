class_name Realm
extends RefCounted
## The two realities a hand can be scored in.

const A := 0
const B := 1


static func flip(realm: int) -> int:
	return B if realm == A else A


static func name_of(realm: int) -> String:
	return "A" if realm == A else "B"
