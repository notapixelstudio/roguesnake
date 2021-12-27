extends Node2D

onready var room = $Room
onready var snake : Snake = $Snake

func _ready():
	Events.connect("snake_moved", self, '_on_snake_moved')
	
func _on_Timer_timeout():
	Events.emit_signal("tick")
	
func _on_snake_moved(cell):
	var tile = room.get_cellv(cell)
	
	if tile == 1 or snake.is_over_cell(cell):
		# wall or self
		snake.die()
	else:
		if tile == 6:
			# coin
			snake.grow(1)
			room.set_cellv(cell, -1)
		elif tile == 7:
			# speed
			$Timer.wait_time *= 0.7
			room.set_cellv(cell, -1)
			
func _unhandled_key_input(event):
	if event.is_action_pressed("ui_cancel"):
		get_tree().reload_current_scene()
