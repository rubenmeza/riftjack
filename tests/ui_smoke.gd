extends SceneTree

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var ui = load("res://scenes/main.tscn").instantiate()
	root.add_child(ui)
	for i in 3:
		ui.law_picker.select(i)
		ui._new_fight()
		assert(ui.fight.law.id == Law.all()[i].id)
		assert(ui.shift_preview.text.contains("dealer upcard"))
		var realm: int = ui.fight.current.realm
		ui._on_shift()
		assert(ui.fight.current.realm == Realm.flip(realm))
		assert(ui.shift_btn.disabled)
		assert(ui.shift_preview.text.contains("Already used"))
		await create_timer(0.3).timeout
		assert(ui.bg.color == ui.BG_B)
		ui._on_stand()
		assert(ui.next_btn.visible and not ui.shift_preview.visible)
		ui._on_next()
		ui.fight.charges = 0
		ui._refresh()
		assert(ui.shift_btn.disabled and ui.shift_preview.text.contains("No charges"))
	ui.queue_free()
	print("UI smoke: all three laws, preview, shift, palette, stand, next, no charges passed")
	quit()
