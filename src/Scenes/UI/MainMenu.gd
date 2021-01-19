extends Control

func _ready():
	$Panel/VBoxContainer/StartGame.grab_focus()
	$FadeIn.show()
	$AnimationPlayer.play("Appear")

func _on_StartGame_pressed():
	pass
	#current_level = level
	#var directory = Directory.new()
	#if directory.file_exists(level):
	#	var levelinstance = load(level).instance()
	#	if levelinstance.worldmap:
	#		worldmap = level
	#	levelinstance.set_name("Level")
	#	add_child(levelinstance)
	#	level_to_grid()
	#load_player()
	#load_ui()
	#load_editor()
	#editmode_toggle()

func _on_Options_pressed():
	$Options.show()
	$Panel.hide()

func _on_Options_popup_hide():
	$Panel.show()

func _on_LevelEditor_pressed():
	# warning-ignore:return_value_discarded
	get_tree().change_scene("res://Scenes/Master/Gameplay.tscn")

func _on_Credits_pressed():
	pass # Replace with function body.

func _on_Quit_pressed():
	get_tree().quit()
