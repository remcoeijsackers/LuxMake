extends CanvasLayer

var directory = null
var dir = Directory.new()
var selectedfile = null
var selectdir = null
var cancel = true
var save = false
var savename = ""
var filetype = ""

func _ready():
	$Popup/Panel/VBoxContainer/FileName.visible = save
	$Popup/Panel/VBoxContainer/FileName/HSplitContainer/FileType.text = filetype
	$Popup.show()
	reload()

func _process(_delta):
	$Popup/Panel/HBoxContainer/OK.disabled = false
	if save and savename == "":
		$Popup/Panel/HBoxContainer/OK.disabled = true

	if selectedfile == null:
		savename = $Popup/Panel/VBoxContainer/FileName/HSplitContainer/LineEdit.text
	else:
		savename = selectedfile
		var end = savename.rfind(".")
		savename.erase(end, savename.length() - end)
		if $Popup/Panel/VBoxContainer/FileName/HSplitContainer/LineEdit.text != savename:
			$Popup/Panel/VBoxContainer/FileName/HSplitContainer/LineEdit.text = savename

	UIHelpers.get_editor().clickdisable = true
	for child in $Popup/Panel/VBoxContainer/ScrollContainer/Files.get_children():
		if selectedfile == child.text:
			child.pressed = true
		else: child.pressed = false
	selectdir = str(directory, "/", selectedfile)

func reload():

	# Make sure directory ends in /
	if !directory.ends_with("/"):
		directory = str(directory, "/")

	selectedfile = null # Clear selected file

	# Delete existing children
	for child in $Popup/Panel/VBoxContainer/ScrollContainer/Files.get_children():
		child.queue_free()

	$Popup/Panel/VBoxContainer/TopBar/DirectoryName.text = directory # Update top text

	# Get all the files in the directory, then add each as a button node
	var files = list_files_in_directory(directory)
	for file in files:
		if (filetype in file or not "." in file or filetype == "") and not ".import" in file and not "EditedLevel" in file:
			var child = load("res://Scenes/Editor/FileSelectButton.tscn").instance()
			child.text = file
			$Popup/Panel/VBoxContainer/ScrollContainer/Files.add_child(child)

func _on_Back_pressed():
	var dir2 = directory.trim_suffix("/")
	var end = dir2.rfind("/")
	dir2.erase(end, dir2.length() - end)
	if dir2.length() > 1:
		directory = dir2
	reload()

func _on_Reload_pressed():
	reload()

func _on_OK_pressed():
	var files = list_files_in_directory(directory)
	if save and (selectedfile != null or (str(savename, filetype) in files)):
		$Popup.hide()
		$Overwrite.show()
	else:
		cancel = false
		queue_free()

func _on_Cancel_pressed():
	queue_free()

func list_files_in_directory(path):
	var files = []
	dir = Directory.new()
	dir.open(path)
	dir.list_dir_begin()

	while true:
		var file = dir.get_next()
		if file == "":
			break
		elif not file.begins_with("."):
			files.append(file)

	dir.list_dir_end()

	return files

func _on_LineEdit_text_changed(_new_text):
	selectedfile = null

func _on_OverwriteYes_pressed():
	cancel = false
	queue_free()

func _on_OverwriteNo_pressed():
	$Overwrite.hide()
	$Popup.show()
