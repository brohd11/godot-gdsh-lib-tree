# GDSh tree

SceneTree commands for [GDSh](https://github.com/brohd11/godot-gdsh.git) consoles.
They have no editor dependency and no implicit root: every command works on the node
paths piped into it.

## Loading

```gdscript
var ctx = GDSh.Context.new()
ctx.load("res://addons/addon_lib/gdsh_lib/tree/tree.gd")
```

Load `tree.gd`, not the directory, so the subcommands stay under `tree`.

## Paths and pipes

Commands take **absolute node paths** on stdin, one per line, and print absolute paths,
so every stage of a pipeline resolves them the same way. A chain starts from a path:
`tree root` prints `/root`, and hosts can add their own starting points (Editor Console
has `editor scene root` and `editor scene select`).

```sh
tree root | tree nodes                             # children of /root
tree root | tree nodes --recursive Label | tree prop text Hi
echo /root/Main | tree add Timer Cooldown
echo /root/Main/Level | tree pack user://level.tscn
```

Relative paths and empty stdin are errors, so a chain whose first stage matched nothing
does nothing.

## Commands

| Command | Use |
| --- | --- |
| `root` | Print `/root` |
| `nodes` | List children (`--recursive` for descendants), filtered by class, script, or `--owned`; `--pretty` tree |
| `add` / `instance` | Add a node / instance a scene under each node |
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

- `ctx.host_data["tree_undo_redo"]`: `Callable() -> Object`, optional. An `UndoRedo`, or
  any object with its `create_action`/`add_do_*`/`add_undo_*`/`commit_action` methods
  taking `(object, method, args...)`. Each command is one action. Null or no hook applies
  changes directly.
- `pack` calls the GDSh `filesystem_changed` hook after saving.

## Exporting

`manifest.gd` preloads every command so plugin exporters that follow preloads include
them; preload it from the host.

## Validation

```sh
python3 tests/gdsh_lib/run_headless.py --godot godot
```
