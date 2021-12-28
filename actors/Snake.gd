extends Line2D
class_name Snake

var head_cell := Vector2(20, 10)
var direction := Vector2.RIGHT
var commands := []
var alive := true
var occupied_cells := [head_cell]

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
		if direction.y == 0 and new_direction.x == 0:
			direction = new_direction
			break
		if direction.x == 0 and new_direction.y == 0:
			direction = new_direction
			break
		
	head_cell += direction
	Events.emit_signal("snake_moved", head_cell)
	
func get_last_point_position() -> Vector2:
	return self.get_point_position(self.get_point_count()-1)
	
func set_last_point_position(pos : Vector2) -> void:
	self.set_point_position(self.get_point_count()-1, pos)
	
func update_tail():
	# update tail
	if length >= max_length:
		occupied_cells.pop_front()
		self.remove_point(0)
	else:
		length += 1
		
	# update continuous movement
	previous_head_cell = occupied_cells[-1]
	occupied_cells.append(head_cell)
	self.set_last_point_position(Global.cell2p(previous_head_cell))
	self.add_point(Global.cell2p(previous_head_cell))
	
var tick := 0.3
var t := 0.0
var previous_head_cell : Vector2
func _process(delta):
	t += delta
	if alive and previous_head_cell:
		var weight := t/tick - floor(t/tick)
		var starting_position := Global.cell2p(previous_head_cell)
		var final_position := Global.cell2p(head_cell)
		var interpolated_position = lerp(starting_position, final_position, weight)
		self.set_last_point_position(interpolated_position)
		$Head.position = interpolated_position
		$DeadHead.position = interpolated_position

func _unhandled_key_input(event):
	if event.is_action_pressed("ui_up"):
		_queue_command(Vector2.UP)
	elif event.is_action_pressed("ui_down"):
		_queue_command(Vector2.DOWN)
	elif event.is_action_pressed("ui_right"):
		_queue_command(Vector2.RIGHT)
	elif event.is_action_pressed("ui_left"):
		_queue_command(Vector2.LEFT)

func _queue_command(dir):
	commands.push_front(dir)
	# keep max 2 commands
	commands = commands.slice(0,1)

func die():
	alive = false
	$DeadHead.visible = true
	$Head.visible = false

func grow(amount):
	max_length += amount
	
func is_over_cell(cell : Vector2) -> bool:
	return occupied_cells.has(cell)

func get_head_cell() -> Vector2:
	return head_cell
	
