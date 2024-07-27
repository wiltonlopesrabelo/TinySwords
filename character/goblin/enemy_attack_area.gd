extends Area2D

@export var damage: int = 1;
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func on_body_entered(body):
	body.update_health(damage);


func on_life_time_timeout() -> void:
	queue_free();
