extends Node3D

@onready var dispense_pos := $DispensePosition

var cash_obj: PackedScene = preload("res://scenes/money.tscn")
var sfx_dispense := preload("res://assets/sound/sfx/ui/dispensed.wav")

@onready var base = get_node("/root/base")

func _ready() -> void:
	BankManager.money_dispenser = self

func dispense(amount: float):
	var cash: RigidBody3D = cash_obj.instantiate()
	cash.get_node("Money").amount = amount
	cash.global_transform = dispense_pos.global_transform
	base.add_child(cash)
