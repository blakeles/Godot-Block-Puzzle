extends Node

var pieceScene = load("res://scenes/piece.tscn")
var piecesAvailable = [] # Holds references to the pieces that are available to be placed

signal piece_placed # Signal to board to alert that a piece has been placed

# Called when the node enters the scene tree for the first time.
func _ready():
	await spawn_pieces()
	get_parent().can_still_play(piecesAvailable)
	
'''
handle_hover
- Forwards the piece being dragged to the board manager
'''
func handle_hover(dict : Dictionary):
	get_parent().hover_piece(dict['blockSelected'], dict['piece'])

'''
handle_place_piece
- Forwards piece to game board to be placed and remove from available pieces
- If piece can be placed, then checks if at least one remaining piece can still be placed
'''
func handle_place_piece(dict : Dictionary):
	if await get_parent().place_piece(dict['unclick'], dict['blockSelected'], dict['piece']): # If piece can be placed, do it
		piecesAvailable.remove_at(piecesAvailable.find(dict['piece'])) # Remove piece from pieces available
		if piecesAvailable.size() < 1: await spawn_pieces() # Check to see if the player has ran out of pieces 
		piece_placed.emit()
		return true
	return false

'''
spawn_pieces
- Spawn 3 random pieces
'''
func spawn_pieces():
	for i in 3:
		var pieceInstance = pieceScene.instantiate()
		pieceInstance.position = Vector2(i,0)*68 # 64 + 4 px gap
		piecesAvailable.append(pieceInstance)
		add_child(pieceInstance)
		pieceInstance.spawn(pieceInstance.global_position, false)
		
'''
get_pieces
- Check to see if the available pieces can be placed
'''
func get_pieces():
	return piecesAvailable
