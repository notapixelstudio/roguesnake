extends TileMap

var player_position = Vector2(20, 10)
var direction = 'right'
var evolving_cells = {}
var length = 6

func _ready():
	update_player()

func _on_Timer_timeout():
	move()

func move():
	match direction:
		'up': player_position += Vector2(0,-1)
		'down': player_position += Vector2(0,1)
		'right': player_position += Vector2(1,0)
		'left': player_position += Vector2(-1,0)
	update_player()
	
func evolve():
	for pos in evolving_cells.keys():
		var cell = evolving_cells[pos]
		cell.age += 1
		if cell.age >= length:
			self.set_cellv(pos, 5) # empty
			evolving_cells.erase(pos)
			
func update_player():
	var current_tile = self.get_cellv(player_position)
	if current_tile in [1,4]:
		# wall or self
		$Timer.stop()
	else:
		if current_tile == 6:
			# coin
			length += 1
		elif current_tile == 7:
			# speed
			$Timer.wait_time *= 0.7
		
		self.set_cellv(player_position, 4)
		evolving_cells[player_position] = {'age': 0}
		evolve()

func _unhandled_key_input(event):
	if direction in ['left', 'right']:
		if event.is_action_pressed("ui_up"):
			direction = 'up'
		elif event.is_action_pressed("ui_down"):
			direction = 'down'
	
	if direction in ['up', 'down']:
		if event.is_action_pressed("ui_right"):
			direction = 'right'
		elif event.is_action_pressed("ui_left"):
			direction = 'left'
	
	if event.is_action_pressed("ui_cancel"):
		get_tree().reload_current_scene()
