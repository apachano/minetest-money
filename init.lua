--[[
Money API
This mod adds money to players

Code from mana by Wuzzy is used under WTFPL Liscense
]]

--[===[
	Initialization
]===]

--Add Chat Command Builder By rubenwardy
dofile(minetest.get_modpath("money") .. "/ChatCmdBuilder.lua")

--[[ I need to figure out how this works to use it :/ coming soon?
local S
if (minetest.get_modpath("intllib")) then
	S = intllib.Getter()
else
	S = function(s,a,...)a={a,...}return s:gsub("@(%d+)",function(n)return a[tonumber(n)]end)end
end
]]--
money = {}
money.playerlist = {}

money.settings = {}

--[===[
	API functions
]===]

function money.set(playername, value) 
	if value < 0 then
		minetest.log("info", "[money] Warning: money.set was called with negative value!")
		value = 0
	end
	value = money.round(value)
	if money.playerlist[playername].money ~= value then
		money.playerlist[playername].money = value
		money.hud_update(playername)
	end
end

function money.get(playername)
	return money.playerlist[playername].money
end

function money.add(playername, value)
	value = tonumber(value)
	local player = money.playerlist[playername]
	value = money.round(value)
	if(player ~= nil and value >= 0) then
		player.money = player.money + value 
		money.hud_update(playername)
		return true
	else
		return false
	end
end

function money.subtract(playername, value)
	local t = money.playerlist[playername]
	value = money.round(value)
	if(t ~= nil and t.money >= value and value >= 0) then
		t.money = t.money - value 
		money.hud_update(playername)
		return true
	else
		return false
	end
end

function money.send(sender, reciver, value)
	local Sender = money.playerlist[sender]
	local Reciver = money.playerlist[reciver]
	value = money.round(value)
	if(Sender ~= nil and Reciver ~= nil and Sender.money > value and value >= 0) then
		money.subtract(sender, value)
		money.add(reciver, value)
		minetest.chat_send_player("sender", "You sent" .. value .. "to" .. reciver)
		minetest.chat_send_player("reciver", "You recived" .. value .. "from" .. sender)
		money.hud_update(sender)
		money.hud_update(reciver)
		return true
	else
		return false
	end
end

--[===[
	File handling, loading data, saving data, setting up stuff for players.
]===]

-- Load the playerlist from a previous session, if available.
do
	local filepath = minetest.get_worldpath().."/money.mt"
	local file = io.open(filepath, "r")
	if file then
		minetest.log("action", "[money] money.mt opened.")
		local string = file:read()
		io.close(file)
		if(string ~= nil) then
			local savetable = minetest.deserialize(string)
			money.playerlist = savetable.playerlist
			minetest.debug("[money] money.mt successfully read.")
		end
	end
end

function money.save_to_file()
	local savetable = {}
	savetable.playerlist = money.playerlist

	local savestring = minetest.serialize(savetable)

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


minetest.register_on_respawnplayer(
	function(player)
		local playername = player:get_player_name()
		money.set(playername, 0)
		money.hud_update(playername)
	end
)

minetest.register_on_leaveplayer(
	function(player)
		local playername = player:get_player_name()
		if not minetest.get_modpath("hudbars") ~= nil then
			money.hud_remove(playername)
		end
		money.save_to_file()
	end
)

minetest.register_on_shutdown(
	function()
		minetest.log("action", "[money] Server shuts down. Rescuing data into money.mt")
		money.save_to_file()
	end
)

minetest.register_on_joinplayer(
	function(player)
		local playername = player:get_player_name()
		
		if money.playerlist[playername] == nil then
			money.playerlist[playername] = {}
			money.playerlist[playername].money = 50
		end

		money.hud_add(playername)
	end
)

--[===[
	HUD functions
]===]
function money.moneystring(playername)
	return "money:" .. money.get(playername)
end

function money.hud_add(playername)
	local player = minetest.get_player_by_name(playername)
	local id = player:hud_add({
		hud_elem_type = "text",
		position = { x = 0.5, y=1 },
		text = money.moneystring(playername),
		scale = { x = 0, y = 0 },
		alignment = { x = 1, y = 0},
		direction = 1,
		number = 0xFFFFFF,
		offset = { x = -262, y = -103}
	})
	money.playerlist[playername].hudid = id
	return id
end

function money.hud_update(playername)
	local player = minetest.get_player_by_name(playername)
	player:hud_change(money.playerlist[playername].hudid, "text", money.moneystring(playername))
end

function money.hud_remove(playername)
	local player = minetest.get_player_by_name(playername)
	player:hud_remove(money.playerlist[playername].hudid)
end

--[===[
	Helper functions
]===]

money.round = function(x)
	return math.ceil(math.floor(x+0.5))
end

function money.help()
	minetest.chat_send_player(name, "=====Money=====")
	minetest.chat_send_player(name, "/sendmoney <player> <amount> -> sends money to specified player")
	minetest.chat_send_player(name, "=====Money=====")
	minetest.chat_send_player(name, "=====Money=====")
	minetest.chat_send_player(name, "=====Money=====")
	minetest.chat_send_player(name, "=====Money=====")
end

--[===[
	Chat Commands
]===]

ChatCmdBuilder.new("money", 
	function(cmd)
		cmd:sub("send :to :amount", function(name, to, amount)
			local player = minetest.get_player_by_name(to)
			if player then
				money.send(name, to, amount)
				return true
			else
				return false, "player does not exist"
			end
		end)
	end, {
		description = "Momey mod for MineTest",
		privs = {
			basic_privs
		}
	}
)
ChatCmdBuilder.new("money", 
	function(cmd)
		cmd:sub("give :to :amount:int", function(name, to, amount)
			if money.playerlist[to] ~= nil then
				money.add(to, amount)
				return true
			else
				return false, "Player does not exist"
			end
		end)
		cmd:sub("take :from :ammount:int", function(name, from, amount)
			if money.playerList[from] ~= nil then
				money.subtract(from, amount))
				return true;
			else
				return false; "Player does not exist"
			end
		end)
	end, {
		description = "admin money command",
		privs = {
			money_create
		}
	}

)