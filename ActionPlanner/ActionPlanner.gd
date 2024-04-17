extends Resource
class_name ActionPlanner
@export var Goals:Array[Array] = [
	[{'is_thirsty':false}, {'is_hungry':false}],
	[{'is_water_source_close':true}]
]
@export var Conditions:Dictionary = {
	'is_hungry':true,
	'has_food':false,
	'has_animal':false,
	'has_weapon':false,
	'has_fruits':false,
	'has_wood':false,
	'has_axe':false,
	'is_thirsty':true,
	'has_water':false,
	'has_cup':false,
	'is_water_source_close':false
}
@export var PredefinedActions:Dictionary = {
	'Eat':{
		'Preconditions':[
			[{'has_food':true}]
		],
		'Effects':{'is_hungry':false},
		'Profit':1,
		'Cost':1
	},
	'Cook':{
		'Preconditions':[
			[{'has_animal':true}],
			[{'has_fruits':true}]
		],
		'Effects':{'has_food':true},
		'Profit':1,
		'Cost':1
	},
	'Hunt':{
		'Preconditions':[
			[{'has_weapon':true}]
		],
		'Effects':{'has_animal':true},
		'Profit':3,
		'Cost':2
	},
	'Make Weapon':{
		'Preconditions':[
			[{'has_wood':true}]
		],
		'Effects':{'has_weapon':true, 'has_wood':false},
		'Profit':1,
		'Cost':1
	},
	'Pick Fruits':{
		'Preconditions':[],
		'Effects':{'has_fruits':true},
		'Profit':1,
		'Cost':1
	},
	'Pick Sticks':{
		'Preconditions':[],
		'Effects':{'has_wood':true},
		'Profit':1,
		'Cost':4
	},
	'Chop Tree':{
		'Preconditions':[
			[{'has_axe':true}]
		],
		'Effects':{'has_wood':true},
		'Profit':5,
		'Cost':1
	},
	'Make Axe':{
		'Preconditions':[
			[{'has_wood':true}]
		],
		'Effects':{'has_axe':true, 'has_wood':false},
		'Profit':1,
		'Cost':1
	},
	'Drink Water':{
		'Preconditions':[
			[{'has_water':true}],
		],
		'Effects':{'is_thirsty':false},
		'Profit':1,
		'Cost':1
	},
	'Fetch Water With Cup':{
		'Preconditions':[
			[{'has_cup':true}, {'is_water_source_close':true}]
		],
		'Effects':{'has_water':true},
		'Profit':3,
		'Cost':1
	},
	'Fetch With Hand':{
		'Preconditions':[
			[{'is_water_source_close':true}]
		],
		'Effects':{'has_water':true},
		'Profit':1,
		'Cost':1
	},
	'Find Water Source':{
		'Preconditions':[],
		'Effects':{'is_water_source_close':true},
		'Profit':1,
		'Cost':1
	},
}
var Actions:Array[Action] = []
func _init() -> void:
	for action:String in PredefinedActions:
		Actions.append(Action.new(action, PredefinedActions[action].Profit, PredefinedActions[action].Cost, PredefinedActions[action].Preconditions, PredefinedActions[action].Effects))

func BuildPlan(goals:Array = Goals, conditions:Dictionary = Conditions, available_actions:Array = Actions, current_plan:Plan = Plan.new()) -> Plan:
	if goals.is_empty():
		return current_plan
	
	var ActionsForGoals:Array[Array] = []
	for goal:Array in goals:
		var ActionsForGoal:Array[Dictionary] = []
		var AllPreconditionsAchieved:bool = true
		for precondition:Dictionary in goal:
			var precondition_name:String = precondition.keys()[0]
			var precondition_value:bool = precondition.values()[0]
			if conditions[precondition_name] != precondition_value:
				AllPreconditionsAchieved = false
				var ActionsForPrecondition:Array[Action] = []
				for action:Action in available_actions:
					if action.has_effect(precondition_name):
						if action.get_effect(precondition_name) == precondition_value:
							ActionsForPrecondition.append(action)
				if ActionsForPrecondition.is_empty():
					ActionsForGoal.clear()
					break
				else:
					ActionsForGoal.append({precondition:ActionsForPrecondition})
		if AllPreconditionsAchieved:
			current_plan.Error = Plan.ERROR.PRECONDITIONS_ACHIEVED
			return current_plan
		if !ActionsForGoal.is_empty():
			ActionsForGoals.append(ActionsForGoal)
	if ActionsForGoals.is_empty():
		current_plan.Error = Plan.ERROR.UNACHIEVABLE_PLAN
		return current_plan
	
	var PlansForGoals:Array[Array] = []
	for actions_for_goal:Array in ActionsForGoals:
		var PlansForGoal:Array[Plan] = []
		var EffectsOnConditions:Dictionary = conditions.duplicate(true)
		for precondition_for_actions:Dictionary in actions_for_goal:
			var precondition:Dictionary = precondition_for_actions.keys()[0]
			var actions_for_precondition:Array = precondition_for_actions.values()[0]
			var PlansForPrecondition:Array[Plan] = []
			if EffectsOnConditions[precondition.keys()[0]] != precondition.values()[0]:
				for action:Action in actions_for_precondition:
					var plan:Plan
					if action.Preconditions.is_empty():
						plan = Plan.new(action)
					else:
						plan = BuildPlan(action.Preconditions, EffectsOnConditions, available_actions.filter(func (item:Action): return item != action), Plan.new(action))
					if plan.Error != Plan.ERROR.UNACHIEVABLE_PLAN:
						PlansForPrecondition.append(plan)
			var BestPlan:Plan = PlansForPrecondition.pop_back()
			for plan:Plan in PlansForPrecondition:
				if plan.get_worth() > BestPlan.get_worth():
					BestPlan = plan
			if BestPlan:
				PlansForGoal.append(BestPlan)
				EffectsOnConditions.merge(BestPlan.Effects, true)
			else:
				PlansForGoal.clear()
				break
		if !PlansForGoal.is_empty():
			PlansForGoals.append(PlansForGoal)
	
	var BestPlans:Array[Plan]
	var BestWorth:int
	for plans_for_goal:Array in PlansForGoals:
		if plans_for_goal.is_empty():
			continue
		var PlanWorth:int = plans_for_goal.reduce(func (sum:int, plan:Plan): return sum + plan.get_worth(), 0)
		if !BestPlans or PlanWorth > BestWorth:
			BestPlans = plans_for_goal
			BestWorth = PlanWorth
	if !BestPlans:
		current_plan.Error = Plan.ERROR.UNACHIEVABLE_PLAN
		return current_plan
	for plan:Plan in BestPlans:
		current_plan.extend_plan(plan)
	return current_plan
