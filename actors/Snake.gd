extends Line2D
class_name Snake

var head_cell := Vector2(20, 10)
var head_position := Global.cell2p(head_cell)
var direction := Vector2.RIGHT
var commands := []
var has_command := false
var alive := true
var occupied_cells := [head_cell]

var length := 0
var max_length := 3
var speed := 0.2 # cells per second

func _ready():
	self._update_occupied_cells()

func _execute_queued_command():
	while len(commands) > 0:
		var command = commands.pop_back()
		var done = self._execute_command(command)
		if done:
			break
			
	if len(commands) == 0:
		has_command = false
		
func _execute_command(command):
	# skip commands that are useless or that would result in a trivial self-kill
	if direction.y == 0 and command.x == 0:
		direction = command
		head_position.x = Global.cell2p(head_cell).x # snap to grid
		return true
	if direction.x == 0 and command.y == 0:
		direction = command
		head_position.y = Global.cell2p(head_cell).y # snap to grid
		return true
		
	return false
	
func _process(delta):
	if not alive:
		return
		
	head_position += direction*speed*Global.cellsize*delta
	
	var new_head_cell = Global.p2cell(head_position)
	if new_head_cell != head_cell:
		head_cell = new_head_cell
		self._execute_queued_command()
		Events.emit_signal("snake_moved", head_cell)
		self._update_occupied_cells()
		
	self._update_tail()
	
	if $Debug.visible:
		$Debug/HeadPosition.position = head_position
		$Debug/HeadCell.position = Global.cell2p(head_cell)
		
		for point in $Debug/Points.get_children():
			$Debug/Points.remove_child(point)
			
		for p in self.points:
			var point := Line2D.new()
			point.begin_cap_mode = Line2D.LINE_CAP_ROUND
			point.end_cap_mode = Line2D.LINE_CAP_ROUND
			point.points = PoolVector2Array([p,p+Vector2(1,1)])
			point.z_index = 1000
			point.z_as_relative = false
			point.width = 20
			point.default_color = Color.red
			point.modulate = Color(1,1,1,0.6)
			$Debug/Points.add_child(point)
			
		for point in $Debug/OccupiedCells.get_children():
			$Debug/OccupiedCells.remove_child(point)
			
		for cell in self.occupied_cells:
			var p := Global.cell2p(cell)
			var point := Line2D.new()
			point.begin_cap_mode = Line2D.LINE_CAP_ROUND
			point.end_cap_mode = Line2D.LINE_CAP_ROUND
			point.points = PoolVector2Array([p,p+Vector2(1,1)])
			point.z_index = 900
			point.z_as_relative = false
			point.width = 60
			point.default_color = Color.green
			point.modulate = Color(1,1,1,0.6)
			$Debug/OccupiedCells.add_child(point)
	
func set_last_point_position(pos : Vector2) -> void:
	self.set_point_position(self.get_point_count()-1, pos)
	
func _update_occupied_cells():
	if length >= max_length:
		occupied_cells.pop_front()
	else:
		length += 1
		
	if head_cell != occupied_cells[-1]:
		occupied_cells.append(head_cell)
	
func _update_tail():
	self.clear_points()
	for cell in self.occupied_cells:
		var p := Global.cell2p(cell)
		self.add_point(p)
	self.add_point(head_position + direction*0.5*Global.cellsize)
	
"""
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
"""

func _unhandled_key_input(event):
	if event.is_action_pressed("ui_up"):
		_queue_command(Vector2.UP)
	elif event.is_action_pressed("ui_down"):
		_queue_command(Vector2.DOWN)
	elif event.is_action_pressed("ui_right"):
		_queue_command(Vector2.RIGHT)
	elif event.is_action_pressed("ui_left"):
		_queue_command(Vector2.LEFT)
		

func _queue_command(command):
	# execute right now if this is the first command while in this cell
	if not has_command:
		_execute_command(command)
		has_command = true
		
	commands.push_front(command)
	# keep max 2 queued commands
	commands = commands.slice(0,1)

func die():
	alive = false
	#$DeadHead.visible = true
	#$Head.visible = false

func grow(amount):
	max_length += amount
	
func is_over_cell(cell : Vector2) -> bool:
	return occupied_cells.has(cell)

func get_head_cell() -> Vector2:
	return head_cell
	
