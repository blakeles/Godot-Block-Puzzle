extends Node

var pieceScene = load("res://scenes/piece.tscn")
var pieceInstance : Object
var labelText : String

# Called when the node enters the scene tree for the first time.
func _ready():
	$"Piece container/PIECE/AnimationPlayer".play("spin")
	handle_piece()
	# Load highscore from file and display it
	if not FileAccess.file_exists("user://score.save"): 
		labelText = ""
		FileAccess.open("user://score.save", FileAccess.WRITE).store_string("0")
	else: 
		labelText = "HIGHSCORE\n" + FileAccess.open("user://score.save", FileAccess.READ).get_as_text()
		
	$'Highscore container/Label'.text = labelText
	
# Spawn random piece
func handle_piece():
	if pieceInstance: pieceInstance.queue_free()
	pieceInstance = pieceScene.instantiate()
	$'Piece container/PIECE'.add_child(pieceInstance)
	pieceInstance.spawn($'Piece container/PIECE'.global_position, true)

# Play game
func _on_play_pressed():
	get_tree().change_scene_to_file("res://scenes/main.tscn")

# Quit game
func _on_quit_pressed():
	get_tree().quit()

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "spin":
		$"Piece container/PIECE/AnimationPlayer".play("spin2")
		handle_piece()
	elif anim_name == "spin2":
		$"Piece container/PIECE/AnimationPlayer".play("spin")
		#handle_piece()
