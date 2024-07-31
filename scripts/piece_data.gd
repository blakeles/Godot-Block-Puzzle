extends Node2D

const BLOCK_SIZE = 16 # Sprite is 16x16
const PIECE_TYPES = [ # Hold vector positions of where each block in a piece should be
	[Vector2i(0,0)], # Single cube
	[Vector2i(0,0), Vector2i(1,0), Vector2i(0,1), Vector2i(1,1)], # 2x2 cube 
	[Vector2i(0,0), Vector2i(0,1)], # Vertical line of 2
	[Vector2i(0,0), Vector2i(1,0)], # Horizontal line of 2
	[Vector2i(0,-1), Vector2i(0,0), Vector2i(0,1)], # Vertical line of 3
	[Vector2i(-1,0), Vector2i(0,0), Vector2i(1,0)], # Horizontal line of 3
	[Vector2i(0,-1), Vector2i(0,0), Vector2i(0,1), Vector2i(0,2)], # Vertical line of 4
	[Vector2i(-1,0), Vector2i(0,0), Vector2i(1,0), Vector2i(2,0)], # Horizontal line of 4
	[Vector2i(-1,0), Vector2i(0,0), Vector2i(1,0), Vector2i(1,-1)], # --/
	[Vector2i(-1,0), Vector2i(0,0), Vector2i(1,0), Vector2i(-1,-1)], # \--
	[Vector2i(-1,0), Vector2i(0,0), Vector2i(1,0), Vector2i(1,-1)], # --\
	[Vector2i(-1,0), Vector2i(0,0), Vector2i(1,0), Vector2i(-1,1)], # /--
	[Vector2i(-1,0), Vector2i(0,0), Vector2i(1,0), Vector2i(1,1)], # --/
	[Vector2i(0,-1), Vector2i(0,0), Vector2i(0,1), Vector2i(-1,-1)], # -\
	[Vector2i(0,-1), Vector2i(0,0), Vector2i(0,1), Vector2i(-1,1)], # _\
	[Vector2i(0,-1), Vector2i(0,0), Vector2i(0,1), Vector2i(1,-1)],# /-
	[Vector2i(0,-1), Vector2i(0,0), Vector2i(0,1), Vector2i(1,1)], # /_
	[Vector2i(-1,1), Vector2i(-1,0), Vector2i(0,0), Vector2i(0,-1)], # S
	[Vector2i(1,1), Vector2i(1,0), Vector2i(0,0), Vector2i(0,-1)], # Back S
	[Vector2i(-1,0), Vector2i(0,0), Vector2i(0,1), Vector2i(1,1)], # Z
	[Vector2i(-1,0), Vector2i(0,0), Vector2i(0,-1), Vector2i(1,-1)], # Back Z
	[Vector2i(-1,0), Vector2i(0,0), Vector2i(1,0), Vector2i(0,-1)], # _|_
	[Vector2i(-1,0), Vector2i(0,0), Vector2i(1,0), Vector2i(0,1)], # -|-
	[Vector2i(-1,1), Vector2i(-1,0), Vector2i(-1,-1), Vector2i(0,0)], # |-
	[Vector2i(1,1), Vector2i(1,0), Vector2i(1,-1), Vector2i(0,0)] # -|
]

''' Pieces that could be implemented in a future "hard" mode
	[Vector2i(-1,-1), Vector2i(0,-1), Vector2i(1,-1), Vector2i(-1,0), Vector2i(0,0), Vector2i(1,0), Vector2i(-1,1), Vector2i(0,1), Vector2i(1,1)],	# 3x3 cube
	[Vector2i(-1,-1), Vector2i(-1,0), Vector2i(-1,1), Vector2i(0,-1), Vector2i(1,-1)], # //--
	[Vector2i(-1,-1), Vector2i(-1,0), Vector2i(-1,1), Vector2i(0,1), Vector2i(1,1)], # //__
	[Vector2i(1,-1), Vector2i(1,0), Vector2i(1,1), Vector2i(0,-1), Vector2i(-1,-1)], # --//
	[Vector2i(1,-1), Vector2i(1,0), Vector2i(1,1), Vector2i(0,1), Vector2i(-1,1)] # __//
'''

''' FOR BLOCK POSITIONING
- X L->R = -1 -> 1
- Y B->T = 1 -> -1
- So bottom left block = X-1, Y1
'''

var blockScene = preload("res://scenes/block.tscn")
var pieceBlocks = [] # Holds the references to the blocks in the piece

var chosenColour : String # The colour of every block in the piece
var chosenPiece : Array # The position of each block in the piece
var returnPosition : Vector2 # The global position that the piece should be returned to when it is released
var dragging : bool = false # Whether the piece is currently being dragged
var draggingPosition : Vector2 # Which block in the piece is being dragged
var forShow : bool = false # ONLY CHANGE IF PIECE IS ON MAIN SCREEN

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if dragging:
		# Piece follows depending on which piece is being dragged 
		global_position = get_viewport().get_mouse_position() - draggingPosition*4
		scale = Vector2(1.5, 1.5)
		get_parent().handle_hover({'blockSelected': draggingPosition/BLOCK_SIZE, 'piece': self})
		
'''
start_drag
- Sets the piece to its 'dragging' state

stop_drag
- Sets the piece to its default state
'''
func start_drag(blockPosition : Vector2):
	if !forShow:
		dragging = true
		draggingPosition = blockPosition
		z_index = 2
func stop_drag(unclickPosition : Vector2):
	if !forShow:
		if await get_parent().handle_place_piece({'unclick': unclickPosition, 'blockSelected': draggingPosition/BLOCK_SIZE, 'piece': self}):
			queue_free() # Delete piece from scene if it has been placed
		else:
			dragging = false
			global_position = returnPosition
			scale = Vector2(1, 1)
			z_index = 0
			
'''
spawn
- Spawn piece into scene
- Colour of piece is determined by the first block
'''
func spawn(spawnedPosition : Vector2, menu : bool):
	returnPosition = spawnedPosition
	chosenPiece = PIECE_TYPES.pick_random()
	
	if !menu: forShow = false
	else: forShow = true
	
	for block in chosenPiece:
		var blockInstance = blockScene.instantiate()
		pieceBlocks.append(blockInstance)
		add_child(blockInstance)
		blockInstance.position = block*BLOCK_SIZE
		if !chosenColour:
			blockInstance.activate("black", true)
			chosenColour = blockInstance.get_colour()
		else:
			blockInstance.activate(chosenColour, true)
			
'''
get_colour
- Returns the colour of the piece
'''
func get_colour():
	return chosenColour
