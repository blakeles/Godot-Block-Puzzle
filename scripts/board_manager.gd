extends Node

const BOARD_HEIGHT : int = 8
const BOARD_LENGTH : int = 8
const BLOCK_SIZE : int = 16

var blockScene = preload("res://scenes/block.tscn")
var boardPieces = [] # Holds references to each block on the board
var boardPositions = {} # Holds the reference of each board piece along with the coordinates of each of its corners

var score : int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	await create_board()
	check_board()

'''
create_blocks
- Instantiate board with blocks
'''
func create_board():
	for i in BOARD_HEIGHT:
		for j in BOARD_LENGTH:
			var blockInstance = blockScene.instantiate()
			boardPieces.append(blockInstance)
			add_child(blockInstance)
			blockInstance.position = Vector2i(j,i)*BLOCK_SIZE # Move block instance to new positon
			if randf() < 0.2: blockInstance.activate("black", false) # 20% chance for a block to start placed
			boardPositions[str(blockInstance)] = blockInstance.get_global_pos()
			
'''
update_score
- Changes the score
'''
func update_score(targetScore : int):
	var scoreText = score
	score = targetScore
	while scoreText < targetScore:
		await get_tree().create_timer(0.001).timeout
		scoreText += 1
		$'Score'.text = str(scoreText)

'''
check_board
- Check board for any complete rows or columns, then update score
'''
func check_board():
	var currentScore = 0
	var blocksToRemove = do_check_xy(false)
	blocksToRemove.append_array(do_check_xy(true))
	
	if blocksToRemove:
		for block in blocksToRemove:
			await get_tree().create_timer(0.001).timeout
			block.set_complete()
			currentScore += 1
		currentScore += ((currentScore / 7) * 100)
		update_score(currentScore+score)
		
	for block in boardPieces:
		if block.get_placement():
			return
	update_score(1000+score)
	
'''
do_check_xy
- Do the complete check of either rows or columns
'''
func do_check_xy(flip : bool):
	var blocksXY = []
	var currentRow : int
	var currentBlock = boardPieces[0]
	
	for row in BOARD_HEIGHT:
		var blocks = []
		for column in BOARD_LENGTH:
			if flip == false:
				currentRow = row * BOARD_LENGTH
				currentBlock = boardPieces[currentRow+column]
			else: 
				currentRow = column * BOARD_HEIGHT
				currentBlock = boardPieces[row+currentRow]
			
			if currentBlock.get_placement():
				blocks.append(currentBlock)
			else:
				break
				
		if blocks.size() == BOARD_HEIGHT: blocksXY.append_array(blocks)

	return blocksXY
	
'''
can_still_play
- Given the pieces still available, can any play still be made? Return true if yes, false if no
'''
func can_still_play(pieces : Array):
	for piece in pieces:
		for block in boardPieces:
			var blockCoordinates = find_coordinates(block.global_position, Vector2(0,0), piece.chosenPiece)
			var blocksToPlace = check_place(blockCoordinates)
					
			if blocksToPlace.size() == piece.chosenPiece.size():
				print("Piece " + str(piece.chosenPiece) + " can be placed at: " + str(blockCoordinates))
				return true
		print(str(piece.chosenPiece) + " cannot be be placed.")
	return false
	
'''
reset_pieces
- Sets all pieces to default that are not placed (Used to create hover effect)
'''
func reset_pieces():
	for block in boardPieces:
		if !block.get_placement(): block.set_empty()
	
'''
hover_piece
- Sets the individual blocks to their hover state if the current piece selected can be placed there
'''
func hover_piece(blockPositions : Vector2, selectedPiece : Object):
	reset_pieces()
	
	var blockCoordinates = find_coordinates(get_viewport().get_mouse_position(), blockPositions, selectedPiece.chosenPiece)
	var blocksToPlace = check_place(blockCoordinates)
			
	if blocksToPlace.size() == 1 || !blocksToPlace.all(func(e): return e == blocksToPlace.front()): 
		if blocksToPlace.size() == selectedPiece.chosenPiece.size():
			for block in blocksToPlace:
					get_node(block).become_hovered()
	
'''
place_piece
- Attempt to place piece
'''
func place_piece(mousePosition : Vector2, blockPositions : Vector2, selectedPiece : Object):
	var blockCoordinates = find_coordinates(mousePosition, blockPositions, selectedPiece.chosenPiece)
	var blocksToPlace = check_place(blockCoordinates)
	if !blocksToPlace: return false
	
	if blocksToPlace.size() == 1 || !blocksToPlace.all(func(e): return e == blocksToPlace.front()): 
		if blocksToPlace.size() == selectedPiece.chosenPiece.size():
			for block in blocksToPlace:
				get_node(block).activate(selectedPiece.get_colour(), false)
		else:
			return false
	
	await check_board()
	return true

'''
check_place
- Check if the piece can be placed at coordinates given
'''
func check_place(coordinatesToCheck : Array):
	var blocksToPlace = []
	for coord in coordinatesToCheck:
		for block in boardPositions:
			if Geometry2D.is_point_in_polygon(coord, boardPositions[block]):
				if !get_node(block).get_placement():
					blocksToPlace.append(block)
		
	return blocksToPlace
			
'''
find_coordinates
- Find the coordinates of all blocks piece, given a specific block and the other positions of blocks in the piece
'''
func find_coordinates(originalCoords : Vector2, originalBlock : Vector2, positions : Array):
	var xo = originalCoords.x
	var yo = originalCoords.y
	var xb = originalBlock.x
	var yb = originalBlock.y
	var blockCoordinates = []
	
	for vectors in positions:
		var x = xo + (vectors.x - xb) * 64
		var y = yo + (vectors.y - yb) * 64
		blockCoordinates.append(Vector2(x,y))
	
	return blockCoordinates
	
'''
game_over
- Fade to black and load main screen

save_score
- Save highscore to file
'''
func game_over():
	save_score()
	$'AnimationPlayer'.play("over")
func save_score():
	var fileScore = int(FileAccess.open("user://score.save", FileAccess.READ).get_as_text())
	if score > fileScore:
		FileAccess.open("user://score.save", FileAccess.WRITE).store_string(str(score))

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "over":
		get_tree().change_scene_to_file("res://scenes/menu.tscn")

func _on_piece_area_piece_placed():
	if !can_still_play($'Piece Area'.get_pieces()):
		game_over()

func _on_back_gui_input(event):
	if event.pressed:
		$'AnimationPlayer'.play("over")
