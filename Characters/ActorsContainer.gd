extends Node2D

signal open_esc_menu
signal show_actor_bar
signal conceal_actor_bar
signal alter_actors_portraits(actors_idxs, styles)

var actors_selected := Array()
var is_selecting_actor := false
var actors_in_party := []

func _input(_event):
	for idx in range(actors_in_party.size()):
		if Input.is_action_just_pressed("select_actor_" + String(idx)):
			handle_key_input_select_actor(idx)
	if Input.is_action_just_pressed("select_all_actors"):
		for actor in actors_in_party:
			select_actor(actor)
	elif Input.is_action_just_pressed("open_esc_menu"):
		if actors_selected.size() == 0:
			emit_signal("open_esc_menu")
		else:
			deselect_all_actors()
	elif Input.is_action_just_pressed("stop_actor_actions"):
		for actor in actors_selected:
			actor.path = PoolVector2Array()
			actor.set_current_target(null)


func handle_key_input_select_actor(num_key_value: int) -> void: ### How do you test for is_action_press()
	if actors_in_party.size() > num_key_value:
		if Input.is_action_pressed("shift"):
			select_actor_by_idx(num_key_value)
		else:
			select_only_this_actor_by_idx(num_key_value)


func select_only_this_actor(actor: KinematicBody2D) -> void:
	deselect_all_actors()
	append_selected_actor(actor)


func select_only_this_actor_by_idx(actor_index: int) -> void:
	select_only_this_actor(get_child(actor_index))


func select_actor(actor: KinematicBody2D) -> void:
	if actors_selected:
		for selected_actor in actors_selected:
			if selected_actor == actor:
				return
		append_selected_actor(actor)
	else:
		append_selected_actor(actor)


func select_actor_by_idx(actor_idx: int) -> void:
	select_actor(actors_in_party[actor_idx])


func append_selected_actor(actor: KinematicBody2D) -> void:
	actors_selected.append(actor)
	if actors_selected.size() > 1:
		emit_signal("conceal_actor_bar")
	else:
		emit_signal("show_actor_bar")
	var styles = {
		"background_color": "#0b2b5c",
		"border_color": "#949494",
		"border_width": 3
	}
	var actors_idxs = []
	for actor in actors_selected:
		var actor_idx = actors_in_party.find(actor)
		if actor_idx > -1:
			actors_idxs.append(actor_idx)
	emit_signal("alter_actors_portraits", actors_idxs, styles)


func deselect_all_actors() -> void:
	actors_selected.clear()
	var styles = {
		"background_color": "#0b2b5c",
	}
	emit_signal("alter_actors_portraits", [], styles)
	emit_signal("conceal_actor_bar")


func is_actor_allowed_to_move(actor: KinematicBody2D) -> bool:
	var is_actor_selected = false
	if is_selecting_actor == false:
		for selected_actor in actors_selected:
			if selected_actor == actor:
				is_actor_selected = true
	return is_actor_selected


func add_actor_to_party(actor: KinematicBody2D) -> void:
	add_child(actor)
	actors_in_party.append(actor)
	var actorCollider = actor.get_node("SelectBox")
	actorCollider.connect("lmb_up", self,
			"select_only_this_actor", [actor])
	actorCollider.connect("lmb_up_shift", self,
			"select_actor", [actor])
	actorCollider.connect("lmb_down", self,
			"set_is_selecting_actor", [true])
	actorCollider.connect("on_mouse_exit", self, "set_is_selecting_actor",
			[false])


func set_selected_actors_target(value: KinematicBody2D) -> void:
	for actor in actors_selected:
		actor.set_current_target(value)


func set_is_selecting_actor(value: bool) -> void:
	is_selecting_actor = value
