--[[
Money API
This mod adds money to players
]]

--[===[
	Initialization
]===]

--[[ I need to figure out how this works to use it :/ coming soon?
local S
if (minetest.get_modpath("intllib")) then
	S = intllib.Getter()
else
	S = function(s,a,...)a={a,...}return s:gsub("@(%d+)",function(n)return a[tonumber(n)]end)end
end
]]--
money = {}
money.bank = {}
money.bank.players = {}
money.config = {}
money.config.init = 100

--[===[
	API functions
]===]

function money.set(playername, value)
	local value = money.round(value)

	if value < 0 then
		value = 0
		money.hud_update(player.get_player_by_name(playername))
		return
	end
	if money.bank.players[playername].purse ~= value and money.bank.players[playername] ~= nil then
		money.bank.players[playername].purse = tostring(value)
		money.hud_update(player.get_player_by_name(playername))
	end
end

function money.get(player)
	playername = player:get_player_name()
	return money.bank.players[playername].purse
end

function money.add(playername, value)
	local player = minetest.get_player_by_name(playername)
	local value = money.round(value)

	if(money.bank.players[playername] ~= nil and value >= 0) then
		local bank = tonumber(money.bank.players[playername].purse)
		bank = tostring(bank + value)
		money.bank.players[playername].purse = bank
		money.hud_update(player)
		return true
	else
		return false
	end
end

function money.subtract(playername, value)
	local player = minetest.get_player_by_name(playername)
	local value = money.round(value)
	local bank = tonumber(money.bank.players[playername].purse)

	if(money.bank.players[playername] ~= nil and bank >= value and value >= 0) then
		bank = tostring(bank - value)
		money.bank.players[playername].purse = bank
		money.hud_update(player)
		return true
	else
		return false
	end
end

function money.send(send, recive, value)

	local sender = minetest.get_player_by_name(send)
	local reciver = minetest.get_player_by_name(recive)
	local value = money.round(value)

	if(sender ~= nil and reciver ~= nil and money.round(money.bank.players[sender].purse) > value and value >= 0) then
		if(money.subtract(send, value)) then
			money.add(recive, value)
			minetest.chat_send_player(send, "You sent " .. value .. " to " .. recive)
			minetest.chat_send_player(recive, "You recived " .. value .. " from " .. send)
			money.hud_update(sender)
			money.hud_update(reciver)
			return true
		end
			minetest.chat_send_player(send, "e1")
	end
	minetest.chat_send_player(send, "e2")
	return false, "Something went wrong :("
end

--[===[
	File handling, loading data, saving data, setting up stuff for players.
]===]

minetest.register_on_leaveplayer(
	function(player)
		money.hud_remove(player)
	end
)

minetest.register_on_joinplayer(
	function(player)
		playername = player:get_player_name()
		if money.bank.players[playername] == nil then
			money.bank.players[playername] = {}
			money.bank.players[playername].purse = 100
		end
		money.hud_add(player)
	end
)

--[===[
	HUD functions
]===]
function money.moneystring(player)
	return "money:" .. money.get(player)
end

function money.hud_add(player)
	local id = player:hud_add({
		hud_elem_type = "text",
		position = { x = 1, y=1 },
		text = money.moneystring(player),
		scale = { x = 0, y = 0 },
		alignment = { x = 1, y = 0},
		direction = 1,
		number = 0xFFFFFF,
		offset = { x = -262, y = -103}
	})
	player:set_attribute("money:hudid", id)
end

function money.hud_update(player)
	player:hud_change(player:get_attribute("money:hudid"), "text", money.moneystring(player))
end

function money.hud_remove(player)
	player:hud_remove(player:get_attribute("money:hudid"))
end

--[===[
	Helper functions
]===]

money.round = function(x)
	return math.ceil(math.floor(tonumber(x)+0.5))
end

function money.help(name)
	minetest.chat_send_player(name, "=====Money==============================================================")
	minetest.chat_send_player(name, "/money send <player> <amount> -> Sends money to specified player")
	minetest.chat_send_player(name, "/money give <player> <amount> -> Admin gives money to a specific player ")
	minetest.chat_send_player(name, "/money take <player> <amount> -> Admin takes money from a plauer")
	minetest.chat_send_player(name, "/money check <player>         -> Check how much money a player has")
	minetest.chat_send_player(name, "=====Money==============================================================")
end
--[===[
	Chat Commands
]===]
minetest.register_privilege("moneymagic", "Allows the player to create and delete money")

minetest.register_chatcommand("money", {
	description = "Money command interface, type /money help",
	privs = {interact = true},
	func = function(name, param)
		local args = param:split(" ")

		if args[1] == "help" then
			money.help(name)
			return
		elseif args[1] == "send" then
			money.send(name, args[2], args[3])
			return
		elseif args[1] == "give" then
			if minetest.get_player_privs(name).moneymagic then
				money.add(args[2], args[3])
			end
			return
		elseif args[1] == "take" then
			if minetest.get_player_privs(name).moneymagic then
				money.subtract(args[2], args[3])
			end
			return
		elseif args[1] == "check" then
			if args[2] == nil then
				args[2] = name
			end
			minetest.chat_send_player(name, money.get(minetest.get_player_by_name(args[2])))
			return
		end
	end
})



--[[
File io
]]

do
	local filepath = minetest.get_worldpath().."/money.mt"
	local file = io.open(filepath, "r")
	if file then
		minetest.log("action", "[money] money.mt opened.")
		local string = file:read()
		io.close(file)
		if(string ~= nil) then
			money.bank = minetest.deserialize(string)
			
			minetest.debug("[money] money.mt successfully read.")
		else
			minetest.debug("[money] String nill, read failed")
		end
	end
end

--Save towns database to file

function money.save_to_file()
	local save = money.bank
	local savestring = minetest.serialize(save)

	local filepath = minetest.get_worldpath().."/money.mt"
	local file = io.open(filepath, "w")
	if file then
		file:write(savestring)
		io.close(file)
		minetest.log("action", "[money] Wrote money data into "..filepath..".")
	else
		minetest.log("error", "[money] Failed to write money data into "..filepath..".")
	end
end

--Catch the server while it shuts down

minetest.register_on_shutdown(
	function()
		minetest.log("action", "[money] Server shuts down. Rescuing data into money.mt")
		money.save_to_file()
	end
)