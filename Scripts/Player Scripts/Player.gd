extends CharacterBody2D

@export var speed: float = 300
@export var dashSpeed: float = 600

@onready var meleeHitbox = $MeleePivot/MeleeHitbox
@onready var swordVFX = $MeleePivot/SwordVFX
@onready var swingPivot = $MeleePivot 
@onready var sfxSword = $"SFX Manager/swordSFX"
@onready var sfxDash = $"SFX Manager/sfxDash"

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


func meleeAttack():
	if meleeTimer > 0:
		return
	
	meleeTimer = meleeCooldown
	isAttacking = true
	
	attackLockTimer = attackLockTime
	attackActiveTimer = attackActiveTime
	
	var baseAngle = facingDir.normalized().angle()
	var arcRadians = deg_to_rad(swingArc)
	
	# Left → Right relative to facing
	swingStartAngle = baseAngle - arcRadians / 2.0
	swingEndAngle = baseAngle + arcRadians / 2.0
	
	# Reset pivot rotation; hitbox and VFX follow pivot
	swingPivot.rotation = swingStartAngle
	meleeHitbox.monitoring = true
	swordVFX.visible = true
	sfxSword.play();

func updateTimers(delta: float):
	if dashCooldownTimer > 0:
		dashCooldownTimer -= delta
	# COOLDOWN TICK
	if meleeTimer > 0:
		meleeTimer -= delta
		if meleeTimer < 0:
			meleeTimer = 0

	if attackLockTimer > 0:
		attackLockTimer -= delta
		if attackLockTimer <= 0:
			isAttacking = false

	# HANDLE SWING ARC USING PIVOT
	if attackActiveTimer > 0:
		attackActiveTimer -= delta

		var t = 1.0 - (attackActiveTimer / attackActiveTime)
		t = clamp(t, 0.0, 1.0)

		swingPivot.rotation = lerp(swingStartAngle, swingEndAngle, t)

		if attackActiveTimer <= 0:
			meleeHitbox.monitoring = false
			swordVFX.visible = false

func startDash(direction: Vector2) -> void:
	isDashing = true
	dashTimer = dashTime
	dashCooldownTimer = dashCooldown
	
	if direction == Vector2.ZERO:
		direction = facingDir
	
	dashDirection = direction.normalized()
	velocity = dashDirection * dashSpeed
	sfxDash.play()

func _ready() -> void:
	swordVFX.visible = false
	meleeHitbox.monitoring = false

func _physics_process(delta: float) -> void:
	var inputDir: Vector2 = Input.get_vector("Left","Right","Up","Down")
	if inputDir != Vector2.ZERO:
		facingDir = inputDir.normalized()
	
	updateTimers(delta)
	
	if Input.is_action_just_pressed("Attack"):
		meleeAttack()
	
	if Input.is_action_just_pressed("Reset"):
		get_tree().reload_current_scene()
	
	if Input.is_action_just_pressed("Dash") && dashCooldownTimer <= 0:
		startDash(inputDir)
	
	velocity = inputDir * speed
	
	
	
	move_and_slide()
