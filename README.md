# Minetest-money
### Version 0.1.1
### Minetest Version 0.4.16
Liscense: MIT -> https://opensource.org/licenses/MIT
Author: SonosFuer

Money API for use in minetest


## Description
This mod adds a bottom line framework for in game money

Each player has an additional money attribute

## API
### money.add(player, amount)
Adds the amount specified by the amount value passed to the player passed. 
Returns true on success
Returns false if ammount is <0
Returns false if player does not exist

### money.subtract(player, amount)
Subtracts the amount specified by the amount value passed to the player passed.
Returns true on success
Returns false if ammount is <0
Returns false if player does not exist

### money.set(player, amount)
Sets the value of a players bank

### money.get(player)
Returns the value of a players bank

### money.send(from, to, amount)
Sends money from one player to another

## Commands

/money send <playername> <amount>
Sends money from yourseld to the specified player

/money give <playername> <amount>
Adds money to players account, money is magically created and not obtained from anywhere
Requires money_create privilage

/money take <playername> <amount>
Removes money from players account, money vanishes
Requires money_create privilage

/money check <playername>
Prints how much money is in a players account


##Credits

This mod is "Forked" From Wuzzys mana mod and modified to be used as an interface for money. Credit for original code goes to Wuzzy.
Check out his profile on the Minetest forums here
https://forum.minetest.net/memberlist.php?mode=viewprofile&u=3082
Also check out his original mana mod here
https://forum.minetest.net/viewtopic.php?f=9&t=11154

This mod impliments ChatCmdBuilder by rubenwardy
https://github.com/rubenwardy/ChatCmdBuilder