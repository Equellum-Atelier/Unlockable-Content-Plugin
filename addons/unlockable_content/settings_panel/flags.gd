@tool
extends PanelContainer

@onready var flag_group_selection_area: ItemList = %FlagGroupSelectionArea

var _selected_flag_group: int = -1

func _notification(what: int) -> void:
	if what == NOTIFICATION_VISIBILITY_CHANGED and visible:
		if not is_node_ready():
			await ready
		prepare_flags()


func add_node_name(accum: Array, node: Node) -> Array:
	accum.append(node.name)
	return accum


func prepare_flags() -> void:
	flag_group_selection_area.clear()
	
	for flag_group_info: UCGroupInfo in UnlockableContent.database.groups:
		flag_group_selection_area.add_item(flag_group_info.group_name)
	
	_update_flag_info_container()


func _on_add_flags_button_pressed() -> void:
	var flag_group: String = %FlagGroupName.text
	
	UnlockableContent.database.register_group(flag_group)
	
	var idx: int = flag_group_selection_area.add_item(flag_group)
	flag_group_selection_area.select(idx)
	_selected_flag_group = idx
	
	%AddFlagsGroupButton.disabled = true
	_update_flag_info_container()


func _on_remove_flag_group_button_pressed() -> void:
	var removed_group: UCGroupInfo = UnlockableContent.database.remove_group_by_index(_selected_flag_group)
	flag_group_selection_area.remove_item(_selected_flag_group)
	_selected_flag_group = -1
	_update_flag_info_container()


func _on_add_flag_button_pressed() -> void:
	var value_text: String = %AddFlagContainer/FlagValue.text
	var flag_group_info: UCGroupInfo = UnlockableContent.database.groups[_selected_flag_group]
	
	var flag_name: String = %AddFlagContainer/FlagNameEdit.text
	
	if value_text.is_empty():
		UnlockableContent.database.register_flag(flag_group_info.group_name, flag_name)
	else:
		UnlockableContent.database.register_flag(flag_group_info.group_name, flag_name, int(value_text))
	
	%AddFlagContainer/FlagValue.text = ""
	%AddFlagContainer/FlagNameEdit.text = ""
	
	_update_flag_info_container()

## refresh the container displaying all flags in a group
func _update_flag_info_container() -> void:
	for child in %FlagInfo.get_children():
		child.queue_free()
	
	for child: Control in %FlagInfoContainer.get_children():
		child.visible= _selected_flag_group != -1
	
	if _selected_flag_group == -1:
		return
	
	%AddFlagContainer/FlagNameEdit.text = ""
	%AddFlagContainer/FlagValue.text = ""
	%AddFlagContainer/AddFlagButton.disabled = true
	
	var flag_group_info: UCGroupInfo = UnlockableContent.database.groups[_selected_flag_group]
	var flag_definitions: Array[Dictionary] = flag_group_info._flag_definitions
	
	for definition_index in flag_definitions.size():
		var definition: Dictionary = flag_definitions[definition_index]
		
		var row: HBoxContainer = HBoxContainer.new()
		%FlagInfo.add_child(row)
		
		var flag_name_edit: UCValidatedLineEdit = UCValidatedLineEdit.new()
		flag_name_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		flag_name_edit.text = definition[&"name"]
		flag_name_edit.validation_succesful.connect(func () -> void:
			var result: UCGroupInfo.RenameResult = flag_group_info.rename_flag(definition[&"name"], flag_name_edit.text)
			
			if result == UCGroupInfo.RenameResult.EMPTY_NAME:
				flag_name_edit.show_warning()
				flag_name_edit.tooltip_text = tr(&"Flag name cannot be empty.")
				return
			
			if result == UCGroupInfo.RenameResult.DUPLICATE_ENTRY:
				flag_name_edit.show_warning()
				flag_name_edit.tooltip_text = tr(&"Flag with same name already exists.")
				return
			
			flag_name_edit.hide_warning()
			UnlockableContent.database.update_or_register_group(flag_group_info)
		)
		row.add_child(flag_name_edit)
		
		var flag_value_edit: SpinBox = SpinBox.new()
		flag_value_edit.size_flags_horizontal = Control.SIZE_FILL
		flag_value_edit.value = definition[&"value"]
		flag_value_edit.max_value = 9223372036854775807
		flag_value_edit.value_changed.connect(func (_v) -> void:
			flag_group_info.set_flag_index(flag_name_edit.text, int(flag_value_edit.value))
			UnlockableContent.database.update_or_register_group(flag_group_info)
		)
		row.add_child(flag_value_edit)
		
		var remove_flag_button: Button = Button.new()
		remove_flag_button.size_flags_horizontal = Control.SIZE_FILL
		remove_flag_button.text = "Remove"
		remove_flag_button.pressed.connect(func () -> void:
			flag_group_info.remove_flag(definition[&"name"])
			UnlockableContent.database.update_or_register_group(flag_group_info)
			row.queue_free()
		)
		row.add_child(remove_flag_button)


func _on_flag_name_edit_text_changed() -> void:
	var flags: Dictionary[StringName, int] = UnlockableContent.database.groups[_selected_flag_group].flags
	var flag_name: StringName = StringName(%AddFlagContainer/FlagNameEdit.text)
	%AddFlagContainer/AddFlagButton.disabled = flag_name.is_empty() or flags.has(flag_name)


func _on_flag_group_selection_area_item_selected(index: int) -> void:
	_selected_flag_group = index
	_update_flag_info_container()


func _on_flag_group_name_validation_succesful() -> void:
	if %FlagGroupName.text.is_empty():
		%AddFlagsGroupButton.disabled = true
		return
	
	if UnlockableContent.database.has_flag_group(%FlagGroupName.text):
		%AddFlagsGroupButton.disabled = true
		return
	
	%AddFlagsGroupButton.disabled = false
