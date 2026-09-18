# GDSh tree

SceneTree commands for [GDSh](https://github.com/brohd11/godot-gdsh.git).
Usable in editor, or in a runtime debug console.

## Loading

```gdscript
var ctx = GDSh.Context.new()
ctx.load("res://addons/addon_lib/gdsh_lib/tree/tree.gd")
```

Load `tree.gd`, not the directory, so the subcommands stay under `tree`.

## Paths and pipes

Commands take **absolute node paths** on stdin, one per line, and print absolute paths,
so every stage of a pipeline resolves them the same way. A chain starts from a path:
`tree root` prints `/root`; a bare node path such as `/root/Main` prints its absolute
path too. Use `cn /root/Main` to resolve bare child names relative to that node. Hosts can add their own starting points (Editor Console
has `editor scene root` and `editor scene select` which operate at the edited scene level).

Examples:
```sh
# inspect a node directly
/root/Main | tree inspect

# get the children of the root
tree root | tree nodes

# recursively get the children of the root of the type label.
# then set the 'text' property to 'Hi'
tree root | tree nodes --recursive --type=Label | tree prop text Hi

# add a timer named 'Cooldown' to node
echo /root/Main | tree add Timer Cooldown

# pack the 'Level' branch and save the scene to path
echo /root/Main/Level | tree pack user://level.tscn

# Advanced example

# This is a function that takes a node as an argument, finds all labels,
# creates an hbox, reparents the label, adds an icon, then reindexes the new node

# first, we'll create a shorthand for echo, 'p' for path
p() { echo "$1" }

add_icons(){
	local nodes=$(p "$1" | tree nodes -r --type=Label)
	if [ "$nodes" == "" ] { return 1 }
	
	# every loop here is 4 actions, we can combine them all into one commitable action
	undoredo --compound "Add Icons to Labels" 1>discard

	for n in $nodes {
		local parent=$(p "$n" | tree parent)
		local idx=$(p "$n" | tree index)
		local h=$(p "$parent" | tree add HBoxContainer H)
		p "$n" | tree reparent "$h" 1>discard
		p "$h" | tree add TextureRect Icon 1>discard
		p "$h" | tree index $idx 1>discard
	}
	undoredo commit 1>discard
}

# Using it with Editor Console to operate on the edited scene
add_icons $(editor scene root)

```

Relative paths and empty stdin are errors, so a chain whose first stage matched nothing
does nothing.

## Commands

| Command | Use |
| --- | --- |
| `root` | Print `/root` |
| `nodes` | List children (`--recursive` for descendants), filtered by class, script, or `--owned`; `--pretty` tree |
| `parent` | Get node's parent path |
| `add` / `instance` | Add a node / instance a scene under each node |
| `duplicate` | Copy nodes next to themselves as `Name_<first free int>`, or `--name` / `--suffix` |
| `index` | Get or set the index of the node. |
| `free` | Remove nodes (never `/root`) |
| `prop` | Get or set a property (`position:x` paths, typed conversion) |
| `rename` / `reparent` | Rename one node / move nodes under an absolute parent path |
| `group` | `add`, `remove`, or `list` groups |
| `attach` | Set a script on nodes |
| `inspect` | List properties of nodes, or of a resource path |
| `pack` | Save a subtree as a PackedScene (the live tree is not changed) |

Run `tree <command> --help` for flags.

New and reparented nodes join their parent's scene: they are owned by the parent's
owner, or by the parent when it is a scene root.

## Host hooks

- Undo uses the GDSh core `ctx.host_data["undo_redo"]` hook. Each command is one action; wrap several in `undoredo --compound <action name>`
  `undoredo commit` for a single entry. Null or no hook (default for runtime console) applies changes directly.
- `pack` calls the GDSh `filesystem_changed` hook after saving.

## Exporting

`manifest.gd` preloads every command for use with [PluginExporter](https://github.com/brohd11/Godot-Plugin-Exporter)


## Install

Download the release and place the contents in the addons folder.

I use [gdaddon](https://github.com/brohd11/gdaddon) to manage the addon.
```
cd ~/your/project/
gdaddon install brohd11/godot-gdsh-lib-tree
```


## Validation

```sh
python3 tests/gdsh_lib/run_headless.py --godot godot
```
