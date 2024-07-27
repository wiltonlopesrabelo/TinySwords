extends CharacterBody2D

const AUDIO_TEMPLATE: PackedScene =  preload("res://management/audio_template.tscn");
@export var move_speed: float = 245.0;
@export var damage: int = 1;
@export var health: int = 20;
@onready var dust: GPUParticles2D = get_node("Dust");
@onready var animation: AnimationPlayer = get_node("Animation");
@onready var texture: Sprite2D = get_node("Texture");
@onready var attack_area_collision: CollisionShape2D = get_node("AttackArea/Collision");
@onready var aux_animation: AnimationPlayer = get_node("AuxAnimationPlayer");
var can_atack: bool = true;
var can_die: bool = false;

func _ready() -> void:
	if transition_screen.player_health != 0:
		health = transition_screen.player_health;
		return;
		
	transition_screen.player_health = health;
	
	

func _physics_process(_delta: float) -> void:
	if not can_atack or can_die:
		return;
		
	move();
	animate();
	attack_handler();
	
func move() -> void:	
	var direction: Vector2 = get_direction();
	velocity = direction * move_speed;
	move_and_slide();
	
	
func get_direction() -> Vector2:
	return Vector2(
		Input.get_axis("move_left", "move_right"),
		Input.get_axis("move_up", "move_down"),
	).normalized();	
	
func animate() -> void:	
	if velocity.x > 0:
		texture.flip_h = false;
		attack_area_collision.position.x = 59;
	
	if velocity.x < 0:
		texture.flip_h = true;	
		attack_area_collision.position.x = -59;
		
	if velocity != Vector2.ZERO:
		animation.play("run");
		dust.emitting = true;
		return;
	
	dust.emitting = false;
	animation.play("idle");

func attack_handler() -> void:
	if Input.is_action_just_pressed("attack") and can_atack:
		can_atack = false;
		dust.emitting = false;
		animation.play("attack");


func on_animation_animation_finished(anim_name: String) -> void:
	match anim_name:
		"attack":
			can_atack = true;
		"dead":
			transition_screen.fade_in();
			transition_screen.player_health = 0;
			transition_screen.player_score = 0;


func on_attack_area_body_entered(body) -> void:
	body.update_health(damage);
	
func update_health(value: int) -> void:
	health -= value;
	
	transition_screen.player_health = health;
	get_tree().call_group("level", "update_health", health);
	
	if health <= 0:
		can_die = true;
		animation.play("dead");
		attack_area_collision.set_deferred("disabled", true);
		return;
	
	aux_animation.play("hit");

func spawn_sfx(sfx_path: String) -> void:
	var sfx = AUDIO_TEMPLATE.instantiate();
	sfx.sfx_to_play = sfx_path;
	add_child(sfx);
