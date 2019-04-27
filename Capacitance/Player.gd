extends KinematicBody2D

var _name = "player"
var _class = "mobile"
var speed = 200
var velocity = Vector2()
var _actions = []
var actions = {}
var canInteract = false
var boundActions = {}
var userActions = {}
var classActions = {}
var handleBoundActions = true
var pressedActions = {}
var checkedActions = []
var validInputs = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]

signal use
signal take
signal terminalMessage(message)

func _ready():
	$Panel.hide()
	classActions["mobile"] = ["print", "help", "move", "use", "take", "bind"]
	connectSignals()
	populatePossibleActions()
	boundActions["w"] = "player.move(0,1))"
	boundActions["a"] = "player.move(-1,0))"
	boundActions["s"] = "player.move(0,-1))"
	boundActions["d"] = "player.move(1,0))"
	boundActions["u"] = "player.use()"
	boundActions["t"] = "player.use()"

func _physics_process(delta):
	resetState()
	if handleBoundActions:
		handleInputs()
	if velocity.length() > 0:
		var normalised = velocity.normalized() * speed * delta
		self.move_and_collide(normalised)

func resetState():
	velocity = Vector2()
	checkedActions = []

func _on_Area2D_area_entered(area):
	canInteract = true

func _on_Area2D_area_exited(area):
	canInteract = false

func _print(args: ActionArguments):
	if (skipAction("print")):
		return
	$Panel.show()
	$Panel/Label.text = args.arguments[0]

func _move(args: ActionArguments):
	velocity.x += float(args.arguments[0])
	velocity.y += float(args.arguments[1]) * -1
	handleDelegate("didMove", args.pressed)

func _use(args: ActionArguments):
	if (skipAction("use")):
		return
	if canInteract:
		emit_signal("use")
	else:
		$Panel.show()
		emit_signal("terminalMessage", "There's nothing to use")

func _take(args: ActionArguments):
	if (skipAction("take")):
		return
	if canInteract:
		emit_signal("take")
	else:
		emit_signal("terminalMessage", "There's nothing to take")

func _help(args: ActionArguments):
	if (skipAction("help")):
		return
	emit_signal("terminalMessage", "player. ~print(\"\"), ~move(1,1), ~use(), ~take()")

func _bind(args: ActionArguments):
	if (skipAction("bind")):
		return
	var binding = args.arguments[0]
	if binding.length() == 1:
		boundActions[binding.to_lower()] = args.arguments[1]
	else:
		$Panel.show()
		$Panel/Label.text = "Could not bind to " + binding

func handle_input_text(text: String, pressed = false):
	var isAction = text.find(_name) == 0
	var isFunc = text.find("func") == 0
	if isAction:
		handlePlayerAction(text, pressed)
	elif isFunc:
		handleFunc(text)

func handlePlayerAction(action: String, pressed):
	var text = action.split(".", false, 1)
	if text.size() == 1:
		emit_signal("terminalMessage", "Invalid declaration")
		return
	handleAction(text[1], pressed)

func handleAction(action: String, pressed):
	var parts = action.split("(", true, 1)
	if parts.size() == 2:
		var actionName = parts[0]
		var args = parts[1].trim_suffix(")")
		if _actions.has(actionName) && actions.has(actionName):
			var act = actions[actionName]
			var pArgArray = getArgs(args, act.argCount)
			var argArray = cleanArgs(pArgArray)
			if validParameters(argArray, act.argCount):
				var finalArgs = ActionArguments.new(pressed, argArray)
				act.funcRef.call_func(finalArgs)
				updateActionstate(actionName, pressed)
			else:
				emit_signal("terminalMessage", "Invalid parameters")
		elif userActions.has(actionName):
			var act = userActions[actionName]
			for funcLine in act.funcLines:
				handlePlayerAction(funcLine, pressed)
		else:
			emit_signal("terminalMessage", _name + " can't do that")
	else:
		emit_signal("terminalMessage", "Invalid declaration")

func handleDelegate(action: String, pressed):
	if userActions.has(action):
		handleAction(action + "()", pressed)

func updateActionstate(actionName: String, pressed):
	if(checkedActions.has(actionName)):
		return
	pressedActions[actionName] = pressed
	checkedActions.append(actionName)

func handleInputs():
	for validInput in validInputs:
		if Input.is_action_pressed(validInput):
			handleBoundAction(validInput.to_lower(), true)
	for validInput in validInputs:
		if Input.is_action_just_released(validInput):
			handleBoundAction(validInput.to_lower(), false)

func handleBoundAction(code: String, pressed: bool):
	if boundActions.has(code):
		handle_input_text(boundActions[code], pressed)

func skipAction(action: String):
	return actionIsPressed(action) || checkedActions.has(action)

func actionIsPressed(action: String):
	if (pressedActions.has(action)):
		return pressedActions[action]
	else:
		return false

func handleFunc(function: String):
	var text = function.trim_prefix("func")
	var parts = text.split("(", true, 1)
	if parts.size() == 2:
		var funcName = trimWhitespace(parts[0])
		var lines = parts[1].split(")", true, 1)
		var args = lines[0].split(",", false)
		var finalLines = trimWhitespace(lines[1]).trim_prefix("{").trim_suffix("}").replace("\"", "").c_escape()
		var funcsToCall = finalLines.split("\\n", false)
		userActions[funcName] = UserAction.new(funcName, args, funcsToCall)

func trimWhitespace(string: String):
	return removeWrappingCharacter(string, " ")

func removeWrappingCharacter(string: String, wrappingCharacter: String):
	var replacement = removeWrappingPair(string, wrappingCharacter, wrappingCharacter)
	return replacement

func removeWrappingPair(string: String, first: String, second: String):
	var replacement = string.trim_prefix(first).trim_suffix(second)
	return replacement 

func getArgs(args: String, argCount: int):
	var count = argCount if argCount == 0 else argCount - 1
	return args.split(",", false, count)

func cleanArgs(argArray: PoolStringArray):
	var args = []
	for arg in argArray:
		if arg != "":
			args.append(arg)	
	for i in range(0, args.size()):
		var noSpaces = trimWhitespace(args[i])
		args[i] = removeWrappingPair(noSpaces, "“", "”")
		args[i] = removeWrappingCharacter(args[i], "\"")
	return args

func validParameters(argArray: Array, expectedCount: int):
	return argArray.size() == expectedCount

func populatePossibleActions():
	populateAvailableActions(_class)
	populateAction("print", "_print", 1)
	populateAction("move", "_move", 2)
	populateAction("take", "_take", 0)
	populateAction("use", "_use", 0)
	populateAction("help", "_help", 0)
	populateAction("bind", "_bind", 2)

func populateAvailableActions(className: String):
	_actions = classActions[className]

func populateAction(alias: String, funcName: String, argCount: int):
	if(_actions.has(alias)):
		var funcRef = funcref(self, funcName)
		actions[alias] = Action.new(funcRef, argCount)

func connectSignals():
	if get_parent().has_method("_terminal_message_received"):
		 connect("terminalMessage", get_parent(), "_terminal_message_received")