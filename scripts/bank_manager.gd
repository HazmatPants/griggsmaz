extends Node

var money_dispenser

var balance: float = 100.0
var cash: float = 0.0

func withdraw(amount: float) -> bool:
	if balance - amount < 0:
		return false
	
	money_dispenser = get_node("/root/base/PaycheckDispenser")
	
	balance -= amount
	money_dispenser.dispense(amount)
	return true

func deposit(amount: float) -> bool:
	if cash - amount < 0:
		return false
	
	cash -= amount
	balance += amount
	return true    
