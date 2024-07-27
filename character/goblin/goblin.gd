extends CharacterBody2D

const ATTACK_AREA: PackedScene = preload("res://character/goblin/enemy_attack_area.tscn")
const OFF_SET: Vector2 = Vector2(0, 31.5);
@export var move_speed: float = 185.0;
@export var distance_threshold: float = 60.0;
@export var health: int = 3;
@export var score: int = 1;
@onready var animation: AnimationPlayer = get_node("Animation");
@onready var texture: Sprite2D = get_node("Texture");
@onready var aux_animation: AnimationPlayer = get_node("AuxAnimationPlayer");
@onready var dust: GPUParticles2D = get_node("Dust");
const AUDIO_TEMPLATE: PackedScene =  preload("res://management/audio_template.tscn");
var player_ref: CharacterBody2D = null;
var can_die: bool = false;

func _physics_process(_delta: float) -> void:
	if can_die:
		return;
		
	if player_ref == null or player_ref.can_die:
		animate();
		return;
	
	move();
	


func move() -> void:
	var direction: Vector2 = global_position.direction_to(player_ref.global_position);
	var distance: float = global_position.distance_to(player_ref.global_position);
	
	if distance < distance_threshold:
		dust.emitting = false;
		animation.play("attack");
		return;
	
	velocity =  direction * move_speed;
	move_and_slide();
	animate();

func spawn_attack_area() -> void:
	var attack_area = ATTACK_AREA.instantiate();
	attack_area.position = OFF_SET;
	add_child(attack_area);

func animate() -> void:
	if velocity.x < 0:
		texture.flip_h = true;
	
	if velocity.x > 0:
		texture.flip_h = false;	
	
	if velocity != Vector2.ZERO:
		animation.play("run");
		dust.emitting = true;
		return;
	
	dust.emitting = false;
	animation.play("idle");


func on_detection_area_body_entered(body):
	player_ref = body;


func on_detection_area_body_exited(_body):
	player_ref = null;
	velocity = Vector2.ZERO;


func update_health(value: int) -> void:
	health -= value;
	if health <= 0:
		can_die = true;
		animation.play("dead");
		
		return;
	
	aux_animation.play("hit");


func on_animation_animation_finished(anim_name: String) -> void:
	if anim_name == "dead":
		transition_screen.player_score += score;
		get_tree().call_group("level", "increase_kill_count");
		get_tree().call_group("level", "update_score", transition_screen.player_score)
		queue_free();
		
func spawn_sfx(sfx_path: String) -> void:
	var sfx = AUDIO_TEMPLATE.instantiate();
	sfx.sfx_to_play = sfx_path;
	add_child(sfx);		
