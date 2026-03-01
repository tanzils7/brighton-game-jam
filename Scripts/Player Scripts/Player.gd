extends CharacterBody2D

@export var speed: float = 300
@export var dashSpeed: float = 600


@onready var animation = $AnimatedSprite2D
@onready var meleeHitbox = $MeleePivot/MeleeHitbox
@onready var swordVFX = $MeleePivot/SwordVFX
@onready var swingPivot = $MeleePivot 
@onready var sfxSword = $"SFX Manager/swordSFX"
@onready var sfxDash = $"SFX Manager/sfxDash"
@onready var carryPoint = $CarryPoint

const meleeCooldown: float = 0.5
const attackLockTime: float = 0.12
const attackActiveTime: float = 0.12
const swingArc: float = 120
const dashTime: float = 0.15
const dashCooldown: float = 0.4

var facingDir: Vector2 = Vector2.DOWN
var isAttacking: bool = false 
var meleeTimer: float = 0
var attackLockTimer: float = 0
var attackActiveTimer: float = 0
var swingStartAngle: float = 0
var swingEndAngle: float = 0
var isDashing: bool = false
var dashTimer: float = 0
var dashDirection: Vector2 = Vector2.ZERO
var dashCooldownTimer: float = 0
var carried: Node2D = null

func meleeAttack():
	if meleeTimer > 0:
		return

	meleeTimer = meleeCooldown
	isAttacking = true

	attackLockTimer = attackLockTime
	attackActiveTimer = attackActiveTime

	var baseAngle = facingDir.normalized().angle()
	var arcRadians = deg_to_rad(swingArc)

	swingStartAngle = baseAngle - arcRadians / 2.0
	swingEndAngle = baseAngle + arcRadians / 2.0

	swingPivot.rotation = swingStartAngle
	meleeHitbox.monitoring = true
	swordVFX.visible = true
	sfxSword.play()

func updateTimers(delta: float):
	# Dash cooldown
	if dashCooldownTimer > 0:
		dashCooldownTimer -= delta
		if dashCooldownTimer < 0:
			dashCooldownTimer = 0

	# Melee cooldown
	if meleeTimer > 0:
		meleeTimer -= delta
		if meleeTimer < 0:
			meleeTimer = 0

	# Attack lock
	if attackLockTimer > 0:
		attackLockTimer -= delta
		if attackLockTimer <= 0:
			isAttacking = false

	# Attack active + swing arc
	if attackActiveTimer > 0:
		attackActiveTimer -= delta

		var t = 1.0 - (attackActiveTimer / attackActiveTime)
		t = clamp(t, 0.0, 1.0)

		swingPivot.rotation = lerp(swingStartAngle, swingEndAngle, t)

		if attackActiveTimer <= 0:
			meleeHitbox.monitoring = false
			swordVFX.visible = false

	
	if isDashing:
		dashTimer -= delta
		if dashTimer <= 0:
			isDashing = false

func startDash(direction: Vector2) -> void:
	isDashing = true
	dashTimer = dashTime
	dashCooldownTimer = dashCooldown

	if direction == Vector2.ZERO:
		direction = facingDir

	dashDirection = direction.normalized()
	velocity = dashDirection * dashSpeed
	sfxDash.play()

func try_pickup(body: Node2D) -> void:
	if carried != null:
		return
	if body == null:
		return
	if not body.is_in_group("pickup"):
		return

	# Tell the object to attach to us
	body.call("attach_to", carryPoint)
	carried = body

func drop_carried() -> void:
	if carried == null:
		return

	# Drop at carry point position (slightly below so it doesn't overlap player)
	carried.call("detach", global_position)
	carried = null

func _ready() -> void:
	swordVFX.visible = false
	meleeHitbox.monitoring = false
	
	if Global.next_spawn_position != Vector2.ZERO:
		global_position = Global.next_spawn_position
	
	var g := get_node_or_null("/root/Global")
	if g != null and g.next_spawn_position != Vector2.ZERO:
		global_position = g.next_spawn_position

func _physics_process(delta: float) -> void:
	var inputDir: Vector2 = Input.get_vector("Left", "Right", "Up", "Down")
	if inputDir != Vector2.ZERO:
		facingDir = inputDir.normalized()

	updateTimers(delta)
	
	if inputDir == Vector2(-1,0):
		animation.play("run_l")
	elif inputDir == Vector2(1,0):
		animation.play("run_r")
	elif inputDir == Vector2(0,-1):
		animation.play("run_b")
	elif inputDir == Vector2(0,1):
		animation.play("run_f")
	elif facingDir == Vector2(-1,0) and  inputDir == Vector2.ZERO:
		animation.play("idle_l")
	elif facingDir == Vector2(1,0) and  inputDir == Vector2.ZERO:
		animation.play("idle_r")
	elif facingDir == Vector2(0,-1) and  inputDir == Vector2.ZERO:
		animation.play("idle_b")
	elif facingDir == Vector2(0,1) and inputDir == Vector2.ZERO:
		animation.play("idle_f")
		
	
		

	if Input.is_action_just_pressed("Attack"):
		meleeAttack()

	if Input.is_action_just_pressed("Reset"):
		get_tree().reload_current_scene()

	if Input.is_action_just_pressed("Dash") and dashCooldownTimer <= 0 and not isDashing:
		startDash(inputDir)
	
	if Input.is_action_just_pressed("Interact"):
		if carried != null:
			drop_carried()

	# Movement: dash wins while active
	if isDashing:
		velocity = dashDirection * dashSpeed
	else:
		velocity = inputDir * speed

	move_and_slide()
