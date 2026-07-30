extends PlayerState

var dash_velocity_add: Vector2
var pos_jump: bool = false
var is_turning: bool = false          # <-- NOVO: indica que está na animação de virada
var direction_input: float
var last_direction_input: float:
	set(value):
		if value == 0.0:
			return
		last_direction_input = value

func enter(previous_state: String, data: Dictionary = {}) -> void:
	is_turning = false                 # reseta ao entrar no estado
	if data.has("velocity_add"):
		dash_velocity_add = data["velocity_add"]
	
	if previous_state in [FALL, JUMP, HURT, WALL_SLIDE, WALL_SLIDE]:
		pos_jump = true
		player.animation.play(POS_JUMP)
		await player.animation.animation_finished
		pos_jump = false
	
	player.animation.play(RUN)

func physics_update(delta: float) -> void:
	if pos_jump:
		return
		
	if player.is_on_floor():
		player.can_dash = true
	
	player.velocity.y += player.fall_gravity * delta
	
	# Só atualiza a escala (flip) se não estiver na animação de virada
	if not is_turning:
		player.animation.scale.x = player.direction
	
	direction_input = Game.get_input().x
	
	# Verifica virada: direção atual e última são válidas e de sinais opostos
	if not is_turning and direction_input != 0.0 and last_direction_input != 0.0:
		if sign(direction_input) != sign(last_direction_input):
			_trigger_turn()
			# não interrompe a física, só inicia a coroutine
	
	handle_movement()
	
	if handle_dash():
		return
	
	elif is_equal_approx(player.velocity.x, 0.0) and !Game.is_input_horizontal():
		finished.emit(IDLE)
	
	elif player.buffer_jump.is_interval() and player.coyote_timer > 0:
		finished.emit(JUMP, {"velocity_add": player.velocity})
	
	elif player.can_wall_slide():
		finished.emit(WALL_SLIDE)
	
	elif not player.is_on_floor():
		finished.emit(FALL, {"velocity_add": player.velocity})
	
	last_direction_input = direction_input

func _trigger_turn() -> void:
	if not is_active(): return
	is_turning = true
	player.animation.play("Run Turn")          # substitua pelo nome da sua animação de virada
	
	await player.animation.animation_finished
	
	# Se ainda estiver neste estado e a virada não foi cancelada (ex: saiu do estado)
	if not is_active(): return
	if is_turning:
		is_turning = false
		# Agora aplica o flip na direção que já foi atualizada em handle_movement
		player.animation.scale.x = player.direction
		player.animation.play(RUN)

func handle_movement() -> void:
	var velocity_add: Vector2 = Vector2.ZERO
	
	if MathGame.desnormalized(dash_velocity_add).x == direction_input:
		velocity_add.x = dash_velocity_add.abs().x
	
	dash_velocity_add = dash_velocity_add.lerp(Vector2.ZERO, player.AIR_FRICTION / 10.0)
	
	if is_turning:
		player.direction = direction_input
		player.velocity.x = lerp(player.velocity.x, direction_input * max(player.speed, velocity_add.x), player.speed / 1000.0)
		
	elif Game.is_input_horizontal():
		player.direction = direction_input
		player.velocity.x = player.direction * max(player.speed, velocity_add.x)
	
	else:
		player.velocity.x = 0.0

func handle_dash()-> bool:
	if player.buffer_dash.is_interval() and player.dash_cooldown:
		finished.emit(DASH)
		player.buffer_dash.set_buffer_time()
		player.use_skills()
		return true
	return false

func get_name() -> StringName:
	return RUN

func exit() -> void:
	is_turning = false
	# se possível, também pare a animação se necessário
