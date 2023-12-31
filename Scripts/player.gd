extends CharacterBody3D

@onready var animated_sprite_2d: AnimatedSprite2D = $UI/GunBase/AnimatedSprite2D
@onready var ray_cast_3d: RayCast3D = $RayCast3D
@onready var shoot_sound: AudioStreamPlayer = $ShootSound

@export_group("Player Properties")
## Set speed for the player.
@export var SPEED: float = 5.0
## Set mouse sensitivity for the player.
@export var MOUSE_SENSITIVITY: float = 0.5

var can_shoot = true
var dead = false

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	animated_sprite_2d.animation_finished.connect(_shoot_anim_done)
	$UI/GunBase/DeathScreen/Panel/Button.button_up.connect(_restart)
	
func _input(event: InputEvent) -> void:
	if dead:
		return
	if event is InputEventMouseMotion:
		rotation_degrees.y -= event.relative.x * MOUSE_SENSITIVITY
	
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("exit"):
		get_tree().quit()
	if Input.is_action_just_pressed("restart"):
		_restart()
	if dead:
		return
	if Input.is_action_just_pressed("shoot"):
		_shoot()
	
func _physics_process(delta: float) -> void:
	if dead:
		return
	var input_dir := Input.get_vector("move_left", "move_right", "move_forwads", "move_backwards")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()


func _restart():
	get_tree().reload_current_scene()


func _shoot():
	if !can_shoot:
		return
	can_shoot = false
	animated_sprite_2d.play("Shoot")
	shoot_sound.play()
	if ray_cast_3d.is_colliding() and ray_cast_3d.get_collider().has_method("_kill"):
		ray_cast_3d.get_collider()._kill()
		
		
func _shoot_anim_done():
	can_shoot = true

	
func _kill():
	dead = true
	$UI/GunBase/DeathScreen.show()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
