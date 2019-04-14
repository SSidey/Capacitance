extends Area2D

var isActive = false

func _on_Button_area_entered(area):
	isActive = true

func _on_Button_area_exited(area):
	isActive = false

func _on_Player_use():
	$AnimatedSprite.flip_h = !($AnimatedSprite.flip_h)