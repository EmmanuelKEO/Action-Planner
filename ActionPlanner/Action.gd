extends Resource
class_name Action
@export var Name:String
@export var Profit:int
@export var Cost:int
@export var Preconditions:Array
@export var Effects:Dictionary

func _init(name:String, profit:int, cost:int, preconditions:Array, effects:Dictionary) -> void:
	Name = name
	Profit = profit
	Cost = cost
	Preconditions = preconditions
	Effects = effects

func has_effect(effect:String) -> bool:
	return Effects.has(effect)

func get_effect(effect:String) -> bool:
	return Effects[effect]

func _to_string() -> String:
	return str(Name)#, ': ', Profit - Cost, ' worth')
