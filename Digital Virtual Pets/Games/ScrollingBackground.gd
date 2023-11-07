extends Sprite2D

@export var scrollElements : Array[Node2D]
@export var isScrolling := false
@export var speed : float
@export_range(-1, 1) var direction : int

var validSetUp := false
var wrapPosns : Array[Vector2]

func _ready():
	self.ready.connect(startScrolling)
	
	if scrollElements.size() > 2:
		validSetUp = true
		wrapPosns += [scrollElements[0].position]
		wrapPosns += [scrollElements[scrollElements.size() - 1].position]

func startScrolling():
	isScrolling = true

func stopScrolling():
	isScrolling = false

func setSpeed(value : float):
	speed = value

func changeDirection():
	if direction > 0:
		direction = -1
	else:
		direction = 1

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if isScrolling and validSetUp:
		for element in scrollElements:
			element.position.x += speed * direction
			
			if direction == 1:
				if element.position.x > wrapPosns[0].x:
					element.position = wrapPosns[1]
			elif direction == -1:
				if element.position.x < wrapPosns[0].x:
					element.position = wrapPosns[1]
