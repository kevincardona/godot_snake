extends Node2D

enum Direction { UP, DOWN, LEFT, RIGHT }

var snake_segments = []
var snake_direction = Direction.RIGHT
var segment_size = Vector2(32, 32)
var game_size = Vector2(40,22)

var food = null
var score = 0

func _ready():
	initialize_game_area()
	spawn_food()
	add_snake_segment(Vector2(5, 5))
	$Timer.timeout.connect(on_SnakeMoveTimer_timeout)
	
func initialize_game_area():
	var top_border = create_border(Vector2(game_size.x / 2, 0.5), Vector2(game_size.x, 1))
	var bottom_border = create_border(Vector2(game_size.x / 2, game_size.y - 0.5), Vector2(game_size.x, 1))
	var left_border = create_border(Vector2(0.5, game_size.y / 2), Vector2(1, game_size.y))
	var right_border = create_border(Vector2(game_size.x - 0.5, game_size.y / 2), Vector2(1, game_size.y))
	
func check_border_collision():
	var head_grid_position = snake_segments[0].position / segment_size
	if head_grid_position.x < 0 or head_grid_position.x >= game_size.x or head_grid_position.y < 0 or head_grid_position.y >= game_size.y:
		print("Resetting")
		reset_game()


func create_border(position, size):
	var border = Area2D.new()
	var shape = CollisionShape2D.new()
	shape.shape = RectangleShape2D.new()
	shape.shape.extents = size * segment_size * 0.5
	border.add_child(shape)
	border.position = position * segment_size
	self.add_child(border)
	return border

func spawn_food():
	food = $SnakeSegment.duplicate()
	food.modulate = Color(1, 0, 0)  # Make the food red for distinction
	var food_position = Vector2(randi() % int(game_size.x), randi() % int(game_size.y))
	food.position = food_position * segment_size
	add_child(food)

func check_self_collision():
	var head_position = snake_segments[0].position
	for i in range(1, snake_segments.size()):
		if snake_segments[i].position == head_position:
			print("Self-collision detected")
			reset_game()
			break

func check_food_collision():
	if snake_segments[0].position == food.position:
		food.queue_free()
		add_snake_segment(snake_segments[-1].position)
		score += 1
		$Score.text = "[center]%d[/center]" % score
		spawn_food()

func reset_game():
	for segment in snake_segments:
		segment.queue_free()
	snake_segments = []
	add_snake_segment(Vector2(5, 5))
	snake_direction = Direction.RIGHT
	if food:
		food.queue_free()
		spawn_food()
	score = 0
	$Score.text = "[center]0"

func _physics_process(delta):
	if Input.is_action_pressed("ui_up") and snake_direction != Direction.DOWN:
		snake_direction = Direction.UP
	elif Input.is_action_pressed("ui_down") and snake_direction != Direction.UP:
		snake_direction = Direction.DOWN
	elif Input.is_action_pressed("ui_left") and snake_direction != Direction.RIGHT:
		snake_direction = Direction.LEFT
	elif Input.is_action_pressed("ui_right") and snake_direction != Direction.LEFT:
		snake_direction = Direction.RIGHT

func on_SnakeMoveTimer_timeout():
	move_snake()
	check_food_collision()
	check_border_collision()
	check_self_collision()

func add_snake_segment(position):
	var segment = $SnakeSegment.duplicate()
	segment.position = position * segment_size
	snake_segments.append(segment)
	add_child(segment)

func move_snake():
	var head_position = snake_segments[0].position
	match snake_direction:
		Direction.UP:
			head_position.y -= segment_size.y
		Direction.DOWN:
			head_position.y += segment_size.y
		Direction.LEFT:
			head_position.x -= segment_size.x
		Direction.RIGHT:
			head_position.x += segment_size.x
	
	for i in range(snake_segments.size() - 1, 0, -1):
		snake_segments[i].position = snake_segments[i-1].position
		
	snake_segments[0].position = head_position
	
