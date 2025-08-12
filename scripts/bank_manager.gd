extends Node

var balance: float = 100.0
var cash: float = 0.0

func withdraw(amount: float) -> bool:
	if balance - amount < 0:
		return false
	
	balance -= amount
	cash += amount
	return true

func deposit(amount: float) -> bool:
	if cash - amount < 0:
		return false
	
	cash -= amount
	balance += amount
	return true    
