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
money.config = {}
money.config.init = 100

--[===[
	API functions
]===]

function money.set(player, value)
	local value = money.round(value)

	if value < 0 then
		value = 0
		money.hud_update(player)
		return
	end
	if player:get_attribute("money:purse") ~= value then
		player:set_attribute("money:purse", tostring(value))
		money.hud_update(player)
	end
end

function money.get(player)
	return player:get_attribute("money:purse")
end

function money.add(playername, value)
	local player = minetest.get_player_by_name(playername)
	local value = money.round(value)
	local bank = tonumber(player:get_attribute("money:purse"))

	if(player ~= nil and value >= 0) then
		bank = tostring(bank + value)
		player:set_attribute("money:purse", bank)
		money.hud_update(player)
		return true
	else
		return false
	end
end

function money.subtract(player, value)
	local value = money.round(value)
	local bank = tonumber(player:get_attribute("money:purse"))

	if(player ~= nil and bank >= value and value >= 0) then
		bank = tostring(bank - value)
		money.hud_update(player)
		return true
	else
		return false
	end
end

function money.send(sender, reciver, value)
	local value = money.round(value)

	if(sender ~= nil and reciver ~= nil and sender:get_attribute("money:purse") > value and value >= 0) then
		if(money.subtract(sender, value)) then
			money.add(reciver, value)
			minetest.chat_send_player(sender, "You sent" .. value .. "to" .. reciver:get_player_name())
			minetest.chat_send_player(reciver, "You recived" .. value .. "from" .. sender:get_player_name())
			money.hud_update(sender)
			money.hud_update(reciver)
			return true
		end
	end
	return false
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
		if player:get_attribute("money:purse") == nil then
			player:set_attribute("money:purse", "100")
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