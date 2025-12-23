extends CanvasLayer

@onready var desc_label: Label = $Panel/LabelText
@onready var title_label: Label = $Panel/LabelTitle

func _ready():
	print("QuestHud ready, Verbinde Signal")
	QuestManager.quest_changed.connect(_on_quest_changed)
	visible = false

func _on_quest_changed(quest: QuestData) -> void:
	if not title_label or not desc_label:
		print("Labels fehlen!")
		return

	if quest == null:
		# HUD erst ausblenden, wenn keine Quest aktiv ist
		visible = false
		title_label.text = ""
		desc_label.text = ""
		return

	# Wenn eine Quest aktiv ist, HUD anzeigen
	visible = true
	title_label.text = quest.title
	desc_label.text = quest.description
