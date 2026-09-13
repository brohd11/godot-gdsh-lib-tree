extends RefCounted
## Buffered do/undo operations for one tree command, so each command is one undo entry.
##
##   var a = TreeUtil.action(ctx, "Rename node")
##   a.do_property(node, &"name", new_name)
##   a.undo_property(node, &"name", old_name)
##   a.commit()
##
## commit() replays the operations into the injected undo object (an UndoRedo, or any
## object with UndoRedo's add_do_*/add_undo_* methods taking (object, method, args...)),
## which runs the do side. Without one, commit() applies the do side directly.
## Commands must NOT also apply the change themselves.

enum {
	_DO_PROPERTY,
	_UNDO_PROPERTY,
	_DO_METHOD,
	_UNDO_METHOD,
	_DO_REFERENCE,
	_UNDO_REFERENCE,
}

var _name:String
var _undo_redo:Object
var _ops:Array = []


func _init(name:String, undo_redo:Object=null) -> void:
	_name = name
	_undo_redo = undo_redo


func do_property(obj:Object, property:StringName, value):
	_ops.append([_DO_PROPERTY, obj, property, value])
	return self


func undo_property(obj:Object, property:StringName, value):
	_ops.append([_UNDO_PROPERTY, obj, property, value])
	return self


func do_method(obj:Object, method:StringName, args:Array = []):
	_ops.append([_DO_METHOD, obj, method, args])
	return self


func undo_method(obj:Object, method:StringName, args:Array = []):
	_ops.append([_UNDO_METHOD, obj, method, args])
	return self


## Object is out of the tree on the do side (a new node before add_child): the undo
## stack keeps it alive so an undo can restore it.
func do_reference(obj:Object):
	_ops.append([_DO_REFERENCE, obj])
	return self


## Object is out of the tree on the undo side (a removed node): the undo stack keeps it.
## Without an undo object there is nothing to restore, so commit() frees it.
func undo_reference(obj:Object):
	_ops.append([_UNDO_REFERENCE, obj])
	return self


func commit() -> void:
	if _ops.is_empty():
		return
	if is_instance_valid(_undo_redo):
		_commit_undo_redo()
	else:
		_commit_direct()


func _commit_undo_redo() -> void:
	var ur = _undo_redo
	# UndoRedo takes Callables; other undo managers take (object, method, args...).
	var callables = ur is UndoRedo
	ur.create_action(_name)
	for op in _ops:
		match op[0]:
			_DO_PROPERTY:
				ur.add_do_property(op[1], op[2], op[3])
			_UNDO_PROPERTY:
				ur.add_undo_property(op[1], op[2], op[3])
			_DO_METHOD:
				if callables:
					ur.add_do_method(Callable(op[1], op[2]).bindv(op[3]))
				else:
					ur.callv("add_do_method", [op[1], op[2]] + op[3])
			_UNDO_METHOD:
				if callables:
					ur.add_undo_method(Callable(op[1], op[2]).bindv(op[3]))
				else:
					ur.callv("add_undo_method", [op[1], op[2]] + op[3])
			_DO_REFERENCE:
				ur.add_do_reference(op[1])
			_UNDO_REFERENCE:
				ur.add_undo_reference(op[1])
	ur.commit_action()


func _commit_direct() -> void:
	var orphaned:Array = []
	for op in _ops:
		match op[0]:
			_DO_PROPERTY:
				op[1].set(op[2], op[3])
			_DO_METHOD:
				op[1].callv(op[2], op[3])
			_UNDO_REFERENCE:
				orphaned.append(op[1])
			# Undo-side and do_reference ops have nothing to do without an undo object.
	for obj in orphaned:
		if not is_instance_valid(obj):
			continue
		if obj is Node:
			obj.queue_free()
		elif not obj is RefCounted:
			obj.free()
