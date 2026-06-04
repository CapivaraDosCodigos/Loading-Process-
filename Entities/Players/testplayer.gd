extends CharacterBody2D

enum State { NORMAL, DASHING, WALL_SLIDING }
var state: int = State.NORMAL

@export var velocidade_max: float = 90.0         # velocidade instantânea ao pressionar
@export var atrito_chao: float = 800.0           # atrito quando solta a direção no chão

@export var velocidade_pulo: float = -400.0      # negativa (Y para cima)
@export var velocidade_corte: float = -150.0     # corte se largar o botão durante a subida
@export var coyote_time_max: float = 0.08        # ~5 frames a 60 fps
@export var buffer_time_max: float = 0.1         # ~6 frames a 60 fps

# Dash
@export var dash_speed: float = 240.0            # velocidade durante o dash
@export var dash_duration: float = 0.25          # 15 frames a 60 fps ≈ 0.25s
@export var retained_dash_speed: float = 160.0   # momentum horizontal mantido após o dash

# Wall slide / Wall jump
@export var wall_slide_speed: float = 30.0       # velocidade vertical ao deslizar na parede
@export var wall_jump_vertical: float = -250.0    # velocidade vertical do salto de parede
@export var wall_jump_horizontal: float = 150.0   # velocidade horizontal (para longe da parede)

@export var gravidade: float = 1200.0

var coyote_timer: float = 0.0
var buffer_timer: float = 0.0
var dash_timer: float = 0.0
var dash_direction: Vector2 = Vector2.ZERO
var facing: int = 1                           # 1 = direita, -1 = esquerda
var was_on_floor: bool = false                # estado do chão no frame anterior

func _physics_process(delta: float) -> void:
	# 1. Guarda o estado do chão antes do movimento
	was_on_floor = is_on_floor()
	
	# 2. Actualiza o buffer de salto (se o jogador acabou de pressionar "pular")
	if Input.is_action_just_pressed("ui_accept"):
		buffer_timer = buffer_time_max

	# 3. Calcula a velocidade de acordo com o estado actual
	match state:
		State.NORMAL:
			_velocity_normal(delta)
		State.DASHING:
			_velocity_dash(delta)
		State.WALL_SLIDING:
			_velocity_wall_slide(delta)

	# 4. Primeiro movimento do frame
	move_and_slide()

	# 5. Pós‑movimento: verifica saltos com buffer/coyote (executa um segundo movimento se necessário)
	match state:
		State.NORMAL:
			# --- JUMP BUFFER: aterra com o buffer activo → salta imediatamente
			if is_on_floor() and buffer_timer > 0.0 and not was_on_floor:
				velocity.y = velocidade_pulo
				move_and_slide()
				buffer_timer = 0.0
				coyote_timer = 0.0

			# --- COYOTE TIME: pressionou "pular" enquanto o coyote ainda está activo
			if Input.is_action_just_pressed("ui_accept") and coyote_timer > 0.0:
				velocity.y = velocidade_pulo
				move_and_slide()
				coyote_timer = 0.0
				buffer_timer = 0.0

			# Actualiza temporizadores de coyote e buffer (após possíveis saltos)
			if is_on_floor():
				coyote_timer = coyote_time_max
			else:
				coyote_timer -= delta
				coyote_timer = max(0.0, coyote_timer)
				buffer_timer -= delta
				buffer_timer = max(0.0, buffer_timer)

			# Transições de estado a partir de NORMAL
			# Dash?
			if Input.is_action_just_pressed("Dash"):
				_enter_dash()
				return     # sai do _physics_process, o dash domina o próximo frame
			# Wall slide? (na parede, no ar e a descer)
			if is_on_wall() and not is_on_floor() and velocity.y > 0:
				state = State.WALL_SLIDING

		State.DASHING:
			# Temporizador do dash
			dash_timer -= delta
			if dash_timer <= 0.0:
				# Retorna ao normal, mantendo parte do momentum horizontal do dash
				velocity.x = dash_direction.x * retained_dash_speed
				velocity.y = 0.0
				state = State.NORMAL
				# (coyote/buffer permanecem como estão, normalmente 0)

		State.WALL_SLIDING:
			# Se perdeu a parede ou tocou o chão, volta ao normal
			if not is_on_wall() or is_on_floor():
				state = State.NORMAL
			# Dash quebra o wall slide
			if Input.is_action_just_pressed("Dash"):
				_enter_dash()
				return

	# 6. Guarda o estado do chão para o próximo frame
	was_on_floor = is_on_floor()

func _velocity_normal(delta: float) -> void:
	# --- Input horizontal ---
	var input_dir: float = Input.get_axis("ui_left", "ui_right")
	if input_dir != 0:
		facing = sign(input_dir)          # actualiza a direcção em que a Madeline está virada

	if is_on_floor():
		if input_dir != 0:
			velocity.x = input_dir * velocidade_max   # resposta instantânea
		else:
			# Pequeno slide no chão (atrito)
			velocity.x = move_toward(velocity.x, 0.0, atrito_chao * delta)
	else:
		# No ar: se houver input, velocidade horizontal fixa; se não, mantém a anterior
		if input_dir != 0:
			velocity.x = input_dir * velocidade_max

	# --- Gravidade ---
	velocity.y += gravidade * delta

	# --- Corte do salto (largou o botão durante a subida) ---
	if not Input.is_action_pressed("ui_accept") and velocity.y < velocidade_corte:
		velocity.y = velocidade_corte

func _velocity_dash(_delta: float) -> void:
	# Durante o dash a velocidade é fixa, ignorando gravidade e input do jogador
	velocity = dash_direction * dash_speed

func _velocity_wall_slide(_delta: float) -> void:
	# Desliza lentamente pela parede
	velocity.x = 0.0
	velocity.y = wall_slide_speed

	# Wall jump (sai do estado imediatamente)
	if Input.is_action_just_pressed("ui_accept"):
		var wall_normal: float = -sign(get_wall_normal().x)  # -1 se parede à direita, 1 se à esquerda
		velocity.y = wall_jump_vertical
		velocity.x = wall_normal * wall_jump_horizontal
		state = State.NORMAL
		# Como acabou de saltar, o coyote e buffer são zerados
		coyote_timer = 0.0
		buffer_timer = 0.0

func _enter_dash() -> void:
	state = State.DASHING
	dash_timer = dash_duration

	# Define a direcção do dash com base no input actual.
	# Se não houver input, usa a direcção em que a Madeline está virada (horizontal).
	dash_direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if dash_direction == Vector2.ZERO:
		dash_direction = Vector2(facing, 0)
	else:
		dash_direction = dash_direction.normalized()
