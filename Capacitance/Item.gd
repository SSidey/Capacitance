extends Area2D

var isActive = false

func _on_Item_area_entered(area):
	isActive = true

func _on_Item_area_exited(area):
	isActive = false

func _on_Player_take():
	if isActive:
		self.queue_free()
