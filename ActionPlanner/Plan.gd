class_name Plan
enum ERROR{
	NONE,
	UNACHIEVABLE_PLAN,
	PRECONDITIONS_ACHIEVED
}
var ActionObject:Action
var Children:Array[Plan]
var Effects:Dictionary
var Profit:int
var Cost:int
var Error:ERROR = ERROR.NONE

func _init(action_object:Action = null) -> void:
	if action_object:
		ActionObject = action_object
		Effects = action_object.Effects.duplicate(true)
		Profit = action_object.Profit
		Cost = action_object.Cost

func get_worth() -> int:
	return Profit - Cost

func extend_plan(child:Plan) -> void:
	Children.append(child)
	Effects.merge(child.Effects)
	Profit += child.Profit
	Cost += child.Cost

func get_full_plan(plan:Plan = self, output:Array = []) -> Array:
	for sup_plan:Plan in plan.Children:
		get_full_plan(sup_plan, output)
	if plan.ActionObject:
		output.append(plan.ActionObject)
	return output

func get_structure() -> String:
	if ActionObject:
		if Children.is_empty():
			return ActionObject.Name
		else:
			var out:String = '['
			for plan:Plan in Children:
				out += plan.get_structure()
				out += ', '
			out = out.trim_suffix(', ')
			out += ']'
			return ActionObject.Name + out
	else:
		var out:String = '['
		for plan:Plan in Children:
			out += plan.get_structure()
			out += ', '
		out = out.trim_suffix(', ')
		out += ']'
		return out

func _to_string() -> String:
	if Error != ERROR.NONE:
		return 'Error: ' + ERROR.keys()[Error].capitalize().to_upper()
	return str(get_full_plan())
