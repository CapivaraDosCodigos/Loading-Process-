extends PlayerState

var dash_velocity_add: Vector2
var pos_jump: bool = false
var gear: float = 1.0
var direction_input: float

# Fases internas do estado RUN
enum GearPhase {WALK_ACCEL, JOG_ACCEL, RUN, JOG_DECEL, WALK_DECEL}
var current_phase: GearPhase
var is_turning: bool = false
var is_decelerating: bool = false


func enter(previous_state: String, data: Dictionary = {}) -> void:
	if data.has("velocity_add"):
		dash_velocity_add = data["velocity_add"]

	# Pos‑jump (aterrissagem de um pulo, queda, etc.)
	if previous_state in [FALL, JUMP, HURT, WALL_SLIDE, WALL_SLIDE]:
		pos_jump = true
		player.animation.play(POS_JUMP)
		await player.animation.animation_finished
		pos_jump = false

	# Se veio de um dash, já começa em Run total
	if previous_state == DASH:
		gear = 2.0
		current_phase = GearPhase.RUN
		player.animation.play(RUN)
		return

	# Inicia a aceleração normal
	_start_acceleration()


func _start_acceleration() -> void:
	current_phase = GearPhase.WALK_ACCEL
	gear = 1.0
	player.animation.play("Walk")
	_connect_loop_signal(_on_accel_walk_looped)


func _on_accel_walk_looped() -> void:
	if not _state_still_active():
		_disconnect_loop_signal()
		return
	_disconnect_loop_signal()

	current_phase = GearPhase.JOG_ACCEL
	gear = 1.5
	player.animation.play("Jog")
	_connect_loop_signal(_on_accel_jog_looped)


func _on_accel_jog_looped() -> void:
	if not _state_still_active():
		_disconnect_loop_signal()
		return
	_disconnect_loop_signal()

	current_phase = GearPhase.RUN
	gear = 2.0
	player.animation.play(RUN)
	# Fim da aceleração


func _start_deceleration() -> void:
	if is_decelerating:
		return
	is_decelerating = true
	_disconnect_loop_signal()  # cancela qualquer aceleração pendente

	match current_phase:
		GearPhase.WALK_ACCEL:
			# Ainda nem saiu do Walk → para imediatamente
			finished.emit(IDLE)

		GearPhase.JOG_ACCEL:
			# Estava em Jog → reduz para Walk rápido e depois idle
			_schedule_decel_step(GearPhase.WALK_DECEL, 1.0, "Walk", _on_decel_walk_looped)

		GearPhase.RUN:
			# Estava em Run → reduz para Jog rápido → Walk rápido → idle
			_schedule_decel_step(GearPhase.JOG_DECEL, 1.5, "Jog", _on_decel_jog_looped)

		# Se já estiver decelerando, não faz nada (mantém a sequência atual)
		GearPhase.JOG_DECEL, GearPhase.WALK_DECEL:
			pass


func _on_decel_jog_looped() -> void:
	if not _state_still_active():
		_disconnect_loop_signal()
		return
	_disconnect_loop_signal()

	_schedule_decel_step(GearPhase.WALK_DECEL, 1.0, "Walk", _on_decel_walk_looped)


func _on_decel_walk_looped() -> void:
	if not _state_still_active():
		_disconnect_loop_signal()
		return
	_disconnect_loop_signal()

	finished.emit(IDLE)


func _schedule_decel_step(phase: GearPhase, new_gear: float, anim: String, callback: Callable) -> void:
	current_phase = phase
	gear = new_gear
	player.animation.speed_scale = 1.0          # dobra a velocidade da animação
	player.animation.play(anim)
	_connect_loop_signal(callback)
	# O speed_scale será restaurado no próximo passo ou ao sair do estado


func _start_turn() -> void:
	if is_turning:
		return
	is_turning = true
	_disconnect_loop_signal()         # pausa a progressão de gear enquanto vira
	player.animation.play("Run Turn")
	# Supondo que "Run-Turn" seja uma animação que toca uma vez e termina
	await player.animation.animation_finished
	if not _state_still_active():
		return
	is_turning = false
	_resume_current_phase_animation()


func _resume_current_phase_animation() -> void:
	# Restaura a animação de acordo com a fase atual
	match current_phase:
		GearPhase.WALK_ACCEL:
			player.animation.play("Walk")
			_connect_loop_signal(_on_accel_walk_looped)
		GearPhase.JOG_ACCEL:
			player.animation.play("Jog")
			_connect_loop_signal(_on_accel_jog_looped)
		GearPhase.RUN:
			player.animation.play(RUN)
		# Para fases de deceleração, não deve ocorrer (turn só com input ativo)
		_:
			pass


func physics_update(delta: float) -> void:
	if pos_jump:
		return

	handle_movement()

	if player.is_on_floor():
		player.can_dash = true

	player.velocity.y += player.fall_gravity * delta
	player.animation.scale.x = player.direction

	direction_input = Inputs.get_input().x

	# Trata virada de direção (Run‑Turn) se houver input e a direção mudar
	if direction_input != 0 and not is_turning and player.direction * direction_input < 0:
		_start_turn()

	# Se não está virando, verifica se deve começar a parar
	if not is_turning:
		if direction_input == 0 and not is_decelerating:
			_start_deceleration()

	# Dash e outras transições
	if handle_dash():
		return

	elif player.buffer_jump.is_interval() and player.coyote_timer > 0:
		finished.emit(JUMP)

	elif player.can_wall_slide():
		finished.emit(WALL_SLIDE)

	elif not player.is_on_floor():
		finished.emit(FALL)


func handle_movement() -> void:
	var velocity_add: Vector2 = Vector2.ZERO

	if MathGame.desnormalized(dash_velocity_add).x == direction_input:
		velocity_add.x = dash_velocity_add.abs().x

	dash_velocity_add = dash_velocity_add.lerp(Vector2.ZERO, player.AIR_FRICTION / 10.0)

	if direction_input != 0.0:
		player.direction = direction_input
	# A chamada de fim foi substituída pelo sistema de desaceleração

	player.velocity.x = player.direction * max(player.speed * gear, velocity_add.x)


func handle_dash() -> bool:
	if player.buffer_dash.is_interval() and player.dash_cooldown:
		if player.has_dash:
			finished.emit(DASH, {"gear": gear})
			return true
		player.buffer_dash.set_buffer_time()
		player.use_skills()
	return false


func get_name() -> StringName:
	return RUN


# ─── Helpers de conexão segura do sinal ───
func _connect_loop_signal(callable: Callable) -> void:
	if not player.animation.animation_looped.is_connected(callable):
		player.animation.animation_looped.connect(callable, CONNECT_ONE_SHOT)  # uma única execução


func _disconnect_loop_signal() -> void:
	for conn: Dictionary in player.animation.animation_looped.get_connections():
		player.animation.animation_looped.disconnect(conn.callable)


func _state_still_active() -> bool:
	return player.state_machine.is_state(RUN)


# Ao sair do estado, restaura o speed_scale e limpa sinais
func exit() -> void:
	_disconnect_loop_signal()
	player.animation.speed_scale = 1.0
	is_decelerating = false
	is_turning = false
