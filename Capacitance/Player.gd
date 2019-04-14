extends KinematicBody2D

var _name = "player"
var _class = "mobile"
var speed = 200
var velocity = Vector2()
var _actions = []
var canInteract = false

signal use
signal take

func _ready():
	$Panel.hide()
	_actions.append("print")
	_actions.append("move")
	_actions.append("take")
	_actions.append("use")
	_actions.append("help")

func _physics_process(delta):
	if velocity.length() > 0:
		var normalised = velocity.normalized() * speed * delta
		self.move_and_collide(normalised)

func _on_Area2D_area_entered(area):
	canInteract = true

func _on_Area2D_area_exited(area):
	canInteract = false

func _print(text):
	$Panel.show()
	$Panel/Label.text = text[0]

func _move(vector):
	velocity.x = float(vector[0])
	velocity.y = float(vector[1]) * -1

func _use(arg):
	if canInteract:
		emit_signal("use")
	else:
		$Panel.show()
		$Panel/Label.text = "There's nothing to use"

func _take(arg):
	if canInteract:
		emit_signal("take")
	else:
		$Panel.show()
		$Panel/Label.text = "There's nothing to take"

func _help(arg):
	$Panel.show()
	$Panel/Label.text = "player. ~print(\"\"), ~move(1,1), ~use(), ~take()"