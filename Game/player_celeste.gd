extends Node

#region const
# ========================
# PARTICLES (static)
# ========================
static var P_DashA            # Partícula dash A
static var P_DashB            # Partícula dash B
static var P_CassetteFly      # Partícula voo cassette
static var P_Split            # Partícula split
static var P_SummitLandA      # Partícula pouso A
static var P_SummitLandB      # Partícula pouso B
static var P_SummitLandC      # Partícula pouso C


# ========================
# MOVEMENT / GRAVITY
# ========================
const MAX_FALL: float = 160.0             # Velocidade máxima de queda
const GRAVITY: float = 900.0              # Gravidade padrão
const HALF_GRAV_THRESHOLD: float = 40.0   # Limite para meia gravidade

const FAST_MAX_FALL: float = 240.0        # Queda rápida máxima
const FAST_MAX_ACCEL: float = 300.0       # Aceleração queda rápida

const MAX_RUN: float = 90.0               # Velocidade máxima corrida
const RUN_ACCEL: float = 1000.0           # Aceleração corrida
const RUN_REDUCE: float = 400.0           # Desaceleração
const AIR_MULT: float = 0.65              # Multiplicador no ar

const HOLDING_MAX_RUN: float = 70.0       # Velocidade segurando objeto
const HOLD_MIN_TIME: float = 0.35         # Tempo mínimo segurando


# ========================
# JUMP
# ========================
const BOUNCE_AUTO_JUMP_TIME: float = 0.1  # Auto jump após bounce

const JUMP_GRACE_TIME: float = 0.1        # Coyote time
const JUMP_SPEED: float = -105.0          # Velocidade pulo
const JUMP_H_BOOST: float = 40.0          # Boost horizontal pulo
const VAR_JUMP_TIME: float = 0.2          # Tempo pulo variável
const CEILING_VAR_JUMP_GRACE: float = 0.05 # Tolerância teto

const UPWARD_CORNER_CORRECTION: int = 4   # Correção canto subindo


# ========================
# WALL
# ========================
const WALL_SPEED_RETENTION_TIME: float = 0.06  # Retenção velocidade parede

const WALL_JUMP_CHECK_DIST: int = 3            # Distância check wall jump
const WALL_JUMP_FORCE_TIME: float = 0.16       # Tempo força wall jump
const WALL_JUMP_H_SPEED: float = MAX_RUN + JUMP_H_BOOST  # Vel horizontal wall jump

const WALL_SLIDE_START_MAX: float = 20.0       # Vel início slide
const WALL_SLIDE_TIME: float = 1.2             # Tempo slide


# ========================
# BOUNCE / SUPER
# ========================
const BOUNCE_VAR_JUMP_TIME: float = 0.2        # Tempo bounce
const BOUNCE_SPEED: float = -140.0             # Vel bounce

const SUPER_BOUNCE_VAR_JUMP_TIME: float = 0.2  # Tempo super bounce
const SUPER_BOUNCE_SPEED: float = -185.0       # Vel super bounce

const SUPER_JUMP_SPEED: float = JUMP_SPEED     # Vel super jump
const SUPER_JUMP_H: float = 260.0              # Horizontal super jump

const SUPER_WALL_JUMP_SPEED: float = -160.0    # Vel wall super
const SUPER_WALL_JUMP_VAR_TIME: float = 0.25   # Tempo variável
const SUPER_WALL_JUMP_FORCE_TIME: float = 0.2  # Tempo força
const SUPER_WALL_JUMP_H: float = MAX_RUN + JUMP_H_BOOST * 2


# ========================
# DASH
# ========================
const DASH_SPEED: float = 240.0          # Velocidade dash
const END_DASH_SPEED: float = 160.0      # Vel final dash
const END_DASH_UP_MULT: float = 0.75     # Multiplicador vertical fim

const DASH_TIME: float = 0.15            # Duração dash
const DASH_COOLDOWN: float = 0.2         # Cooldown
const DASH_REFILL_COOLDOWN: float = 0.1  # Tempo recarga

const DASH_H_JUMP_THRU_NUDGE: int = 6    # Ajuste horizontal
const DASH_CORNER_CORRECTION: int = 4    # Correção canto
const DASH_V_FLOOR_SNAP_DIST: int = 3    # Snap chão

const DASH_ATTACK_TIME: float = 0.3      # Tempo ataque dash


# ========================
# CLIMB
# ========================
const CLIMB_MAX_STAMINA: float = 110.0        # Stamina máxima
const CLIMB_UP_COST: float = 100.0 / 2.2      # Custo subir
const CLIMB_STILL_COST: float = 100.0 / 10.0  # Custo parado
const CLIMB_JUMP_COST: float = 110.0 / 4.0    # Custo pulo

const CLIMB_CHECK_DIST: int = 2
const CLIMB_UP_CHECK_DIST: int = 2

const CLIMB_NO_MOVE_TIME: float = 0.1

const CLIMB_TIRED_THRESHOLD: float = 20.0     # Cansado

const CLIMB_UP_SPEED: float = -45.0
const CLIMB_DOWN_SPEED: float = 80.0
const CLIMB_SLIP_SPEED: float = 30.0

const CLIMB_ACCEL: float = 900.0
const CLIMB_GRAB_Y_MULT: float = 0.2

const CLIMB_HOP_Y: float = -120.0
const CLIMB_HOP_X: float = 100.0

const CLIMB_HOP_FORCE_TIME: float = 0.2
const CLIMB_JUMP_BOOST_TIME: float = 0.2
const CLIMB_HOP_NO_WIND_TIME: float = 0.3

const ST_NORMAL: int = 0
const ST_CLIMB: int = 1
const ST_DASH: int = 2
const ST_SWIM: int = 3
const ST_BOOST: int = 4
const ST_RED_DASH: int = 5
const ST_HIT_SQUASH: int = 6
const ST_LAUNCH: int = 7
const ST_PICKUP: int = 8
const ST_DREAM_DASH: int = 9
const ST_SUMMIT_LAUNCH: int = 10
const ST_DUMMY: int = 11
const ST_INTRO_WALK: int = 12
const ST_INTRO_JUMP: int = 13
const ST_INTRO_RESPAWN: int = 14
const ST_INTRO_WAKE_UP: int = 15
const ST_BIRD_DASH_TUTORIAL: int = 16
const ST_FROZEN: int = 17
const ST_REFLECTION_FALL: int = 18
const ST_STAR_FLY: int = 19
const ST_TEMPLE_FALL: int = 20
const ST_CASSETTE_FLY: int = 21
const ST_ATTRACT: int = 22

const WALK_SPEED: float = 64.0      # Velocidade andando

#endregion
