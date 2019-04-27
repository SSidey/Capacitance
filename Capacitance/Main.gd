extends Node2D

func _ready():
	set_process_input(true)

func _handle_input():
	var text = $InputTerminal/TextField.text
	$Player.handle_input_text(text)

func _on_TextureRect_gui_input(event):
	if event is InputEventMouseButton && event.button_index == BUTTON_LEFT && event.pressed:
		$InputTerminal/TextField.release_focus()
		$Player.handleBoundActions = true

func _terminal_message_received(message):
	$InputTerminal/TextField.text = message

func _on_InputTerminal_focus_terminal():
	$Player.handleBoundActions = false
