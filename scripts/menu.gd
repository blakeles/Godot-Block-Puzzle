extends Node

var labelText : String

# Called when the node enters the scene tree for the first time.
func _ready():
	# Load highscore from file and display it
	if not FileAccess.file_exists("user://score.save"): 
		labelText = ""
		FileAccess.open("user://score.save", FileAccess.WRITE).store_string("0")
	else:
		labelText = "HIGHSCORE\n" + FileAccess.open("user://score.save", FileAccess.READ).get_as_text()
		
	$'CenterContainer2/Label'.text = labelText

# Play game
func _on_play_pressed():
	get_tree().change_scene_to_file("res://scenes/main.tscn")

# Quit game
func _on_quit_pressed():
	get_tree().quit()

