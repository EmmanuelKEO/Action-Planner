extends Control
@export var ActionPlannerObject:ActionPlanner = ActionPlanner.new()
@onready var Display:RichTextLabel = $Panel/RichTextLabel

func _ready() -> void:
	var CurrentPlan:Plan = ActionPlannerObject.BuildPlan()
	print(CurrentPlan)


