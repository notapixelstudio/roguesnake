extends Line2D
class_name Snake

var head_position := Vector2(20, 10)
var direction := 'right'
var next_direction := direction
var alive := true
var occupied_cells := []

var length := 0
var max_length := 4

const cellsize := 16 # TBD configuration

func _ready():
	update_tail()
	Events.connect("tick", self, '_on_tick')
	
func _on_tick():
	if alive:
		move()
		
	if alive:
		update_tail()

func move():
	match next_direction:
		'up': head_position += Vector2(0,-1)
		'down': head_position += Vector2(0,1)
		'right': head_position += Vector2(1,0)
		'left': head_position += Vector2(-1,0)
	direction = next_direction
	Events.emit_signal("snake_moved", head_position)
	
func update_tail():
	if length > max_length:
		occupied_cells.pop_front()
		self.remove_point(0)
	else:
		length += 1
	occupied_cells.append(head_position)
	self.add_point((head_position+Vector2(0.5,0.5))*cellsize)

func _unhandled_key_input(event):
	if direction in ['left', 'right']:
		if event.is_action_pressed("ui_up"):
			next_direction = 'up'
		elif event.is_action_pressed("ui_down"):
			next_direction = 'down'
	
	if direction in ['up', 'down']:
		if event.is_action_pressed("ui_right"):
			next_direction = 'right'
		elif event.is_action_pressed("ui_left"):
			next_direction = 'left'

func die():
	alive = false

func grow(amount):
	max_length += amount
	
func is_over_cell(cell : Vector2) -> bool:
	return occupied_cells.has(cell)
