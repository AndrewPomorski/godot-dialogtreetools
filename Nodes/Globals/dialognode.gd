
extends GraphNode

# Type of node
var type setget set_type,get_type
# path to scene used to create new blocks
var block_scene setget set_block_scene,get_block_scene
# Does a new block add a new slot?
export(bool) var first_left_slot
export(bool) var first_right_slot
export(bool) var new_block_adds_left_slot
export(bool) var new_block_adds_right_slot

## BLOCKS VARS
onready var nb_blocks = 0
onready var nodes_blocks = []



func _ready():
	# security
	if (first_left_slot == null):
		first_left_slot = true
	if (first_right_slot == null):
		first_right_slot = true
	if (new_block_adds_left_slot == null):
		new_block_adds_left_slot = false
	if (new_block_adds_right_slot == null):
		new_block_adds_right_slot = false

	connect("close_request", self, "_on_close_request")

func set_type(new):
	type = new
	
func get_type():
	return type

func set_block_scene(new):
	block_scene = new
	
func get_block_scene():
	return block_scene

###########################################
###########################################

# delete GraphNode on close request
func _on_close_request():
	queue_free()

# instance a scene to add as a block in the GraphNode.
func add_new_block():
	var block = load(block_scene).instance()
	block.set_id(nb_blocks)
	
	add_rembutton(block)
	if (nb_blocks+1 <= 1):
		hide_rembutton(block)
	
	add_addbutton(block)
	
	# add new line block to the main container
	#if (!new_blocks_in_new_container):
		#get_node("vbox_main_container").add_child(block)
	add_child(block)
		
	nodes_blocks.append(block)
	nb_blocks += 1
	
	# at least 2 variables, add remove button to first variable so it can be deleted
	if (nb_blocks > 1):
		show_rembutton(nodes_blocks[0])
	
	# enable/disable slots of the GraphNode for this block EXCEPT BLOCK 1
	print(nb_blocks)
	if (nb_blocks == 1):
		print("FIRST BLOCK", str(first_left_slot), str(first_right_slot))
		set_slot(nb_blocks-1, first_left_slot, 0, Color(1.0, 1.0, 1.0), first_right_slot, 0, Color(1.0, 1.0, 1.0))
	else:
		print("NEW BLOCK", str(new_block_adds_left_slot), str(new_block_adds_right_slot))
		set_slot(nb_blocks-1, new_block_adds_left_slot, 0, Color(1.0, 1.0, 1.0), new_block_adds_right_slot, 0, Color(1.0, 1.0, 1.0))
	

# adds by script the "+" button to add an action block to the graphnode
func add_addbutton(block):
	var btnAdd = Button.new()
	btnAdd.set_name("addbtn")
	btnAdd.set_text("+")
	btnAdd.connect("pressed", self, "_on_add_pressed")
	block.get_node("hbox").add_child(btnAdd)
	
# adds by script the "-" button to remove the action block from the graphnode
func add_rembutton(block):
	var btnRemove = Button.new()
	btnRemove.set_name("rembtn")
	btnRemove.set_text("-")
	#print(parent)
	btnRemove.connect("pressed", self, "_on_remove_pressed", [block])
	block.get_node("hbox").add_child(btnRemove)

# hide the "-" button
func hide_rembutton(block):
	block.get_node("hbox/rembtn").hide()
	
# display the "-" button
func show_rembutton(block):
	block.get_node("hbox/rembtn").show()

func _on_add_pressed():
	add_new_block()

# Remove block button pressed
func _on_remove_pressed(block):
	print(block.get_name())
	remove_child(block)
	nodes_blocks.remove( nodes_blocks.find(block) )
	nb_blocks -= 1
	
	if nb_blocks == 1:
		hide_rembutton(nodes_blocks[0])
	
	var resize = get_minimum_size()
	set_size( Vector2(resize.x, 0 ) )

# Show/Hide block button pressed, and resize GraphNode to its minimum size
func _on_hide_block_pressed(block_to_hide):
	if block_to_hide.is_hidden():
		block_to_hide.show()
	else:
		block_to_hide.hide()
		set_size( Vector2(get_minimum_size().x, 0))