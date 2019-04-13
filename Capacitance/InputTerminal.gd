extends Panel

signal handle_input

func _on_EnterButton_pressed():
	handleInput()

func handleInput():
	emit_signal("handle_input")