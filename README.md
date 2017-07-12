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
### money.add(player, ammount)
Adds the ammount specified by the ammount value passed to the player passed. 
Returns true on success
Returns false if ammount is <0
Returns false if player does not exist

##Credits

This mod is "Forked" From Wuzzys mana mod and modified to be used as an interface for money. Credit for original code goes to Wuzzy.
Check out his profile on the Minetest forums here
https://forum.minetest.net/memberlist.php?mode=viewprofile&u=3082
Also check out his original mana mod here
https://forum.minetest.net/viewtopic.php?f=9&t=11154

This mod impliments ChatCmdBuilder by rubenwardy
https://github.com/rubenwardy/ChatCmdBuilder