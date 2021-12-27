extends Polygon2D

signal done

func _unhandled_key_input(event):
	if event.is_action_pressed("ui_accept"):
		emit_signal("done")
		
