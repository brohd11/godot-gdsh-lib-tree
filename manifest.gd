extends RefCounted
## Preloads the tree namespace and its commands, so exporters that follow preloads include
## them. Load the namespace with ctx.load(Manifest.resource_path.get_base_dir().path_join("tree.gd")).

const TREE = preload("res://addons/addon_lib/gdsh_lib/tree/tree.gd")

const COMMANDS = [
	TREE,
	preload("res://addons/addon_lib/gdsh_lib/tree/add/add.gd"),
	preload("res://addons/addon_lib/gdsh_lib/tree/attach/attach.gd"),
	preload("res://addons/addon_lib/gdsh_lib/tree/free/free.gd"),
	preload("res://addons/addon_lib/gdsh_lib/tree/group/group.gd"),
	preload("res://addons/addon_lib/gdsh_lib/tree/inspect/inspect.gd"),
	preload("res://addons/addon_lib/gdsh_lib/tree/instance/instance.gd"),
	preload("res://addons/addon_lib/gdsh_lib/tree/nodes/nodes.gd"),
	preload("res://addons/addon_lib/gdsh_lib/tree/pack/pack.gd"),
	preload("res://addons/addon_lib/gdsh_lib/tree/prop/prop.gd"),
	preload("res://addons/addon_lib/gdsh_lib/tree/rename/rename.gd"),
	preload("res://addons/addon_lib/gdsh_lib/tree/reparent/reparent.gd"),
	preload("res://addons/addon_lib/gdsh_lib/tree/root/root.gd"),
]
