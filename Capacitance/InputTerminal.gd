extends Panel

signal handle_input
signal focus_terminal

func _on_EnterButton_pressed():
	handleInput()

func handleInput():
	emit_signal("handle_input")

func _on_TextField_gui_input(event):
	if event is InputEventMouseButton && event.button_index == BUTTON_LEFT && event.pressed:
		emit_signal("focus_terminal")