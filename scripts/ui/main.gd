extends Control
## Functional (not pretty) UI for the core loop. Built in code so the scene stays
## trivial; swap for real scenes once the feel is right.

const BG_A := Color("1d1a14")
const BG_B := Color("141a2b")
const COLOR_A := Color("e8c872")
const COLOR_B := Color("7aa7ff")

var laws: Array[Law] = []
var fight: Fight

var bg: ColorRect
var law_picker: OptionButton
var law_label: Label
var stats_label: Label
var dealer_total: Label
var dealer_row: HBoxContainer
var player_row: HBoxContainer
var player_total: Label
var message: Label
var hit_btn: Button
var stand_btn: Button
var shift_btn: Button
var next_btn: Button


func _ready() -> void:
	laws = Law.all()
	_build_ui()
	_new_fight()


func _build_ui() -> void:
	bg = ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	for side in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 24)
	add_child(margin)

	var root := VBoxContainer.new()
	root.add_theme_constant_override("separation", 12)
	margin.add_child(root)

	var top := HBoxContainer.new()
	root.add_child(top)
	law_picker = OptionButton.new()
	for law in laws:
		law_picker.add_item(law.title)
	law_picker.item_selected.connect(func(_i: int) -> void: _new_fight())
	top.add_child(law_picker)
	law_label = _make_label(18)
	law_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(law_label)

	stats_label = _make_label(18)
	root.add_child(stats_label)

	dealer_total = _make_label(20)
	root.add_child(dealer_total)
	dealer_row = HBoxContainer.new()
	dealer_row.add_theme_constant_override("separation", 10)
	root.add_child(dealer_row)

	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_child(spacer)

	player_total = _make_label(20)
	root.add_child(player_total)
	player_row = HBoxContainer.new()
	player_row.add_theme_constant_override("separation", 10)
	root.add_child(player_row)

	message = _make_label(22)
	root.add_child(message)

	var buttons := HBoxContainer.new()
	buttons.add_theme_constant_override("separation", 12)
	root.add_child(buttons)
	hit_btn = _make_button("Hit", _on_hit)
	stand_btn = _make_button("Stand", _on_stand)
	shift_btn = _make_button("Shift (1 charge)", _on_shift)
	next_btn = _make_button("Next round", _on_next)
	for b in [hit_btn, stand_btn, shift_btn, next_btn]:
		buttons.add_child(b)


func _make_label(font_size: int) -> Label:
	var label := Label.new()
	label.add_theme_font_size_override("font_size", font_size)
	return label


func _make_button(text: String, handler: Callable) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(160, 48)
	button.pressed.connect(handler)
	return button


func _new_fight() -> void:
	fight = Fight.new(laws[law_picker.selected], Deck.new())
	fight.start_round()
	_refresh()


func _on_hit() -> void:
	fight.hit()
	_refresh()


func _on_stand() -> void:
	fight.stand()
	_refresh()


func _on_shift() -> void:
	fight.shift()
	_refresh()


func _on_next() -> void:
	if fight.status() == Fight.Status.ACTIVE:
		fight.start_round()
		_refresh()
	else:
		_new_fight()


func _refresh() -> void:
	var r := fight.current
	var other := Realm.flip(r.realm)

	bg.color = BG_A if r.realm == Realm.A else BG_B
	law_label.text = "%s law:  %s" % [fight.law.title, fight.law.strip_text()]
	stats_label.text = "Round %d/%d    Wins %d/%d    Shift charges %d/%d" % [
		fight.round_index, fight.rounds_total, fight.wins, fight.wins_needed,
		fight.charges, fight.max_charges]

	_fill_row(dealer_row, r.dealer, -1 if r.dealer_revealed else 1)
	_fill_row(player_row, r.player, -1)

	if r.dealer_revealed:
		dealer_total.text = "Dealer — %s: %d" % [
			Realm.name_of(r.realm), r.dealer.total(fight.law, r.realm)]
	else:
		dealer_total.text = "Dealer shows — A: %d   B: %d" % [
			r.dealer_visible_total(Realm.A), r.dealer_visible_total(Realm.B)]
	player_total.text = "You — %s: %d    (%s: %d)" % [
		Realm.name_of(r.realm), r.player_total(),
		Realm.name_of(other), r.player.total(fight.law, other)]

	message.text = _message_text(r)

	var playing := r.phase == RoundState.Phase.PLAYER
	hit_btn.disabled = not playing
	stand_btn.disabled = not playing
	shift_btn.disabled = not fight.can_shift()
	next_btn.visible = not playing
	next_btn.text = "Next round" if fight.status() == Fight.Status.ACTIVE else "New fight"


func _message_text(r: RoundState) -> String:
	if r.phase == RoundState.Phase.PLAYER:
		var text := "Stand locks realm %s." % Realm.name_of(r.realm)
		if r.forced:
			text = "FORCED SHIFT — the table starts in B.  " + text
		elif fight.next_round_forced():
			text += "  (Next round: forced shift)"
		return text
	var result: String
	match r.outcome:
		RoundState.Outcome.WIN: result = "You win."
		RoundState.Outcome.LOSE: result = "You lose."
		_: result = "Push."
	match fight.status():
		Fight.Status.WON: result += "  FIGHT WON."
		Fight.Status.LOST: result += "  FIGHT LOST."
	return result


## `hide_from`: index of the first face-down card (-1 = none hidden).
func _fill_row(row: HBoxContainer, hand: Hand, hide_from: int) -> void:
	for child in row.get_children():
		row.remove_child(child)
		child.queue_free()
	for i in hand.cards.size():
		var hidden := hide_from >= 0 and i >= hide_from
		row.add_child(_card_widget(hand.cards[i], hidden))


func _card_widget(card: Card, hidden: bool) -> Control:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(96, 132)
	var box := VBoxContainer.new()
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	panel.add_child(box)

	var title := _make_label(28)
	title.text = "?" if hidden else card.label()
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(title)

	for realm in [Realm.A, Realm.B]:
		var row := _make_label(18)
		row.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		row.text = "%s  %s" % [
			Realm.name_of(realm), "?" if hidden else str(card.value_in(fight.law, realm))]
		var tint := COLOR_A if realm == Realm.A else COLOR_B
		row.modulate = tint if realm == fight.current.realm else Color(tint, 0.35)
		box.add_child(row)
	return panel
