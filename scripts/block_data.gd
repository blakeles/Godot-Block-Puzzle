extends Area2D

const BLOCK_HOVERED : Color = Color(0.98, 0.9, 0.8, 0.2) # A semi-transparent white, used for when this block is being hovered over
const BLOCK_EMPTY : Color = Color(0, 0, 0.5, 0.2) # A semi-transparent blue, used for when this block has not been 'placed'
const BLOCK_COLOURS : Array[String] = [ # Holds all possible colours a piece can be
	"red",
	"orange",
	"yellow",
	"green",
	"blue",
	"violet",
	"brown",
	"turquoise",
	"pink",
]

const VERTICES_BLOCK : PackedVector2Array = [Vector2i(-7,-7), Vector2i(7,-7), Vector2i(7,7), Vector2i(-7,7)]
const VERTICES_PIECE : PackedVector2Array = [Vector2i(-8,-8), Vector2i(8,-8), Vector2i(8,8), Vector2i(-8,8)]


var placed : bool = false # Whether this block is placed on the board or not
var active : bool = false # Whether this block is part of a piece or not
var hovered : bool = false # Whether this block is currently being hovered over
var chosenColour : String # The given colour of this block

# Called when the node enters the scene tree for the first time.
func _ready():
	set_empty()
	
func _input(event):
	if active: # Only blocks part of the piece can be dragged
		if event is InputEventMouseButton: # Add mobile functionality
			var dict = is_mouse_over(event.position) 
			if dict.get('truth') && self == dict.get('target'): # This ensures that the start and stop of the drag is only performed by the correct block
				if event.pressed:
					get_parent().start_drag(position)
				else:
					get_parent().stop_drag(event.global_position)

'''
activate
- Add block to the game (either as a placed block on the board, or as part of a piece)
- Collision polygon depends on whether the block is in a piece or not
- Oftentimes to choose a random colour I simply set colour to "black"
'''
func activate(colour : String, isPiece : bool):
	active = isPiece
	placed = !isPiece
	
	# Set collision polygon vertices
	if isPiece: $'CollisionPolygon2D'.polygon = VERTICES_PIECE
	else: $'CollisionPolygon2D'.polygon = VERTICES_BLOCK
	
	if BLOCK_COLOURS.has(colour):
		chosenColour = colour
		$'Sprite2D'.self_modulate = colour
	else: 
		chosenColour = BLOCK_COLOURS.pick_random()
		$'Sprite2D'.self_modulate = chosenColour
	
	if !isPiece: $'AnimationPlayer'.play("place")

'''
set_empty
- Set block to default block state (empty; blocks can be placed in it)

set_complete
- Call when block is in a complete row/column

become_hovered
- Call when a piece is being hovered over this piece, and that piece can be placed here
'''
func set_empty():
	placed = false
	active = false
	hovered = false
	$'Sprite2D'.self_modulate = BLOCK_EMPTY
	$Sprite2D.scale = Vector2(1,1)
func set_complete():
	$'AnimationPlayer'.play("clear")
	set_empty()
func become_hovered():
	hovered = true
	$'Sprite2D'.self_modulate = BLOCK_HOVERED

'''
get_global_pos
- Returns the global position of each corner of this block
- Used to check if a piece can be placed in all the required blocks
'''
func get_global_pos():
	var packedPoints = PackedVector2Array()
	for localPoint in $CollisionPolygon2D.polygon:
		packedPoints.append(to_global(localPoint))
		
	return packedPoints

'''
is_mouse_over
- Checks if a point (mousePosition) is within the bounds of the block
- Returns if it is and the block that the mouse is over
'''
func is_mouse_over(mousePosition : Vector2):
	return {'truth': Geometry2D.is_point_in_polygon(mousePosition, get_global_pos()), 'target': self}

'''
get_colour
- Returns the colour of this block

get_placement
- Returns if the block has been placed on the board or not
'''
func get_colour():
	return chosenColour
func get_placement():
	return placed
