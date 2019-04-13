extends KinematicBody2D

var _name = "player"
var _class = "mobile"
var speed = 200
var velocity = Vector2()
var _actions = []

func _ready():
	$Panel.hide()
	_actions.append("print")
	_actions.append("move")

func _print(text):
	$Panel.show()
	$Panel/Label.text = text[0]

func _move(vector):
	velocity.x = float(vector[0])
	velocity.y = float(vector[1]) * -1

func _physics_process(delta):
	if velocity.length() > 0:
		var normalised = velocity.normalized() * speed * delta
		self.move_and_collide(normalised)