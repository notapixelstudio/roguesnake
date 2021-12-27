extends Line2D
class_name Snake

var head_position := Vector2(20, 10)
var direction := 'right'
var commands := []
var alive := true
var occupied_cells := []

var length := 0
var max_length := 3

const cellsize := 64 # TBD configuration

func _ready():
	update_tail()
	Events.connect("tick", self, '_on_tick')
	
func _on_tick():
	if alive:
		move()
		
	if alive:
		update_tail()

func move():
	while len(commands) > 0:
		var new_direction = commands.pop_back()
		
		# skip commands that are useless or that would result in a trivial self-kill
		if direction in ['left', 'right'] and new_direction in ['up', 'down']:
			direction = new_direction
			break
		if direction in ['up', 'down'] and new_direction in ['left', 'right']:
			direction = new_direction
			break
		
	match direction:
		'up': head_position += Vector2(0,-1)
		'down': head_position += Vector2(0,1)
		'right': head_position += Vector2(1,0)
		'left': head_position += Vector2(-1,0)
	Events.emit_signal("snake_moved", head_position)
	
func update_tail():
	if length >= max_length:
		occupied_cells.pop_front()
		self.remove_point(0)
	else:
		length += 1
	occupied_cells.append(head_position)
	self.add_point((head_position+Vector2(0.5,0.5))*cellsize)
	
	$Head.position = (head_position+Vector2(0.5,0.5))*cellsize
	$DeadHead.position = $Head.position

func _unhandled_key_input(event):
	if event.is_action_pressed("ui_up"):
		_queue_command('up')
	elif event.is_action_pressed("ui_down"):
		_queue_command('down')
	elif event.is_action_pressed("ui_right"):
		_queue_command('right')
	elif event.is_action_pressed("ui_left"):
		_queue_command('left')

func _queue_command(dir):
	commands.push_front(dir)
	# keep max 2 commands
	commands.slice(0,2)

func die():
	alive = false
	$DeadHead.visible = true
	$Head.visible = false

func grow(amount):
	max_length += amount
	
func is_over_cell(cell : Vector2) -> bool:
	return occupied_cells.has(cell)

func get_head_position() -> Vector2:
	return head_position
	
