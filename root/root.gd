extends "res://addons/addon_lib/gdsh/command_base.gd"

const TreeUtil = preload("res://addons/addon_lib/gdsh_lib/tree/tree_util.gd")

const _HELP = \
"Print the SceneTree root path (/root), to start a tree command chain.
Usage: tree root | tree nodes"


static func get_command_name() -> String:
	return "root"


static func get_self_command_data() -> Dictionary:
	return _command_data({&"help": _HELP})


func _execute(ctx:Context):
	var root = TreeUtil.get_tree_root()
	if root == null:
		ctx.append_error("No SceneTree.")
		return ExitCode.FAIL
	ctx.append_output(TreeUtil.path_of(root))
	return ExitCode.OK
