extends Node
class_name Quest_Manager

signal quest_changed(quest: QuestData)

var current_quest: QuestData

func set_quest(quest: QuestData) -> void:
	current_quest = quest
	emit_signal("quest_changed", quest)

func clear_quest() -> void:
	current_quest = null
	emit_signal("quest_changed", null)
